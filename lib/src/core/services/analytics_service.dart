import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final Logger _logger = Logger();
  
  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    try {
      await _analytics.logEvent(
        name: eventName,
        parameters: parameters,
      );
      _logger.i('Logged event: $eventName');
    } catch (e) {
      _logger.e('Failed to log event $eventName: $e');
    }
  }

  Future<void> logTrustBadgeTap(String trustLevel, String location) async {
    await logEvent(
      'trust_badge_tap',
      parameters: {
        'trust_level': trustLevel,
        'location': location,
      },
    );
  }
  
  Future<void> logRateLimitHit({
    required String contentType,
    required String limitType,
    required int submissionCount,
  }) async {
    await logEvent(
      'rate_limit_hit',
      parameters: {
        'content_type': contentType,
        'limit_type': limitType,
        'submission_count': submissionCount,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  Future<void> logRateLimitWarning({
    required String contentType,
    required int remainingSubmissions,
  }) async {
    await logEvent(
      'rate_limit_warning',
      parameters: {
        'content_type': contentType,
        'remaining_submissions': remainingSubmissions,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  Future<void> logContentSubmission({
    required String contentType,
    required bool isAnonymous,
  }) async {
    await logEvent(
      'content_submission',
      parameters: {
        'content_type': contentType,
        'is_anonymous': isAnonymous,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
}
