import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:teen_talk_app/src/core/services/connectivity_service.dart';
import 'package:teen_talk_app/src/core/services/feed_cache_service.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/comments/data/repositories/posts_repository.dart';
import 'package:teen_talk_app/src/features/feed/domain/models/feed_sort_option.dart';
import 'package:teen_talk_app/src/features/feed/presentation/providers/feed_provider.dart';

class MockPostsRepository extends Mock implements PostsRepository {}


class FakeConnectivityService extends ConnectivityService {
  FakeConnectivityService({bool initialStatus = false})
      : _isConnected = initialStatus {
    _controller.add(_isConnected);
  }

  bool _isConnected;
  final StreamController<bool> _controller = StreamController<bool>.broadcast();

  @override
  bool get isConnected => _isConnected;

  @override
  Stream<bool> get connectivityStream => _controller.stream;

  @override
  Future<void> initialize() async {}

  void setConnectionStatus(bool value) {
    if (_isConnected != value) {
      _isConnected = value;
      _controller.add(value);
    }
  }

  @override
  void dispose() {
    _controller.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FeedCacheService cacheService;
  late Directory tempDir;
  late MockPostsRepository postsRepository;
  late FakeConnectivityService connectivityService;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('feed_offline_test');
    Hive.init(tempDir.path);
    cacheService = FeedCacheService();
    await cacheService.initialize();

    postsRepository = MockPostsRepository();
    connectivityService = FakeConnectivityService(initialStatus: false);
  });

  tearDown(() async {
    await cacheService.dispose();
    connectivityService.dispose();
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FeedNotifier offline behavior', () {
    test('loads posts from cache when offline', () async {
      final cachedPosts = [
        Post(
          id: '1',
          authorId: 'author',
          authorNickname: 'Author',
          isAnonymous: false,
          content: 'Cached post',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          section: 'spotted',
        ),
      ];

      await cacheService.cachePosts(
        cachedPosts,
        sortOption: FeedSortOption.newest,
        section: 'spotted',
      );

      final notifier = FeedNotifier(
        postsRepository,
        cacheService,
        connectivityService,
      );

      await notifier.loadPosts(section: 'spotted');

      expect(notifier.state.posts, hasLength(1));
      expect(notifier.state.posts.first.id, '1');
      expect(notifier.state.isOffline, isTrue);
      expect(notifier.state.hasMore, isFalse);
      expect(notifier.state.lastSyncedAt, isNotNull);
      verifyNever(postsRepository.getPosts(
        section: anyNamed('section'),
        school: anyNamed('school'),
        sortOption: anyNamed('sortOption'),
        lastDocument: anyNamed('lastDocument'),
        limit: anyNamed('limit'),
      ));
    });

    test('reloads from network when connection restored', () async {
      final onlinePosts = [
        Post(
          id: 'network-1',
          authorId: 'author-network',
          authorNickname: 'Network User',
          isAnonymous: false,
          content: 'Online post',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          section: 'spotted',
        ),
      ];

      when(postsRepository.getPosts(
        section: anyNamed('section'),
        school: anyNamed('school'),
        sortOption: anyNamed('sortOption'),
        lastDocument: anyNamed('lastDocument'),
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => (onlinePosts, null));

      when(postsRepository.getPostsStream(
        section: anyNamed('section'),
        school: anyNamed('school'),
        limit: anyNamed('limit'),
        sortOption: anyNamed('sortOption'),
      )).thenAnswer((_) => const Stream.empty());

      final notifier = FeedNotifier(
        postsRepository,
        cacheService,
        connectivityService,
      );

      connectivityService.setConnectionStatus(true);

      await notifier.loadPosts(section: 'spotted');

      expect(notifier.state.isOffline, isFalse);
      expect(notifier.state.posts, hasLength(1));
      expect(notifier.state.posts.first.id, 'network-1');
      verify(postsRepository.getPosts(
        section: anyNamed('section'),
        school: anyNamed('school'),
        sortOption: anyNamed('sortOption'),
        lastDocument: anyNamed('lastDocument'),
        limit: anyNamed('limit'),
      )).called(1);
    });
  });
}
