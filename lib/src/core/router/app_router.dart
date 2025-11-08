import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/feed/presentation/pages/feed_page.dart';
import 'package:teen_talk_app/src/features/messages/presentation/pages/messages_page.dart';
import 'package:teen_talk_app/src/features/profile/presentation/pages/profile_page.dart';
import 'package:teen_talk_app/src/features/admin/presentation/pages/admin_page.dart';
import 'package:teen_talk_app/src/features/auth/presentation/pages/auth_page.dart';
import 'package:teen_talk_app/src/features/auth/presentation/providers/auth_provider.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/auth',
    redirect: (context, state) {
      final authState = ref.watch(authStateProvider);

      // Redirect unauthenticated users to auth page
      if (!authState.isAuthenticated && state.uri.path != '/auth') {
        return '/auth';
      }

      // Redirect authenticated users away from auth page
      if (authState.isAuthenticated && state.uri.path == '/auth') {
        if (authState.requiresOnboarding) {
          return '/onboarding';
        }
        return '/feed';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/auth',
        builder: (context, state) {
          final isSignUp = state.uri.queryParameters['signup'] == 'true';
          return AuthPage(isSignUp: isSignUp);
        },
      ),
      ShellRoute(
        builder: (context, state, child) {
          return MainNavigationShell(child: child);
        },
        routes: [
          GoRoute(
            path: '/feed',
            builder: (context, state) => const FeedPage(),
          ),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const MessagesPage(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfilePage(),
          ),
          GoRoute(
            path: '/admin',
            builder: (context, state) => const AdminPage(),
          ),
        ],
      ),
    ],
  );
});

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _calculateSelectedIndex(context),
        onTap: (index) => _onItemTapped(index, context),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.message_outlined),
            activeIcon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_outlined),
            activeIcon: Icon(Icons.admin_panel_settings),
            label: 'Admin',
          ),
        ],
      ),
    );
  }

  int _calculateSelectedIndex(BuildContext context) {
    final GoRouterState state = GoRouterState.of(context);
    final String location = state.uri.toString();
    if (location.startsWith('/feed')) {
      return 0;
    } else if (location.startsWith('/messages')) {
      return 1;
    } else if (location.startsWith('/profile')) {
      return 2;
    } else if (location.startsWith('/admin')) {
      return 3;
    }
    return 0;
  }

  void _onItemTapped(int index, BuildContext context) {
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
        context.go('/admin');
        break;
    }
  }
}
