import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final Logger _logger = Logger();
  
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      _logger.i('Logged event: $name');
    } catch (e) {
      _logger.e('Failed to log event $name: $e');
    }
  }

  Future<void> logTrustBadgeTap(String trustLevel, String location) async {
    await logEvent(
      name: 'trust_badge_tap',
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
      name: 'rate_limit_hit',
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
      name: 'rate_limit_warning',
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
      name: 'content_submission',
      parameters: {
        'content_type': contentType,
        'is_anonymous': isAnonymous,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }
  
  Future<void> logLowTrustWarning(String userId, String context) async {
    await logEvent(
      name: 'low_trust_warning',
      parameters: {
        'user_id': userId,
        'context': context,
      },
    );
  }

  Future<void> logLowTrustWarningDismiss(String userId, String context) async {
    await logEvent(
      name: 'low_trust_warning_dismiss',
      parameters: {
        'user_id': userId,
        'context': context,
      },
    );
  }

  Future<void> logLowTrustWarningProceed(String userId, String context) async {
    await logEvent(
      name: 'low_trust_warning_proceed',
      parameters: {
        'user_id': userId,
        'context': context,
      },
    );
  }
}
