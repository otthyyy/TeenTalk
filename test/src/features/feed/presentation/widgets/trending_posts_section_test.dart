import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/feed/presentation/providers/feed_provider.dart';
import 'package:teen_talk_app/src/features/feed/presentation/widgets/trending_posts_section.dart';

class TestFeedNotifier extends StateNotifier<FeedState> {
  TestFeedNotifier(FeedState state) : super(state);

  void update(FeedState newState) {
    state = newState;
  }
}

final _mockPost = Post(
  id: 'post-1',
  authorId: 'author-1',
  authorNickname: 'Jane Doe',
  isAnonymous: false,
  content: 'This is a trending post',
  createdAt: DateTime(2024, 1, 1),
  updatedAt: DateTime(2024, 1, 1),
  likeCount: 10,
  commentCount: 5,
  engagementScore: 90,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TrendingPostsSection', () {
    testWidgets('shows loading indicator while posts are loading', (tester) async {
      final notifier = TestFeedNotifier(const FeedState(isLoading: true, posts: []));
      final overrideProvider = StateNotifierProvider<TestFeedNotifier, FeedState>((ref) => notifier);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            schoolAwareFeedProvider('test-section').overrideWithProvider(overrideProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TrendingPostsSection(section: 'test-section'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows empty state when there are no trending posts', (tester) async {
      final notifier = TestFeedNotifier(const FeedState(isLoading: false, posts: []));
      final overrideProvider = StateNotifierProvider<TestFeedNotifier, FeedState>((ref) => notifier);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            schoolAwareFeedProvider('test-section').overrideWithProvider(overrideProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TrendingPostsSection(section: 'test-section'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('No trending posts yet. Check back soon!'), findsOneWidget);
    });

    testWidgets('shows trending post when posts are available', (tester) async {
      final notifier = TestFeedNotifier(const FeedState(isLoading: false, posts: []));
      final overrideProvider = StateNotifierProvider<TestFeedNotifier, FeedState>((ref) => notifier);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            schoolAwareFeedProvider('test-section').overrideWithProvider(overrideProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TrendingPostsSection(section: 'test-section'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      notifier.update(FeedState(posts: [_mockPost]));

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('This is a trending post'), findsOneWidget);
      expect(find.text('5 comments'), findsOneWidget);
    });

    testWidgets('invokes callback when trending post is tapped', (tester) async {
      final notifier = TestFeedNotifier(FeedState(posts: [_mockPost]));
      final overrideProvider = StateNotifierProvider<TestFeedNotifier, FeedState>((ref) => notifier);

      Post? selectedPost;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            schoolAwareFeedProvider('test-section').overrideWithProvider(overrideProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: TrendingPostsSection(
                section: 'test-section',
                onPostSelected: (post) => selectedPost = post,
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      await tester.tap(find.text('View Post'));
      await tester.pump();

      expect(selectedPost, isNotNull);
      expect(selectedPost!.id, equals('post-1'));
    });

    testWidgets('shows error message when FeedState has error', (tester) async {
      final notifier = TestFeedNotifier(const FeedState(error: 'Unable to load', posts: []));
      final overrideProvider = StateNotifierProvider<TestFeedNotifier, FeedState>((ref) => notifier);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            schoolAwareFeedProvider('test-section').overrideWithProvider(overrideProvider),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: TrendingPostsSection(section: 'test-section'),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Unable to load'), findsOneWidget);
    });
  });
}
