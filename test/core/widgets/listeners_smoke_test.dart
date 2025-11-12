import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/core/widgets/crashlytics_listener.dart';
import 'package:teen_talk_app/src/services/push_notifications_listener.dart';
import 'package:teen_talk_app/src/core/providers/crashlytics_provider.dart';
import 'package:teen_talk_app/src/services/push_notifications_provider.dart';
import 'package:teen_talk_app/src/core/services/crashlytics_service.dart';
import 'package:teen_talk_app/src/services/push_notifications_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Listeners Smoke Tests', () {
    late CrashlyticsService fakeCrashlyticsService;
    late PushNotificationsService fakePushService;

    setUp(() {
      fakeCrashlyticsService = CrashlyticsService();
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('CrashlyticsListener renders without throwing assertions',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            crashlyticsServiceProvider.overrideWithValue(fakeCrashlyticsService),
          ],
          child: const CrashlyticsListener(
            child: MaterialApp(
              home: Scaffold(
                body: Text('Test Child'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Test Child'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PushNotificationsListener renders without throwing assertions',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const PushNotificationsListener(
            child: MaterialApp(
              home: Scaffold(
                body: Text('Push Test'),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Push Test'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Both listeners work together without assertions',
        (WidgetTester tester) async {
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            crashlyticsServiceProvider.overrideWithValue(fakeCrashlyticsService),
            sharedPreferencesProvider.overrideWithValue(prefs),
          ],
          child: const CrashlyticsListener(
            child: PushNotificationsListener(
              child: MaterialApp(
                home: Scaffold(
                  body: Text('Integration Test'),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Integration Test'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
