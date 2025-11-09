import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/notifications/presentation/widgets/notification_badge.dart';
import 'package:teen_talk_app/src/features/notifications/presentation/providers/notifications_provider.dart';

void main() {
  group('NotificationBadge widget', () {
    testWidgets('displays badge when there are unread notifications', (tester) async {
      var tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unreadNotificationCountProvider.overrideWithValue(5),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: NotificationBadge(
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Badge), findsOneWidget);
      expect(find.text('5'), findsOneWidget);

      await tester.tap(find.byType(IconButton));
      expect(tapped, isTrue);
    });

    testWidgets('hides badge when there are no unread notifications', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unreadNotificationCountProvider.overrideWithValue(0),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: NotificationBadge(
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Badge), findsOneWidget);
      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);
    });

    testWidgets('shows 99+ for counts over 99', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unreadNotificationCountProvider.overrideWithValue(150),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: NotificationBadge(
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('99+'), findsOneWidget);
      expect(find.text('150'), findsNothing);
    });

    testWidgets('icon button is accessible', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            unreadNotificationCountProvider.overrideWithValue(3),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: NotificationBadge(
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.byType(IconButton), findsOneWidget);
      expect(find.byIcon(Icons.notifications_outlined), findsOneWidget);
    });
  });
}
