import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/queued_action.dart';
import 'connectivity_service.dart';
import '../../comments/data/repositories/posts_repository.dart';
import '../../comments/data/repositories/comments_repository.dart';
import '../../messages/data/repositories/direct_messages_repository.dart';
import '../../friends/data/repositories/friends_repository.dart';

final syncQueueServiceProvider = Provider<SyncQueueService>((ref) {
  final service = SyncQueueService(
    connectivityService: ref.watch(connectivityServiceProvider),
  );

  unawaited(service.initialize());

  ref.onDispose(() => service.dispose());
  return service;
});

final queuedActionsProvider = StreamProvider<List<QueuedAction>>((ref) {
  final service = ref.watch(syncQueueServiceProvider);
  return service.queueStream;
});

final pendingQueueCountProvider = StreamProvider<int>((ref) {
  final service = ref.watch(syncQueueServiceProvider);
  return service.queueStream.map((actions) => 
    actions.where((a) => a.isPending || a.isSyncing).length);
});

class SyncQueueService {

  SyncQueueService({
    required this.connectivityService,
  });
  static const String _boxName = 'sync_queue';
  final Logger _logger = Logger();
  final ConnectivityService connectivityService;
  
  Box<QueuedAction>? _queueBox;
  final StreamController<List<QueuedAction>> _queueController =
      StreamController<List<QueuedAction>>.broadcast();
  StreamSubscription<ConnectivityStatus>? _connectivitySubscription;
  Timer? _syncTimer;

