import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/queued_action.dart';
import 'connectivity_service.dart';
import 'sync_queue_service.dart';

final offlineSubmissionHelperProvider = Provider<OfflineSubmissionHelper>((ref) {
  return OfflineSubmissionHelper(
    connectivityService: ref.watch(connectivityServiceProvider),
    syncQueueService: ref.watch(syncQueueServiceProvider),
  );
});

class OfflineSubmissionHelper {
  final ConnectivityService connectivityService;
  final SyncQueueService syncQueueService;
  final Logger _logger = Logger();
  final Random _random = Random();

  OfflineSubmissionHelper({
    required this.connectivityService,
    required this.syncQueueService,
  });

  Future<String?> enqueuePost({
    required String authorId,
    required String authorNickname,
    required bool isAnonymous,
    required String content,
    required String section,
    String? school,
    String? imagePath,
    String? imageName,
  }) async {
    try {
      final existing = _findDuplicate(
        type: QueuedActionType.post,
        matcher: (action) =>
            action.data['authorId'] == authorId &&
            action.data['content'] == content &&
            action.data['imagePath'] == imagePath &&
            action.isPending,
      );

      if (existing != null) {
        _logger.w('Duplicate post action detected, reusing ${existing.id}');
        return existing.id;
      }

      final randomSuffix = _random.nextInt(10000);
      final action = QueuedAction(
        id: '${DateTime.now().millisecondsSinceEpoch}_post_${randomSuffix}',
        type: QueuedActionType.post,
        data: {
          'authorId': authorId,
          'authorNickname': authorNickname,
          'isAnonymous': isAnonymous,
          'content': content,
          'section': section,
          'school': school,
          'imagePath': imagePath,
          'imageName': imageName,
        },
        createdAt: DateTime.now(),
      );

      final actionId = await syncQueueService.enqueue(action);
      _logger.i('Post enqueued for offline sync: $actionId');
      return actionId;
    } catch (e, stackTrace) {
      _logger.e('Failed to enqueue post', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<String?> enqueueComment({
    required String postId,
    required String authorId,
    required String authorNickname,
    required bool isAnonymous,
    required String content,
    required String school,
    String? replyToCommentId,
  }) async {
    try {
      final existing = _findDuplicate(
        type: QueuedActionType.comment,
        matcher: (action) =>
            action.data['postId'] == postId &&
            action.data['authorId'] == authorId &&
            action.data['content'] == content &&
            action.isPending,
      );

      if (existing != null) {
        _logger.w('Duplicate comment action detected, reusing ${existing.id}');
        return existing.id;
      }

      final randomSuffix = _random.nextInt(10000);
      final action = QueuedAction(
        id: '${DateTime.now().millisecondsSinceEpoch}_comment_${randomSuffix}',
        type: QueuedActionType.comment,
        data: {
          'postId': postId,
          'authorId': authorId,
          'authorNickname': authorNickname,
          'isAnonymous': isAnonymous,
          'content': content,
          'school': school,
          'replyToCommentId': replyToCommentId,
        },
        createdAt: DateTime.now(),
      );

      final actionId = await syncQueueService.enqueue(action);
      _logger.i('Comment enqueued for offline sync: $actionId');
      return actionId;
    } catch (e, stackTrace) {
      _logger.e('Failed to enqueue comment', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<String?> enqueueDirectMessage({
    required String senderId,
    required String receiverId,
    required String text,
    String? imageUrl,
  }) async {
    try {
      final existing = _findDuplicate(
        type: QueuedActionType.directMessage,
        matcher: (action) =>
            action.data['senderId'] == senderId &&
            action.data['receiverId'] == receiverId &&
            action.data['text'] == text &&
            action.isPending,
      );

      if (existing != null) {
        _logger.w('Duplicate direct message action detected, reusing ${existing.id}');
        return existing.id;
      }

      final randomSuffix = _random.nextInt(10000);
      final action = QueuedAction(
        id: '${DateTime.now().millisecondsSinceEpoch}_dm_${randomSuffix}',
        type: QueuedActionType.directMessage,
        data: {
          'senderId': senderId,
          'receiverId': receiverId,
          'text': text,
          'imageUrl': imageUrl,
        },
        createdAt: DateTime.now(),
      );

      final actionId = await syncQueueService.enqueue(action);
      _logger.i('Direct message enqueued for offline sync: $actionId');
      return actionId;
    } catch (e, stackTrace) {
      _logger.e('Failed to enqueue direct message', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  QueuedAction? _findDuplicate({
    required QueuedActionType type,
    required bool Function(QueuedAction) matcher,
  }) {
    final allActions = syncQueueService.getAllActions();
    for (final action in allActions) {
      if (action.type == type && matcher(action)) {
        return action;
      }
    }
    return null;
  }

  Future<bool> isOnline() async {
    return await connectivityService.isOnline();
  }
}

