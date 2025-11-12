import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/core/services/connectivity_service.dart';
import 'package:teen_talk_app/src/core/services/feed_cache_service.dart';
import 'package:teen_talk_app/src/core/providers/connectivity_provider.dart';
import 'package:teen_talk_app/src/core/providers/feed_cache_provider.dart';
import 'package:teen_talk_app/src/features/feed/presentation/providers/feed_provider.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/comments/data/repositories/posts_repository.dart';
import 'package:teen_talk_app/src/features/feed/domain/models/feed_sort_option.dart';

void main() {
  group('FeedProvider Tests', () {
    late ProviderContainer container;
    late MockPostsRepository mockRepository;
    late MockConnectivityService mockConnectivityService;
    late MockFeedCacheService mockCacheService;

    setUp(() {
      mockRepository = MockPostsRepository();
      mockConnectivityService = MockConnectivityService();
      mockCacheService = MockFeedCacheService();
      
      container = ProviderContainer(
        overrides: [
          feedRepositoryProvider.overrideWithValue(mockRepository),
          connectivityServiceProvider.overrideWithValue(mockConnectivityService),
          feedCacheServiceProvider.overrideWithValue(mockCacheService),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should be empty', () {
      container.read(feedProvider('spotted').notifier);
      final state = container.read(feedProvider('spotted'));
      
      expect(state.posts.isEmpty, true);
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.sortOption, FeedSortOption.newest);
    });

    group('likePost', () {
      test('updates in-memory state on successful like', () async {
        final post = Post(
          id: 'post1',
          authorId: 'author1',
          authorNickname: 'Author',
          isAnonymous: false,
          content: 'Test post',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          likeCount: 0,
          likedBy: [],
        );

        mockRepository.shouldSucceed = true;
        
        final notifier = container.read(feedProvider('spotted').notifier);
        notifier.state = notifier.state.copyWith(posts: [post]);

        await notifier.likePost('post1', 'user1');

        final state = container.read(feedProvider('spotted'));
        expect(state.posts.first.likeCount, 1);
        expect(state.posts.first.likedBy, contains('user1'));
        expect(state.error, isNull);
      });

      test('sets error message on failed like', () async {
        final post = Post(
          id: 'post1',
          authorId: 'author1',
          authorNickname: 'Author',
          isAnonymous: false,
          content: 'Test post',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          likeCount: 0,
          likedBy: [],
        );

        mockRepository.shouldSucceed = false;
        mockRepository.errorMessage = 'Network connection lost. Please check your connection and try again.';
        
        final notifier = container.read(feedProvider('spotted').notifier);
        notifier.state = notifier.state.copyWith(posts: [post]);

        await notifier.likePost('post1', 'user1');

        final state = container.read(feedProvider('spotted'));
        expect(state.posts.first.likeCount, 0);
        expect(state.posts.first.likedBy, isEmpty);
        expect(state.error, contains('Network connection lost'));

        notifier.clearError();
        final clearedState = container.read(feedProvider('spotted'));
        expect(clearedState.error, isNull);
      });

      test('does not update already liked post', () async {
        final post = Post(
          id: 'post1',
          authorId: 'author1',
          authorNickname: 'Author',
          isAnonymous: false,
          content: 'Test post',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          likeCount: 1,
          likedBy: ['user1'],
        );

        mockRepository.shouldSucceed = true;
        
        final notifier = container.read(feedProvider('spotted').notifier);
        notifier.state = notifier.state.copyWith(posts: [post]);

        await notifier.likePost('post1', 'user1');

        final state = container.read(feedProvider('spotted'));
        expect(state.posts.first.likeCount, 1);
        expect(state.posts.first.likedBy, ['user1']);
      });
    });

    group('unlikePost', () {
      test('updates in-memory state on successful unlike', () async {
        final post = Post(
          id: 'post1',
          authorId: 'author1',
          authorNickname: 'Author',
          isAnonymous: false,
          content: 'Test post',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          likeCount: 1,
          likedBy: ['user1'],
        );

        mockRepository.shouldSucceed = true;
        
        final notifier = container.read(feedProvider('spotted').notifier);
        notifier.state = notifier.state.copyWith(posts: [post]);

        await notifier.unlikePost('post1', 'user1');

        final state = container.read(feedProvider('spotted'));
        expect(state.posts.first.likeCount, 0);
        expect(state.posts.first.likedBy, isEmpty);
        expect(state.error, isNull);
      });

      test('sets error message on failed unlike', () async {
        final post = Post(
          id: 'post1',
          authorId: 'author1',
          authorNickname: 'Author',
          isAnonymous: false,
          content: 'Test post',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          likeCount: 1,
          likedBy: ['user1'],
        );

        mockRepository.shouldSucceed = false;
        mockRepository.errorMessage = 'This post no longer exists.';
        
        final notifier = container.read(feedProvider('spotted').notifier);
        notifier.state = notifier.state.copyWith(posts: [post]);

        await notifier.unlikePost('post1', 'user1');

        final state = container.read(feedProvider('spotted'));
        expect(state.posts.first.likeCount, 1);
        expect(state.posts.first.likedBy, ['user1']);
        expect(state.error, contains('post no longer exists'));
      });

      test('does not update already unliked post', () async {
        final post = Post(
          id: 'post1',
          authorId: 'author1',
          authorNickname: 'Author',
          isAnonymous: false,
          content: 'Test post',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          likeCount: 0,
          likedBy: [],
        );

        mockRepository.shouldSucceed = true;
        
        final notifier = container.read(feedProvider('spotted').notifier);
        notifier.state = notifier.state.copyWith(posts: [post]);

        await notifier.unlikePost('post1', 'user1');

        final state = container.read(feedProvider('spotted'));
        expect(state.posts.first.likeCount, 0);
        expect(state.posts.first.likedBy, isEmpty);
      });
    });
  });
}

class MockPostsRepository extends PostsRepository {
  bool shouldSucceed = true;
  String errorMessage = 'Test error';

  @override
  Future<({
    List<Post> posts,
    DocumentSnapshot? lastDocument,
    bool hasMore,
    String? paginationToken,
  })> getPosts({
    DocumentSnapshot? lastDocument,
    int limit = 20,
    String? section,
    String? school,
    FeedSortOption sortOption = FeedSortOption.newest,
    bool forceRefresh = false,
  }) async {
    return (posts: [], lastDocument: null, hasMore: false, paginationToken: null);
  }

  @override
  Stream<List<Post>> getPostsStream({
    String? section,
    String? school,
    int limit = 20,
    FeedSortOption sortOption = FeedSortOption.newest,
  }) {
    return Stream.value([]);
  }

  @override
  Future<void> likePost(String postId, String userId) async {
    if (!shouldSucceed) {
      throw Exception(errorMessage);
    }
  }

  @override
  Future<void> unlikePost(String postId, String userId) async {
    if (!shouldSucceed) {
      throw Exception(errorMessage);
    }
  }
}

class MockConnectivityService extends ConnectivityService {
  @override
  bool get isConnected => true;

  @override
  Stream<bool> get connectivityStream => Stream.value(true);

  @override
  Future<void> initialize() async {}
}

class MockFeedCacheService extends FeedCacheService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> dispose() async {}
}
