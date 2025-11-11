import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:teen_talk_app/src/features/notifications/data/models/app_notification.dart';
import 'package:teen_talk_app/src/features/notifications/presentation/widgets/notification_card.dart';
import 'package:teen_talk_app/src/features/notifications/presentation/providers/notifications_provider.dart';
import '../helpers/golden_test_helper.dart';

class _MockNotificationActions extends NotificationsActions {
  _MockNotificationActions() : super(null as Ref);

  @override
  Future<void> markAsRead(String notificationId) async {}
}

void main() {
  setUpAll(() async {
    await loadTestFonts();
  });

  group('NotificationCard widget golden tests', () {
    final now = DateTime(2024, 1, 15, 14, 30);

    final commentMention = AppNotification(
      id: 'notif-1',
      userId: 'user-1',
      type: NotificationType.commentMention,
      title: 'You were mentioned',
      body: '@TestUser mentioned you in a comment',
      data: const {'postId': 'post-1', 'commentId': 'comment-1'},
      createdAt: now.subtract(const Duration(minutes: 10)),
      read: false,
    );

    final commentReply = AppNotification(
      id: 'notif-2',
      userId: 'user-1',
      type: NotificationType.commentReply,
      title: 'New reply',
      body: 'Someone replied to your comment',
      data: const {'postId': 'post-2', 'commentId': 'comment-2'},
      createdAt: now.subtract(const Duration(hours: 2)),
      read: false,
    );

    final postMention = AppNotification(
      id: 'notif-3',
      userId: 'user-1',
      type: NotificationType.postMention,
      title: 'Mentioned in post',
      body: 'You were mentioned in a post by @PopularUser',
      data: const {'postId': 'post-3'},
      createdAt: now.subtract(const Duration(days: 1)),
      read: true,
    );

    final general = AppNotification(
      id: 'notif-4',
      userId: 'user-1',
      type: NotificationType.general,
      title: 'System Update',
      body: 'New features have been added to the app!',
      data: const {},
      createdAt: now.subtract(const Duration(days: 3)),
      read: true,
    );

    Widget buildNotificationCard(
      AppNotification notification, {
      ThemeMode theme = ThemeMode.light,
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
          notificationsActionsProvider.overrideWithValue(_MockNotificationActions()),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: theme,
          home: Scaffold(
            backgroundColor: theme == ThemeMode.dark
                ? darkTheme.colorScheme.surface
                : lightTheme.colorScheme.surface,
            body: Center(
              child: NotificationCard(notification: notification),
            ),
          ),
        ),
      );
    }

    testGoldens('notification card variants - light theme', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'comment mention unread',
          buildNotificationCard(commentMention),
        )
        ..addScenario(
          'comment reply',
          buildNotificationCard(commentReply),
        )
        ..addScenario(
          'post mention read',
          buildNotificationCard(postMention),
        )
        ..addScenario(
          'general notification',
          buildNotificationCard(general),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(460, 800),
      );

      await screenMatchesGolden(tester, 'notification_card/notification_variants_light');
    });

    testGoldens('notification card variants - dark theme', (tester) async {
      final builder = GoldenBuilder.column()
        ..addScenario(
          'comment mention unread',
          buildNotificationCard(commentMention, theme: ThemeMode.dark),
        )
        ..addScenario(
          'comment reply',
          buildNotificationCard(commentReply, theme: ThemeMode.dark),
        )
        ..addScenario(
          'post mention read',
          buildNotificationCard(postMention, theme: ThemeMode.dark),
        )
        ..addScenario(
          'general notification',
          buildNotificationCard(general, theme: ThemeMode.dark),
        );

      await tester.pumpWidgetBuilder(
        builder.build(),
        surfaceSize: const Size(460, 800),
      );

      await screenMatchesGolden(tester, 'notification_card/notification_variants_dark');
    });

    testGoldens('notification card tablet layout', (tester) async {
      await tester.pumpWidgetBuilder(
        buildNotificationCard(commentMention),
        surfaceSize: const Size(840, 200),
      );

      await screenMatchesGolden(tester, 'notification_card/notification_tablet');
    });
  });
}
