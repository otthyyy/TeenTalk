import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/feed/presentation/widgets/post_card_widget.dart';
import '../helpers/golden_test_config.dart';
import '../helpers/test_helpers.dart';

void main() {
  late Post testPost;

  setUp(() {
    testPost = Post(
      id: 'test-post-1',
      authorId: 'user123',
      authorNickname: 'TestUser',
      isAnonymous: false,
      content: 'This is a test post to verify accessibility features',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      updatedAt: DateTime.now().subtract(const Duration(hours: 2)),
      likeCount: 5,
      likedBy: [],
      commentCount: 3,
      section: 'spotted',
    );
  });

  group('PostCardWidget Accessibility Tests', () {
    testWidgets('has correct semantic labels for post header', (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: testPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final semanticsFinder = find.bySemanticsLabel(
        RegExp('Post by TestUser.*2h ago', caseSensitive: false),
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('has semantic label for anonymous posts', (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

      final anonymousPost = testPost.copyWith(
        isAnonymous: true,
        authorNickname: 'Anonymous',
      );

      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: anonymousPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final semanticsFinder = find.bySemanticsLabel(
        RegExp('Post by Anonymous.*2h ago', caseSensitive: false),
      );
      expect(semanticsFinder, findsOneWidget);
    });

    testWidgets('has semantic labels for like button', (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: testPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final likeButtonFinder = find.bySemanticsLabel(
        RegExp('Like post.*5 likes', caseSensitive: false),
      );
      expect(likeButtonFinder, findsOneWidget);
    });

    testWidgets('has semantic labels for comment button', (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: testPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final commentButtonFinder = find.bySemanticsLabel(
        RegExp('View comments.*3 comments', caseSensitive: false),
      );
      expect(commentButtonFinder, findsOneWidget);
    });

    testWidgets('has semantic label for post content', (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: testPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final contentFinder = find.bySemanticsLabel(
        'Post content: This is a test post to verify accessibility features',
      );
      expect(contentFinder, findsOneWidget);
    });

    testWidgets('has semantic label for section badge', (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: testPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final sectionFinder = find.bySemanticsLabel('Section: spotted');
      expect(sectionFinder, findsOneWidget);
    });

    testWidgets('semantic labels update when post is liked', (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

      final likedPost = testPost.copyWith(
        likedBy: ['current-user'],
      );

      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: likedPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final unlikeButtonFinder = find.bySemanticsLabel(
        RegExp('Unlike post.*5 likes', caseSensitive: false),
      );
      expect(unlikeButtonFinder, findsOneWidget);
    });

    testWidgets('test fails when semantics labels are removed', (tester) async {
      final semantics = tester.ensureSemantics();
      addTearDown(semantics.dispose);

      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: testPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final likeButtonFinder = find.bySemanticsLabel(
        RegExp('Like post', caseSensitive: false),
      );
      expect(
        likeButtonFinder,
        findsOneWidget,
        reason: 'Like button must have semantic label for accessibility',
      );
    });
  });

  group('PostCardWidget Golden Tests', () {
    testWidgets('renders correctly at 1.0x text scale', (tester) async {
      await loadGoldenTestFonts();

      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: testPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PostCardWidget),
        matchesGoldenFile('goldens/post_card_1.0x.png'),
      );
    });

    testWidgets('renders correctly at 1.3x text scale', (tester) async {
      await loadGoldenTestFonts();

      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: testPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
          textScaleFactor: 1.3,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PostCardWidget),
        matchesGoldenFile('goldens/post_card_1.3x.png'),
      );
    });

    testWidgets('renders correctly at 2.0x text scale', (tester) async {
      await loadGoldenTestFonts();

      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: testPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
          textScaleFactor: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(PostCardWidget),
        matchesGoldenFile('goldens/post_card_2.0x.png'),
      );
    });

    testWidgets('no overflow at 1.3x text scale', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: testPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
          textScaleFactor: 1.3,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'No overflow should occur at 1.3x text scale',
      );
    });

    testWidgets('no overflow at 2.0x text scale', (tester) async {
      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: testPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
          textScaleFactor: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'No overflow should occur at 2.0x text scale',
      );
    });

    testWidgets('long content no overflow at 2.0x text scale', (tester) async {
      final longPost = testPost.copyWith(
        content: 'This is a very long post content that should test whether '
            'the widget can handle long text at increased scale factors without '
            'causing any overflow issues in the UI rendering.',
      );

      await tester.pumpWidget(
        createTestApp(
          PostCardWidget(
            post: longPost,
            currentUserId: 'current-user',
            onComments: () {},
            onLike: () {},
            onUnlike: () {},
            onReport: () {},
          ),
          textScaleFactor: 2.0,
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isNull,
        reason: 'No overflow should occur with long content at 2.0x text scale',
      );
    });
  });
}
