import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/feed/presentation/providers/feed_provider.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/comments/data/repositories/posts_repository.dart';

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
      final notifier = container.read(feedProvider('spotted').notifier);
      final state = container.read(feedProvider('spotted'));
      
      expect(state.posts.isEmpty, true);
      expect(state.isLoading, false);
      expect(state.error, null);
    });
  });
}

class MockPostsRepository extends PostsRepository {
  @override
  Future<List<Post>> getPosts({
    DocumentSnapshot? lastDocument,
    int limit = 20,
    String? section,
  }) async {
    // Mock implementation
    return [];
  }

  @override
  Stream<List<Post>> getPostsStream({
    String? section,
    int limit = 20,
  }) {
    // Mock implementation
    return Stream.value([]);
  }
}