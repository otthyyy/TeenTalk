import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;
  final Logger _logger = Logger();
  
  Future<void> logRateLimitHit({
    required String contentType,
    required String limitType,
    required int submissionCount,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'rate_limit_hit',
        parameters: {
          'content_type': contentType,
          'limit_type': limitType,
          'submission_count': submissionCount,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      _logger.i('Logged rate limit hit: $contentType, $limitType');
    } catch (e) {
      _logger.e('Failed to log rate limit hit: $e');
    }
  }
  
  Future<void> logRateLimitWarning({
    required String contentType,
    required int remainingSubmissions,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'rate_limit_warning',
        parameters: {
          'content_type': contentType,
          'remaining_submissions': remainingSubmissions,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
      _logger.i('Logged rate limit warning: $contentType, remaining: $remainingSubmissions');
    } catch (e) {
      _logger.e('Failed to log rate limit warning: $e');
    }
  }
  
  Future<void> logContentSubmission({
    required String contentType,
    required bool isAnonymous,
  }) async {
    try {
      await _analytics.logEvent(
        name: 'content_submission',
        parameters: {
          'content_type': contentType,
          'is_anonymous': isAnonymous,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      _logger.e('Failed to log content submission: $e');
    }
  }
}
