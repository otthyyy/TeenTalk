import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:teen_talk_app/src/core/analytics/analytics_service.dart';

class _FakeFirebaseAnalytics extends Fake implements FirebaseAnalytics {
  final List<_LoggedEvent> loggedEvents = [];

  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    loggedEvents.add(_LoggedEvent(name: name, parameters: parameters));
  }

  @override
  Future<void> setAnalyticsCollectionEnabled(bool enabled) async {}

  @override
  Future<void> setUserProperty({required String name, required String? value}) async {}
}

class _LoggedEvent {
  _LoggedEvent({required this.name, this.parameters});
  final String name;
  final Map<String, Object?>? parameters;
}

void main() {
  group('AnalyticsService', () {
    late _FakeFirebaseAnalytics fakeAnalytics;
    late AnalyticsService analyticsService;

    setUp(() {
      fakeAnalytics = _FakeFirebaseAnalytics();
      analyticsService = AnalyticsService(
        analytics: fakeAnalytics,
        logger: Logger(level: Level.nothing),
      );
    });

    test('logEvent coerces boolean parameters to 0 or 1', () async {
      await analyticsService.logEvent(
        name: 'test_event',
        parameters: {
          'is_true': true,
          'is_false': false,
        },
      );

      expect(fakeAnalytics.loggedEvents, hasLength(1));
      final event = fakeAnalytics.loggedEvents.first;
      expect(event.name, 'test_event');
      expect(event.parameters?['is_true'], 1);
      expect(event.parameters?['is_false'], 0);
    });

    test('logEvent preserves string and number parameters', () async {
      await analyticsService.logEvent(
        name: 'test_event',
        parameters: {
          'string_param': 'test_value',
          'int_param': 42,
          'double_param': 3.14,
        },
      );

      expect(fakeAnalytics.loggedEvents, hasLength(1));
      final event = fakeAnalytics.loggedEvents.first;
      expect(event.parameters?['string_param'], 'test_value');
      expect(event.parameters?['int_param'], 42);
      expect(event.parameters?['double_param'], 3.14);
    });

    test('logEvent converts null to string', () async {
      await analyticsService.logEvent(
        name: 'test_event',
        parameters: {
          'null_param': null,
        },
      );

      expect(fakeAnalytics.loggedEvents, hasLength(1));
      final event = fakeAnalytics.loggedEvents.first;
      expect(event.parameters?['null_param'], 'null');
    });

    test('logEvent handles mixed parameter types', () async {
      await analyticsService.logEvent(
        name: 'test_event',
        parameters: {
          'string': 'hello',
          'number': 123,
          'bool_true': true,
          'bool_false': false,
        },
      );

      expect(fakeAnalytics.loggedEvents, hasLength(1));
      final event = fakeAnalytics.loggedEvents.first;
      expect(event.parameters?['string'], 'hello');
      expect(event.parameters?['number'], 123);
      expect(event.parameters?['bool_true'], 1);
      expect(event.parameters?['bool_false'], 0);
    });

    test('logContentSubmission coerces isAnonymous boolean', () async {
      await analyticsService.logContentSubmission(
        contentType: 'post',
        isAnonymous: true,
      );

      expect(fakeAnalytics.loggedEvents, hasLength(1));
      final event = fakeAnalytics.loggedEvents.first;
      expect(event.name, 'content_submission');
      expect(event.parameters?['is_anonymous'], 1);
      expect(event.parameters?['content_type'], 'post');
    });

    test('logContentSubmission with false isAnonymous', () async {
      await analyticsService.logContentSubmission(
        contentType: 'comment',
        isAnonymous: false,
      );

      expect(fakeAnalytics.loggedEvents, hasLength(1));
      final event = fakeAnalytics.loggedEvents.first;
      expect(event.parameters?['is_anonymous'], 0);
    });

    test('logOnboardingCompleted coerces isMinor boolean', () async {
      await analyticsService.logOnboardingCompleted(
        school: 'Test School',
        isMinor: true,
      );

      expect(fakeAnalytics.loggedEvents, hasLength(1));
      final event = fakeAnalytics.loggedEvents.first;
      expect(event.name, 'onboarding_completed');
      expect(event.parameters?['is_minor'], 1);
      expect(event.parameters?['school'], 'Test School');
    });
  });
}
