import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/core/services/rate_limit_service.dart';

void main() {
  group('RateLimitService', () {
    late RateLimitService service;

    setUp(() {
      service = RateLimitService();
    });

    test('allows submissions when under limit', () {
      final status = service.checkLimit(ContentType.post);
      expect(status.canSubmit, isTrue);
      expect(status.remainingPerMinute, equals(5));
      expect(status.remainingPerHour, equals(20));
    });

    test('tracks submissions correctly', () {
      service.recordSubmission(ContentType.post);
      final status = service.checkLimit(ContentType.post);
      
      expect(status.canSubmit, isTrue);
      expect(status.remainingPerMinute, equals(4));
      expect(status.remainingPerHour, equals(19));
    });

    test('blocks submissions when minute limit is exceeded', () {
      for (int i = 0; i < 5; i++) {
        service.recordSubmission(ContentType.post);
      }
      
      final status = service.checkLimit(ContentType.post);
      expect(status.canSubmit, isFalse);
      expect(status.remainingPerMinute, equals(0));
      expect(status.cooldownDuration, isNotNull);
      expect(status.reason, equals('minute_limit'));
    });

    test('blocks submissions when hour limit is exceeded', () {
      for (int i = 0; i < 20; i++) {
        service.recordSubmission(ContentType.post);
      }
      
      final status = service.checkLimit(ContentType.post);
      expect(status.canSubmit, isFalse);
      expect(status.remainingPerHour, equals(0));
      expect(status.cooldownDuration, isNotNull);
      expect(status.reason, equals('hour_limit'));
    });

    test('shows near limit warning when approaching limit', () {
      for (int i = 0; i < 3; i++) {
        service.recordSubmission(ContentType.post);
      }
      
      final status = service.checkLimit(ContentType.post);
      expect(status.canSubmit, isTrue);
      expect(status.isNearLimit, isTrue);
      expect(status.remainingPerMinute, equals(2));
    });

    test('different content types have independent limits', () {
      for (int i = 0; i < 5; i++) {
        service.recordSubmission(ContentType.post);
      }
      
      final postStatus = service.checkLimit(ContentType.post);
      final commentStatus = service.checkLimit(ContentType.comment);
      
      expect(postStatus.canSubmit, isFalse);
      expect(commentStatus.canSubmit, isTrue);
      expect(commentStatus.remainingPerMinute, equals(10));
    });

    test('clears history for content type', () {
      for (int i = 0; i < 5; i++) {
        service.recordSubmission(ContentType.post);
      }
      
      expect(service.checkLimit(ContentType.post).canSubmit, isFalse);
      
      service.clearHistory(ContentType.post);
      
      final status = service.checkLimit(ContentType.post);
      expect(status.canSubmit, isTrue);
      expect(status.remainingPerMinute, equals(5));
    });

    test('gets submission count correctly', () {
      for (int i = 0; i < 3; i++) {
        service.recordSubmission(ContentType.comment);
      }
      
      final count = service.getSubmissionCount(
        ContentType.comment,
        const Duration(minutes: 1),
      );
      
      expect(count, equals(3));
    });
  });

  group('RateLimitConfig', () {
    test('post config has correct limits', () {
      expect(RateLimitConfig.post.maxPerMinute, equals(5));
      expect(RateLimitConfig.post.maxPerHour, equals(20));
    });

    test('comment config has correct limits', () {
      expect(RateLimitConfig.comment.maxPerMinute, equals(10));
      expect(RateLimitConfig.comment.maxPerHour, equals(50));
    });
  });
}