  Stream<List<QueuedAction>> get queueStream => _queueController.stream;

  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        await Hive.initFlutter();
      } else if (Platform.isLinux) {
        Hive.init('./hive_boxes');
      } else {
        await Hive.initFlutter();
      }
      
      if (!Hive.isAdapterRegistered(0)) {
        final adapter = QueuedActionAdapter();
        Hive.registerAdapter(adapter);
      }
      if (!Hive.isAdapterRegistered(1)) {
        final adapter = QueuedActionTypeAdapter();
        Hive.registerAdapter(adapter);
      }
      if (!Hive.isAdapterRegistered(2)) {
        final adapter = QueuedActionStatusAdapter();
        Hive.registerAdapter(adapter);
      }

      _queueBox = await Hive.openBox<QueuedAction>(_boxName);
      _logger.i('Sync queue initialized with ${_queueBox?.length ?? 0} items');

      _emitQueueUpdate();
      
      _connectivitySubscription = connectivityService.connectivityStream.listen((status) {
        if (status == ConnectivityStatus.online) {
          _logger.d('Connection restored, triggering sync');
          _triggerSync();
        }
      });

      _startPeriodicSync();
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize sync queue', error: e, stackTrace: stackTrace);
    }
  }

  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(const Duration(minutes: 5), (timer) {
      _triggerSync();
    });
  }

  Future<void> _triggerSync() async {
    if (!await connectivityService.isOnline()) {
      _logger.d('Offline, skipping sync');
      return;
    }

    await syncPendingActions();
  }

  Future<String> enqueue(QueuedAction action) async {
    try {
      await _queueBox?.put(action.id, action);
      _logger.i('Enqueued ${action.type.name} action: ${action.id}');
      _emitQueueUpdate();
      
      if (await connectivityService.isOnline()) {
        unawaited(_triggerSync());
      }
      
      return action.id;
    } catch (e, stackTrace) {
      _logger.e('Failed to enqueue action', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> syncPendingActions() async {
    final box = _queueBox;
    if (box == null) {
      _logger.w('Queue box not initialized');
      return;
    }

    if (!await connectivityService.isOnline()) {
      _logger.d('Offline, cannot sync');
      return;
    }

    final pendingActions = box.values
        .where((action) => action.isPending || (action.hasFailed && action.canRetry))
        .toList();

    if (pendingActions.isEmpty) {
      _logger.d('No pending actions to sync');
      return;
    }

    _logger.i('Syncing ${pendingActions.length} pending actions');

    for (final action in pendingActions) {
      if (!await connectivityService.isOnline()) {
        _logger.w('Lost connection during sync');
        break;
      }

      try {
        action.markAsSyncing();
        await action.save();
        _emitQueueUpdate();

        await _syncAction(action);

        action.markAsCompleted();
        await action.save();
        _logger.i('Successfully synced ${action.type.name} action: ${action.id}');
        
        _emitQueueUpdate();
      } catch (e, stackTrace) {
        _logger.e('Failed to sync action ${action.id}', error: e, stackTrace: stackTrace);
        action.markAsFailed(e.toString());
        await action.save();
        _emitQueueUpdate();
      }
    }

    await _cleanupOldCompletedActions();
  }

  Future<void> _syncAction(QueuedAction action) async {
    switch (action.type) {
      case QueuedActionType.post:
        await _syncPost(action);
        break;
      case QueuedActionType.comment:
        await _syncComment(action);
        break;
      case QueuedActionType.directMessage:
        await _syncDirectMessage(action);
        break;
    }
  }

  Future<void> _syncPost(QueuedAction action) async {
    final data = action.data;
    final repository = PostsRepository();

    await repository.createPost(
      authorId: data['authorId'] as String,
      authorNickname: data['authorNickname'] as String,
      isAnonymous: data['isAnonymous'] as bool,
      content: data['content'] as String,
      section: data['section'] as String? ?? 'spotted',
      school: data['school'] as String?,
    );
  }

  Future<void> _syncComment(QueuedAction action) async {
    final data = action.data;
    final repository = CommentsRepository();
    
    final school = data['school'] as String?;
    if (school == null || school.isEmpty) {
      throw Exception('Comment requires a valid school to be synced');
    }
    
    await repository.createComment(
      postId: data['postId'] as String,
      authorId: data['authorId'] as String,
      authorNickname: data['authorNickname'] as String,
      isAnonymous: data['isAnonymous'] as bool,
      content: data['content'] as String,
      school: school,
      replyToCommentId: data['replyToCommentId'] as String?,
    );
  }

  Future<void> _syncDirectMessage(QueuedAction action) async {
    final data = action.data;
    final repository = DirectMessagesRepository(
      FirebaseFirestore.instance,
      FriendsRepository(FirebaseFirestore.instance),
    );

    await repository.sendMessage(
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      text: data['text'] as String,
      imageUrl: data['imageUrl'] as String?,
    );
  }

  Future<void> _cleanupOldCompletedActions() async {
    final box = _queueBox;
    if (box == null) return;

    final now = DateTime.now();
    final cutoffDate = now.subtract(const Duration(days: 7));

    final toDelete = <String>[];
    for (final action in box.values) {
      if (action.isCompleted && 
          action.completedAt != null && 
          action.completedAt!.isBefore(cutoffDate)) {
        toDelete.add(action.id);
      }
    }

    for (final id in toDelete) {
      await box.delete(id);
    }

    if (toDelete.isNotEmpty) {
      _logger.i('Cleaned up ${toDelete.length} old completed actions');
      _emitQueueUpdate();
    }
  }

  Future<void> clearQueue() async {
    try {
      await _queueBox?.clear();
      _logger.i('Queue cleared');
      _emitQueueUpdate();
    } catch (e, stackTrace) {
      _logger.e('Failed to clear queue', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> removeAction(String actionId) async {
    try {
      await _queueBox?.delete(actionId);
      _logger.i('Removed action: $actionId');
      _emitQueueUpdate();
    } catch (e, stackTrace) {
      _logger.e('Failed to remove action', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<void> retryAction(String actionId) async {
    try {
      final action = _queueBox?.get(actionId);
      if (action != null && action.hasFailed && action.canRetry) {
        action.resetForRetry();
        await action.save();
        _logger.i('Retrying action: $actionId');
        _emitQueueUpdate();
        
        if (await connectivityService.isOnline()) {
          await syncPendingActions();
        }
      }
    } catch (e, stackTrace) {
      _logger.e('Failed to retry action', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  List<QueuedAction> getPendingActions() {
    return _queueBox?.values
        .where((action) => action.isPending || action.isSyncing)
        .toList() ?? [];
  }

  List<QueuedAction> getAllActions() {
    return _queueBox?.values.toList() ?? [];
  }

  void _emitQueueUpdate() {
    if (!_queueController.isClosed) {
      _queueController.add(getAllActions());
    }
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _syncTimer?.cancel();
    _queueController.close();
  }
}

void unawaited(Future<void> future) {
  // Explicitly ignore the future
}
