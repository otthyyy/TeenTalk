import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/feed/presentation/pages/feed_page.dart';
import 'package:teen_talk_app/src/features/feed/presentation/pages/post_composer_page.dart';
import 'package:teen_talk_app/src/features/messages/presentation/pages/messages_page.dart';
import 'package:teen_talk_app/src/features/messages/presentation/pages/chat_screen.dart';
import 'package:teen_talk_app/src/features/profile/presentation/pages/profile_page.dart';
import 'package:teen_talk_app/src/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:teen_talk_app/src/features/offline_sync/presentation/pages/sync_queue_page.dart';
import 'package:teen_talk_app/src/features/profile/presentation/pages/public_profile_page.dart';
import 'package:teen_talk_app/src/features/admin/presentation/pages/admin_page.dart';
import 'package:teen_talk_app/src/features/admin/presentation/pages/crashlytics_test_page.dart';
import 'package:teen_talk_app/src/features/moderation/presentation/pages/moderation_queue_page.dart';
import 'package:teen_talk_app/src/features/auth/presentation/pages/auth_page.dart';
import 'package:teen_talk_app/src/features/auth/presentation/pages/signup_page.dart';
import 'package:teen_talk_app/src/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:teen_talk_app/src/features/notifications/presentation/pages/notifications_page.dart';
import 'package:teen_talk_app/src/features/beta_feedback/presentation/pages/beta_feedback_form_page.dart';
import 'package:teen_talk_app/src/features/legal/presentation/pages/legal_document_page.dart';
import 'package:teen_talk_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:teen_talk_app/src/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:teen_talk_app/src/features/tutorial/presentation/providers/tutorial_provider.dart';
import 'package:teen_talk_app/src/core/theme/decorations.dart';
import 'package:teen_talk_app/src/features/auth/presentation/pages/splash_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userProfile = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/loading',
    redirect: (context, state) {
      final isAuthLoading = authState.isLoading;
      final isAuthenticated = authState.user != null;
      final isProfileLoading = userProfile.isLoading;
      final hasProfileError = userProfile.hasError;
      final profile = userProfile.value;
      final hasProfile = profile != null;
      final hasCompletedOnboarding = profile?.onboardingComplete ?? false;
      final isProfileComplete = profile?.isProfileComplete ?? false;
      final isAdminUser = profile?.isAdmin ?? false;

      final path = state.uri.path;
      final isOnAuthPage = path == '/auth' || path == '/auth/signup';
      final isOnOnboardingPage = path == '/onboarding';
      final isOnAdminPage = path.startsWith('/admin');
      final isOnLoadingPage = path == '/loading';

      print('🔀 ROUTER REDIRECT DEBUG:');
      print('   Path: $path');
      print('   Auth: isAuthenticated=$isAuthenticated, isLoading=$isAuthLoading, uid=${authState.user?.uid}');
      print('   Profile: hasProfile=$hasProfile, isLoading=$isProfileLoading, hasError=$hasProfileError');
      print('   Profile Data: onboardingComplete=$hasCompletedOnboarding, school=${profile?.school}, interests=${profile?.interests}');

      if (isAuthLoading || isProfileLoading) {
        print('   ➡️  Redirecting to loading (auth or profile loading)');
        return isOnLoadingPage ? null : '/loading';
      }

      if (hasProfileError && isAuthenticated) {
        print('   ➡️  Redirecting to onboarding (profile error)');
        return isOnOnboardingPage ? null : '/onboarding';
      }

      if (!isAuthenticated) {
        print('   ➡️  Redirecting to auth (not authenticated)');
        return isOnAuthPage ? null : '/auth';
      }

      // Only redirect to onboarding if user hasn't completed it yet
      // Don't redirect if they've completed onboarding but profile is incomplete
      if (isAuthenticated && (!hasProfile || !hasCompletedOnboarding)) {
        print('   ➡️  Redirecting to onboarding (no profile or onboarding not complete)');
        return isOnOnboardingPage ? null : '/onboarding';
      }

      if (isOnAdminPage && !isAdminUser) {
        print('   ➡️  Redirecting to feed (non-admin accessing admin)');
        return '/feed';
      }

      if (isAuthenticated && hasProfile && hasCompletedOnboarding && (isOnAuthPage || isOnOnboardingPage || isOnLoadingPage)) {
        print('   ➡️  Redirecting to feed (authenticated and onboarded)');
        return '/feed';
      }

      print('   ✅ No redirect needed');
      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: '/auth',
        builder: (context, state) => const AuthPage(),
        routes: [
          GoRoute(
            path: 'signup',
            builder: (context, state) => const SignUpPage(),
          ),
        ],
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingPage(),
      ),
      GoRoute(
        path: '/legal/:document',
        builder: (context, state) {
          final documentSegment = state.pathParameters['document'];
          final documentType = legalDocumentTypeFromRouteSegment(documentSegment);
          if (documentType == null) {
            return const LegalDocumentUnavailablePage();
          }
          return LegalDocumentPage(documentType: documentType);
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/feed',
            builder: (context, state) {
              final openComments = state.uri.queryParameters['openComments'] == 'true';
              final postId = state.uri.queryParameters['postId'];
              return FeedPage(
                openCommentsForPost: openComments && postId != null ? postId : null,
              );
            },
            routes: [
              GoRoute(
                path: 'compose',
                builder: (context, state) => const PostComposerPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/notifications',
            builder: (context, state) => const NotificationsPage(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const MessagesPage(),
            routes: [
              GoRoute(
                path: 'chat/:conversationId/:otherUserId',
                builder: (context, state) => ChatScreen(
                  conversationId: state.pathParameters['conversationId'] ?? '',
                  otherUserId: state.pathParameters['otherUserId'] ?? '',
                  otherUserDisplayName: state.uri.queryParameters['displayName'],
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/beta-feedback',
            builder: (context, state) => const BetaFeedbackFormPage(),
          ),
          GoRoute(
             path: '/profile',
             builder: (context, state) => const ProfilePage(),
             routes: [
               GoRoute(
                 path: 'edit',
                 builder: (context, state) => const ProfileEditPage(),
               ),
               GoRoute(
                 path: 'sync-queue',
                 builder: (context, state) => const SyncQueuePage(),
               ),
             ],
           ),
          GoRoute(
            path: '/users/:userId',
            builder: (context, state) => PublicProfilePage(
              userId: state.pathParameters['userId'] ?? '',
            ),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminPage(),
            routes: [
              GoRoute(
                path: 'moderation',
                builder: (context, state) => const ModerationQueuePage(),
              ),
              GoRoute(
                path: 'crashlytics-test',
                builder: (context, state) => const CrashlyticsTestPage(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class MainNavigationShell extends ConsumerWidget {
  const MainNavigationShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userProfile = ref.watch(userProfileProvider);
    final isAdmin = userProfile.value?.isAdmin ?? false;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final tutorialAnchors = ref.watch(tutorialAnchorsProvider);

    return Container(
      decoration: AppDecorations.surfaceGradientBackground(isDark: isDark),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: child,
        extendBody: false,
        bottomNavigationBar: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: AppDecorations.glassContainer(
              isDark: isDark,
              borderRadius: 28,
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              child: BottomNavigationBar(
                currentIndex: _calculateSelectedIndex(context, isAdmin),
                onTap: (index) => _onItemTapped(index, context, isAdmin),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                items: [
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined),
                    activeIcon: Icon(Icons.home_rounded),
                    label: 'Feed',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.message_outlined,
                      key: tutorialAnchors.messagesNavKey,
                    ),
                    activeIcon: const Icon(Icons.message_rounded),
                    label: 'Messages',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(
                      Icons.person_outline,
                      key: tutorialAnchors.profileNavKey,
                    ),
                    activeIcon: const Icon(Icons.person_rounded),
                    label: 'Profile',
                  ),
                  if (isAdmin)
                    const BottomNavigationBarItem(
                      icon: Icon(Icons.admin_panel_settings_outlined),
                      activeIcon: Icon(Icons.admin_panel_settings_rounded),
                      label: 'Admin',
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context, bool isAdmin) {
    final GoRouterState state = GoRouterState.of(context);
    final String location = state.uri.toString();
    if (location.startsWith('/feed')) {
      return 0;
    } else if (location.startsWith('/messages')) {
      return 1;
    } else if (location.startsWith('/profile')) {
      return 2;
    } else if (location.startsWith('/admin') && isAdmin) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, bool isAdmin) {
    switch (index) {
      case 0:
        context.go('/feed');
        break;
      case 1:
        context.go('/messages');
        break;
      case 2:
        context.go('/profile');
        break;
      case 3:
        if (isAdmin) {
          context.go('/admin');
        }
        break;
    }
  }
}
