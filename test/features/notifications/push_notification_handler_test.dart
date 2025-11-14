import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:teen_talk_app/src/features/notifications/presentation/providers/push_notification_handler_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('PushNotificationHandler navigation', () {
    late PushNotificationHandler handler;
    late GoRouter router;

    setUp(() {
      handler = PushNotificationHandler();

      router = GoRouter(
        routes: [
          GoRoute(path: '/', builder: (context, state) => const SizedBox()),
          GoRoute(path: '/feed', builder: (context, state) => const SizedBox()),
          GoRoute(path: '/notifications', builder: (context, state) => const SizedBox()),
          GoRoute(
            path: '/messages',
            builder: (context, state) => const SizedBox(),
            routes: [
              GoRoute(
                path: 'chat/:conversationId/:otherUserId',
                builder: (context, state) => const SizedBox(),
              ),
            ],
          ),
        ],
        initialLocation: '/',
        navigatorKey: GlobalKey<NavigatorState>(),
      );

      handler.initialize(router);
    });

    tearDown(() {
      handler.dispose();
      router.dispose();
    });

    testWidgets('navigates to feed comments for comment notification', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      handler.handleForegroundNotificationTap({
        'type': 'comment_reply',
        'postId': 'post-123',
      });

      await tester.pumpAndSettle();

      expect(router.location, '/feed?openComments=true&postId=post-123');
    });

    testWidgets('navigates to feed comments for post mention', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      handler.handleForegroundNotificationTap({
        'type': 'post_mention',
        'postId': 'post-456',
      });

      await tester.pumpAndSettle();

      expect(router.location, '/feed?openComments=true&postId=post-456');
    });

    testWidgets('navigates to chat for direct message notification', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      handler.handleForegroundNotificationTap({
        'type': 'direct_message',
        'conversationId': 'conv-001',
        'otherUserId': 'user-456',
      });

      await tester.pumpAndSettle();

      expect(router.location, '/messages/chat/conv-001/user-456');
    });

    testWidgets('falls back to notifications when post ID missing', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      handler.handleForegroundNotificationTap({
        'type': 'comment_reply',
      });

      await tester.pumpAndSettle();

      expect(router.location, '/notifications');
    });

    testWidgets('falls back to messages when conversation ID missing', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      handler.handleForegroundNotificationTap({
        'type': 'direct_message',
        'otherUserId': 'user-123',
      });

      await tester.pumpAndSettle();

      expect(router.location, '/messages');
    });

    testWidgets('falls back to notifications for unknown type', (tester) async {
      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      handler.handleForegroundNotificationTap({
        'type': 'unknown_type',
      });

      await tester.pumpAndSettle();

      expect(router.location, '/notifications');
    });
  });
}

