import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/feed/presentation/providers/feed_provider.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/comments/data/repositories/posts_repository.dart';
import 'package:teen_talk_app/src/features/feed/domain/models/feed_sort_option.dart';

void main() {
  group('FeedProvider Tests', () {
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

    test('initial state should be empty', () {
      container.read(feedProvider('spotted').notifier);
      final state = container.read(feedProvider('spotted'));
      
      expect(state.posts.isEmpty, true);
      expect(state.isLoading, false);
      expect(state.error, null);
      expect(state.sortOption, FeedSortOption.newest);
    });
  });
}

class MockPostsRepository extends PostsRepository {
  @override
  Future<(List<Post>, DocumentSnapshot?)> getPosts({
    DocumentSnapshot? lastDocument,
    int limit = 20,
    String? section,
    String? school,
    FeedSortOption sortOption = FeedSortOption.newest,
  }) async {
    return ([], null);
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
