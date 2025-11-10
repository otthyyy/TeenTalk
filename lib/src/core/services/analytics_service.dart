import 'package:flutter/foundation.dart';

class AnalyticsService {
  void logEvent(String eventName, {Map<String, dynamic>? parameters}) {
    if (kDebugMode) {
      print('[Analytics] Event: $eventName, Parameters: $parameters');
    }
  }

  void logTrustBadgeView(String trustLevel, String location) {
    logEvent(
      'trust_badge_view',
      parameters: {
        'trust_level': trustLevel,
        'location': location,
      },
    );
  }

  void logTrustBadgeTap(String trustLevel, String location) {
    logEvent(
      'trust_badge_tap',
      parameters: {
        'trust_level': trustLevel,
        'location': location,
      },
    );
  }

  void logLowTrustWarning(String userId, String context) {
    logEvent(
      'low_trust_warning',
      parameters: {
        'user_id': userId,
        'context': context,
      },
    );
  }

  void logLowTrustWarningDismiss(String userId, String context) {
    logEvent(
      'low_trust_warning_dismiss',
      parameters: {
        'user_id': userId,
        'context': context,
      },
    );
  }

  void logLowTrustWarningProceed(String userId, String context) {
    logEvent(
      'low_trust_warning_proceed',
      parameters: {
        'user_id': userId,
        'context': context,
      },
    );
  }
}
