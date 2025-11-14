import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:teen_talk_app/src/core/services/analytics_provider.dart';
import 'package:teen_talk_app/src/core/services/analytics_service.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/feed/presentation/widgets/post_card_widget.dart';
import 'package:teen_talk_app/src/features/profile/presentation/providers/user_profile_provider.dart';
import '../helpers/golden_test_helper.dart';

class _FakeAnalyticsService extends AnalyticsService {
  @override
  void logTrustBadgeTap(String trustLevel, String location) {}
}

Widget _buildPostCard(
  Post post, {
  String? currentUserId,
  ThemeMode themeMode = ThemeMode.light,
  bool isNew = false,
  VoidCallback? onComments,
  VoidCallback? onLike,
  VoidCallback? onUnlike,
  VoidCallback? onReport,
}) {
  final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.light,
    ),
  );

  final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6366F1),
      brightness: Brightness.dark,
    ),
  );

  return ProviderScope(
    overrides: [
      analyticsServiceProvider.overrideWithValue(_FakeAnalyticsService()),
      userProfileByIdProvider.overrideWith((ref, userId) {
        return Stream.value(null);
      }),
    ],
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      home: Scaffold(
        backgroundColor: themeMode == ThemeMode.dark
            ? darkTheme.colorScheme.surface
            : lightTheme.colorScheme.surface,
        body: Center(
          child: PostCardWidget(
            post: post,
            currentUserId: currentUserId,
            onComments: onComments ?? () {},
            onLike: onLike ?? () {},
            onUnlike: onUnlike ?? () {},
            onReport: onReport ?? () {},
            isNew: isNew,
          ),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() async {
    await loadTestFonts();
  });

  group('PostCard widget golden tests', () {
    final now = DateTime(2024, 1, 15, 10, 30);

    final basePost = Post(
      id: 'post-1',
      authorId: 'author-1',
      authorNickname: 'RiverpodRanger',
      isAnonymous: false,
      content: 'We just rolled out the brand new wellness resources. '
          'Take a look and let us know your thoughts! 🌱',
      createdAt: now.subtract(const Duration(minutes: 45)),
      updatedAt: now.subtract(const Duration(minutes: 45)),
      likeCount: 12,
      likedBy: const ['currentUser', 'friend'],
      commentCount: 3,
      section: 'updates',
    );

    final anonymousPost = basePost.copyWith(
      id: 'post-2',
      authorId: 'anonymous',
      authorNickname: 'MysteryStudent',
      isAnonymous: true,
      content:
          'Does anyone have tips for balancing exams and extracurriculars? '
          'Feeling a little overwhelmed. 😅',
      likeCount: 42,
      commentCount: 18,
      section: 'confessions',
    );

    final imagePost = basePost.copyWith(
      id: 'post-3',
      authorId: 'creator-1',
      authorNickname: 'CampusPhotographer',
      content: 'Sunset behind the library tonight looked unreal! 📸',
      imageUrl: 'https://example.com/library-sunset.jpg',
      likeCount: 128,
      commentCount: 24,
      section: 'photos',
    );

    final highEngagementPost = basePost.copyWith(
      id: 'post-4',
      authorId: 'legend',
      authorNickname: 'LegendaryLeader',
      content:
          'Who else is excited for the leadership summit tomorrow? '
          'We have incredible speakers lined up and interactive workshops! '
          'Tag a friend who should be there.',
      likeCount: 1024,
      commentCount: 256,
      likedBy: List.generate(300, (index) => 'user-$index'),
      section: 'events',
    );

    testGoldens('post card variants - light theme', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'standard post',
          _buildPostCard(basePost, currentUserId: 'currentUser'),
        )
        ..addScenario(
          'anonymous post',
          _buildPostCard(anonymousPost, currentUserId: 'currentUser'),
        )
        ..addScenario(
          'image post',
          _buildPostCard(imagePost, currentUserId: 'currentUser'),
        )
        ..addScenario(
          'high engagement',
          _buildPostCard(highEngagementPost, currentUserId: 'viewer-123'),
        )
        ..addScenario(
          'new post shimmer',
          _buildPostCard(basePost, currentUserId: 'currentUser', isNew: true),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(520, 1800),
      );

      await tester.pump(const Duration(milliseconds: 300));
      await screenMatchesGolden(tester, 'post_card/post_card_variants_light');
    });

    testGoldens('post card variants - dark theme', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'standard post',
          _buildPostCard(
            basePost,
            currentUserId: 'currentUser',
            themeMode: ThemeMode.dark,
          ),
        )
        ..addScenario(
          'anonymous post',
          _buildPostCard(
            anonymousPost,
            currentUserId: 'currentUser',
            themeMode: ThemeMode.dark,
          ),
        )
        ..addScenario(
          'image post',
          _buildPostCard(
            imagePost,
            currentUserId: 'currentUser',
            themeMode: ThemeMode.dark,
          ),
        )
        ..addScenario(
          'high engagement',
          _buildPostCard(
            highEngagementPost,
            currentUserId: 'viewer-123',
            themeMode: ThemeMode.dark,
          ),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(520, 1400),
      );

      await tester.pump(const Duration(milliseconds: 300));
      await screenMatchesGolden(tester, 'post_card/post_card_variants_dark');
    });

    testGoldens('post card tablet layout', (tester) async {
      await tester.pumpWidgetBuilder(
        _buildPostCard(basePost, currentUserId: 'currentUser'),
        surfaceSize: const Size(840, 460),
      );

      await tester.pump(const Duration(milliseconds: 300));
      await screenMatchesGolden(tester, 'post_card/post_card_tablet');
    });
  });

  group('PostCard widget interactions', () {
    final post = Post(
      id: 'post-actions',
      authorId: 'author',
      authorNickname: 'ActionTester',
      isAnonymous: false,
      content: 'Testing interactions',
      createdAt: DateTime(2024, 1, 15),
      updatedAt: DateTime(2024, 1, 15),
      likeCount: 2,
      likedBy: const ['friend'],
      commentCount: 1,
      section: 'general',
    );

    ProviderScope interactionWrapper({
      required VoidCallback onLike,
      required VoidCallback onUnlike,
      required VoidCallback onComments,
    }) {
      return ProviderScope(
        overrides: [
          analyticsServiceProvider.overrideWithValue(_FakeAnalyticsService()),
          userProfileByIdProvider.overrideWith((ref, userId) {
            return Stream.value(null);
          }),
        ],
        child: MaterialApp(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
            ),
          ),
          home: Scaffold(
            body: PostCardWidget(
              post: post,
              currentUserId: 'viewer',
              onComments: onComments,
              onLike: onLike,
              onUnlike: onUnlike,
              onReport: () {},
            ),
          ),
        ),
      );
    }

    testWidgets('tapping like triggers callback', (tester) async {
      var likeTapped = false;

      await tester.pumpWidget(
        interactionWrapper(
          onLike: () => likeTapped = true,
          onUnlike: () {},
          onComments: () {},
        ),
      );

      await tester.pump();
      await tester.tap(find.byIcon(Icons.favorite_border));
      expect(likeTapped, isTrue);
    });

    testWidgets('tapping comments triggers callback', (tester) async {
      var commentsTapped = false;

      await tester.pumpWidget(
        interactionWrapper(
          onLike: () {},
          onUnlike: () {},
          onComments: () => commentsTapped = true,
        ),
      );

      await tester.pump();
      await tester.tap(find.byIcon(Icons.comment_outlined));
      expect(commentsTapped, isTrue);
    });
  });
}
