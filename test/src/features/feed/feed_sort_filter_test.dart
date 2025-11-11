import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/feed/presentation/providers/feed_provider.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/comments/data/repositories/posts_repository.dart';
import 'package:teen_talk_app/src/features/feed/domain/models/feed_sort_option.dart';

void main() {
  group('Feed Sort Filter Tests', () {
    late ProviderContainer container;
    late MockPostsRepository mockRepository;

    setUp(() {
      mockRepository = MockPostsRepository();
      container = ProviderContainer(
        overrides: [
          feedRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state should have newest sort option by default', () {
      final state = container.read(feedProvider('spotted'));
      
      expect(state.posts.isEmpty, true);
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.sortOption, FeedSortOption.newest);
    });

    test('should update sort option when calling updateSortOption', () async {
      final notifier = container.read(feedProvider('spotted').notifier);
      
      await notifier.updateSortOption(
        FeedSortOption.mostLiked,
        section: 'spotted',
      );

      final state = container.read(feedProvider('spotted'));
      expect(state.sortOption, FeedSortOption.mostLiked);
    });

    test('should persist sort option across load operations', () async {
      final notifier = container.read(feedProvider('spotted').notifier);
      
      await notifier.loadPosts(
        refresh: true,
        section: 'spotted',
        sortOption: FeedSortOption.trending,
      );

      final state = container.read(feedProvider('spotted'));
      expect(state.sortOption, FeedSortOption.trending);
    });

    test('FeedSortOption should return correct field names', () {
      expect(FeedSortOption.newest.primaryOrderField, 'createdAt');
      expect(FeedSortOption.mostLiked.primaryOrderField, 'likeCount');
      expect(FeedSortOption.trending.primaryOrderField, 'engagementScore');

      expect(FeedSortOption.newest.secondaryOrderField, null);
      expect(FeedSortOption.mostLiked.secondaryOrderField, 'createdAt');
      expect(FeedSortOption.trending.secondaryOrderField, 'createdAt');
    });

    test('FeedSortOptionX.fromStorage should parse values correctly', () {
      expect(
        FeedSortOptionX.fromStorage('newest'),
        FeedSortOption.newest,
      );
      expect(
        FeedSortOptionX.fromStorage('most_liked'),
        FeedSortOption.mostLiked,
      );
      expect(
        FeedSortOptionX.fromStorage('trending'),
        FeedSortOption.trending,
      );
      expect(
        FeedSortOptionX.fromStorage('invalid'),
        FeedSortOption.newest,
      );
    });
  });

  group('PostsRepository Sort Tests', () {
    test('should call getPosts with correct sort option', () async {
      final mockRepo = MockPostsRepository();
      
      await mockRepo.getPosts(
        section: 'spotted',
        sortOption: FeedSortOption.mostLiked,
      );

      expect(mockRepo.lastCalledSortOption, FeedSortOption.mostLiked);
    });
  });
}

class MockPostsRepository extends PostsRepository {
  FeedSortOption? lastCalledSortOption;

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
    lastCalledSortOption = sortOption;
    
    final now = DateTime.now();
    final mockPosts = [
      Post(
        id: '1',
        authorId: 'user1',
        authorNickname: 'User 1',
        isAnonymous: false,
        content: 'Test post 1',
        createdAt: now,
        updatedAt: now,
        likeCount: 10,
        commentCount: 5,
        engagementScore: 15.0,
        section: 'spotted',
      ),
      Post(
        id: '2',
        authorId: 'user2',
        authorNickname: 'User 2',
        isAnonymous: false,
        content: 'Test post 2',
        createdAt: now.subtract(const Duration(hours: 1)),
        updatedAt: now.subtract(const Duration(hours: 1)),
        likeCount: 20,
        commentCount: 10,
        engagementScore: 30.0,
        section: 'spotted',
      ),
    ];
    
    return (posts: mockPosts, lastDocument: null, hasMore: false, paginationToken: null);
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
}
