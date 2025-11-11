import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/feed/presentation/widgets/post_card_widget.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/user_profile.dart';
import 'package:teen_talk_app/src/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/trust_level.dart';

void main() {
  group('PostCardWidget Navigation Tests', () {
    testWidgets('tapping non-anonymous author nickname navigates to public profile',
        (tester) async {
      final testPost = Post(
        id: 'test-post-1',
        authorId: 'user123',
        authorNickname: 'TestUser',
        isAnonymous: false,
        content: 'Test post for navigation',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likeCount: 0,
        likedBy: [],
        commentCount: 0,
        section: 'spotted',
      );

      final mockUserProfile = UserProfile(
        uid: 'user123',
        nickname: 'TestUser',
        nicknameVerified: true,
        createdAt: DateTime.now(),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime.now(),
        trustLevel: TrustLevel.established,
      );

      String? navigatedTo;
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const SizedBox(),
          ),
          GoRoute(
            path: '/users/:userId',
            builder: (context, state) {
              navigatedTo = '/users/${state.pathParameters['userId']}';
              return const SizedBox();
            },
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileByIdProvider('user123').overrideWith((ref) {
              return Stream.value(mockUserProfile);
            }),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      router.go('/');
      await tester.pumpAndSettle();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileByIdProvider('user123').overrideWith((ref) {
              return Stream.value(mockUserProfile);
            }),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Scaffold(
                    body: PostCardWidget(
                      post: testPost,
                      currentUserId: 'current-user',
                      onComments: () {},
                      onLike: () {},
                      onUnlike: () {},
                      onReport: () {},
                    ),
                  ),
                ),
                GoRoute(
                  path: '/users/:userId',
                  builder: (context, state) {
                    navigatedTo = '/users/${state.pathParameters['userId']}';
                    return const Scaffold(body: Text('Public Profile'));
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final nicknameFinder = find.text('TestUser');
      expect(nicknameFinder, findsOneWidget);

      await tester.tap(nicknameFinder);
      await tester.pumpAndSettle();

      expect(navigatedTo, '/users/user123');
    });

    testWidgets('anonymous post author is not tappable', (tester) async {
      final anonymousPost = Post(
        id: 'test-post-2',
        authorId: 'user456',
        authorNickname: 'Anonymous',
        isAnonymous: true,
        content: 'Anonymous test post',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likeCount: 0,
        likedBy: [],
        commentCount: 0,
        section: 'spotted',
      );

      String? navigatedTo;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => Scaffold(
                    body: PostCardWidget(
                      post: anonymousPost,
                      currentUserId: 'current-user',
                      onComments: () {},
                      onLike: () {},
                      onUnlike: () {},
                      onReport: () {},
                    ),
                  ),
                ),
                GoRoute(
                  path: '/users/:userId',
                  builder: (context, state) {
                    navigatedTo = '/users/${state.pathParameters['userId']}';
                    return const Scaffold(body: Text('Public Profile'));
                  },
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final anonymousFinder = find.text('Anonymous');
      expect(anonymousFinder, findsOneWidget);

      await tester.tap(anonymousFinder);
      await tester.pumpAndSettle();

      expect(navigatedTo, isNull);
    });

    testWidgets('author nickname has accessibility semantics for link',
        (tester) async {
      final testPost = Post(
        id: 'test-post-3',
        authorId: 'user789',
        authorNickname: 'LinkTestUser',
        isAnonymous: false,
        content: 'Test post for link semantics',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        likeCount: 0,
        likedBy: [],
        commentCount: 0,
        section: 'spotted',
      );

      final mockUserProfile = UserProfile(
        uid: 'user789',
        nickname: 'LinkTestUser',
        nicknameVerified: true,
        createdAt: DateTime.now(),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime.now(),
        trustLevel: TrustLevel.newcomer,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileByIdProvider('user789').overrideWith((ref) {
              return Stream.value(mockUserProfile);
            }),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: PostCardWidget(
                post: testPost,
                currentUserId: 'current-user',
                onComments: () {},
                onLike: () {},
                onUnlike: () {},
                onReport: () {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final semanticsFinder = find.bySemanticsLabel(
        'View profile of LinkTestUser',
      );

      expect(semanticsFinder, findsOneWidget);
    });
  });
}
