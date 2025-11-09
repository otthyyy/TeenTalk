import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/feed/presentation/pages/feed_page.dart';
import 'package:teen_talk_app/src/features/feed/presentation/pages/post_composer_page.dart';
import 'package:teen_talk_app/src/features/messages/presentation/pages/messages_page.dart';
import 'package:teen_talk_app/src/features/messages/presentation/pages/chat_screen.dart';
import 'package:teen_talk_app/src/features/profile/presentation/pages/profile_page.dart';
import 'package:teen_talk_app/src/features/profile/presentation/pages/profile_edit_page.dart';
import 'package:teen_talk_app/src/features/admin/presentation/pages/admin_page.dart';
import 'package:teen_talk_app/src/features/moderation/presentation/pages/moderation_queue_page.dart';
import 'package:teen_talk_app/src/features/auth/presentation/pages/auth_page.dart';
import 'package:teen_talk_app/src/features/auth/presentation/pages/signup_page.dart';
import 'package:teen_talk_app/src/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:teen_talk_app/src/features/notifications/presentation/pages/notifications_page.dart';
import 'package:teen_talk_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:teen_talk_app/src/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:teen_talk_app/src/core/theme/decorations.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  final userProfile = ref.watch(userProfileProvider);

  return GoRouter(
    initialLocation: '/feed',
    redirect: (context, state) {
      final isAuthLoading = authState.isLoading;
      final isAuthenticated = authState.user != null;
      final isProfileLoading = userProfile.isLoading;
      final profile = userProfile.value;
      final hasProfile = profile != null;
      final isProfileComplete = profile?.isProfileComplete ?? false;
      final isAdminUser = profile?.isAdmin ?? false;

      final path = state.uri.path;
      final isOnAuthPage = path == '/auth' || path == '/auth/signup';
      final isOnOnboardingPage = path == '/onboarding';
      final isOnAdminPage = path.startsWith('/admin');

      if (isAuthLoading || isProfileLoading) {
        return null;
      }

      if (!isAuthenticated) {
        return isOnAuthPage ? null : '/auth';
      }

      if (isAuthenticated && (!hasProfile || !isProfileComplete)) {
        return isOnOnboardingPage ? null : '/onboarding';
      }

      if (isOnAdminPage && !isAdminUser) {
        return '/feed';
      }

      if (isAuthenticated && hasProfile && isProfileComplete && (isOnAuthPage || isOnOnboardingPage)) {
        return '/feed';
      }

      return null;
    },
    routes: [
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
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/feed',
            builder: (context, state) => const FeedPage(),
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
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
            routes: [
              GoRoute(
                path: 'edit',
                builder: (context, state) => const ProfileEditPage(),
              ),
            ],
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminPage(),
            routes: [
              GoRoute(
                path: 'moderation',
                builder: (context, state) => const ModerationQueuePage(),
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
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.message_outlined),
                    activeIcon: Icon(Icons.message_rounded),
                    label: 'Messages',
                  ),
                  const BottomNavigationBarItem(
                    icon: Icon(Icons.person_outline),
                    activeIcon: Icon(Icons.person_rounded),
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
