import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:logger/logger.dart';
import 'analytics_constants.dart';

/// Analytics service that wraps Firebase Analytics
/// Provides methods to log events with consistent naming and parameters
/// Ensures no PII is logged and respects user privacy preferences
class AnalyticsService {
  final FirebaseAnalytics _analytics;
  final Logger _logger;
  bool _isEnabled = true;

  AnalyticsService({
    FirebaseAnalytics? analytics,
    Logger? logger,
  })  : _analytics = analytics ?? FirebaseAnalytics.instance,
        _logger = logger ?? Logger();

  /// Enable or disable analytics collection
  Future<void> setEnabled(bool enabled) async {
    _isEnabled = enabled;
    await _analytics.setAnalyticsCollectionEnabled(enabled);
    _logger.i('Analytics collection ${enabled ? 'enabled' : 'disabled'}');
  }

  bool get isEnabled => _isEnabled;

  /// Set user properties (non-PII only)
  Future<void> setUserProperties({
    String? school,
    bool? isMinor,
    bool? hasParentalConsent,
    bool? isAdmin,
    bool? isModerator,
  }) async {
    if (!_isEnabled) return;

    try {
      if (school != null) {
        await _analytics.setUserProperty(
          name: AnalyticsParameters.school,
          value: school,
        );
      }
      if (isMinor != null) {
        await _analytics.setUserProperty(
          name: AnalyticsParameters.isMinor,
          value: isMinor.toString(),
        );
      }
      if (hasParentalConsent != null) {
        await _analytics.setUserProperty(
          name: AnalyticsParameters.hasParentalConsent,
          value: hasParentalConsent.toString(),
        );
      }
      if (isAdmin != null) {
        await _analytics.setUserProperty(
          name: AnalyticsParameters.isAdmin,
          value: isAdmin.toString(),
        );
      }
      if (isModerator != null) {
        await _analytics.setUserProperty(
          name: AnalyticsParameters.isModerator,
          value: isModerator.toString(),
        );
      }
    } catch (e) {
      _logger.e('Error setting user properties: $e');
    }
  }

  /// Clear user properties on sign out
  Future<void> clearUserProperties() async {
    if (!_isEnabled) return;

    try {
      await _analytics.setUserProperty(name: AnalyticsParameters.school, value: null);
      await _analytics.setUserProperty(name: AnalyticsParameters.isMinor, value: null);
      await _analytics.setUserProperty(name: AnalyticsParameters.hasParentalConsent, value: null);
      await _analytics.setUserProperty(name: AnalyticsParameters.isAdmin, value: null);
      await _analytics.setUserProperty(name: AnalyticsParameters.isModerator, value: null);
    } catch (e) {
      _logger.e('Error clearing user properties: $e');
    }
  }

  /// Log a generic event with parameters
  Future<void> logEvent({
    required String name,
    Map<String, dynamic>? parameters,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logEvent(
        name: name,
        parameters: parameters,
      );
      _logger.d('Analytics event logged: $name with parameters: $parameters');
    } catch (e) {
      _logger.e('Error logging event $name: $e');
    }
  }

  // Auth & Onboarding Events

  Future<void> logSignUp(String method) async {
    await logEvent(
      name: AnalyticsEvents.signUp,
      parameters: {
        AnalyticsParameters.method: method,
      },
    );
  }

  Future<void> logSignIn(String method) async {
    await logEvent(
      name: AnalyticsEvents.signIn,
      parameters: {
        AnalyticsParameters.method: method,
      },
    );
  }

  Future<void> logSignOut() async {
    await logEvent(name: AnalyticsEvents.signOut);
    await clearUserProperties();
  }

  Future<void> logOnboardingStarted() async {
    await logEvent(name: AnalyticsEvents.onboardingStarted);
  }

  Future<void> logOnboardingCompleted({
    required String school,
    required bool isMinor,
  }) async {
    await logEvent(
      name: AnalyticsEvents.onboardingCompleted,
      parameters: {
        AnalyticsParameters.school: school,
        AnalyticsParameters.isMinor: isMinor,
      },
    );
  }

  Future<void> logOnboardingStepCompleted({
    required int stepNumber,
    required String stepName,
  }) async {
    await logEvent(
      name: AnalyticsEvents.onboardingStepCompleted,
      parameters: {
        AnalyticsParameters.stepNumber: stepNumber,
        AnalyticsParameters.stepName: stepName,
      },
    );
  }

  // Feed Events

  Future<void> logFeedSectionChanged({
    required String section,
    String? previousSection,
  }) async {
    await logEvent(
      name: AnalyticsEvents.feedSectionChanged,
      parameters: {
        AnalyticsParameters.section: section,
        if (previousSection != null)
          AnalyticsParameters.previousSection: previousSection,
      },
    );
  }

  Future<void> logFeedRefreshed(String section) async {
    await logEvent(
      name: AnalyticsEvents.feedRefreshed,
      parameters: {
        AnalyticsParameters.section: section,
      },
    );
  }

  Future<void> logPostViewed({
    required String postId,
    required String section,
    required bool isAnonymous,
  }) async {
    await logEvent(
      name: AnalyticsEvents.postViewed,
      parameters: {
        AnalyticsParameters.contentId: postId,
        AnalyticsParameters.postSection: section,
        AnalyticsParameters.isAnonymous: isAnonymous,
      },
    );
  }

  Future<void> logPostLiked({
    required String postId,
    required String section,
  }) async {
    await logEvent(
      name: AnalyticsEvents.postLiked,
      parameters: {
        AnalyticsParameters.contentId: postId,
        AnalyticsParameters.postSection: section,
      },
    );
  }

  Future<void> logPostUnliked({
    required String postId,
    required String section,
  }) async {
    await logEvent(
      name: AnalyticsEvents.postUnliked,
      parameters: {
        AnalyticsParameters.contentId: postId,
        AnalyticsParameters.postSection: section,
      },
    );
  }

  // Post Creation Events

  Future<void> logPostCreationStarted(String section) async {
    await logEvent(
      name: AnalyticsEvents.postCreationStarted,
      parameters: {
        AnalyticsParameters.postSection: section,
      },
    );
  }

  Future<void> logPostCreated({
    required String postId,
    required String section,
    required bool isAnonymous,
  }) async {
    await logEvent(
      name: AnalyticsEvents.postCreated,
      parameters: {
        AnalyticsParameters.contentId: postId,
        AnalyticsParameters.postSection: section,
        AnalyticsParameters.isAnonymous: isAnonymous,
      },
    );
  }

  Future<void> logPostCreationCancelled(String section) async {
    await logEvent(
      name: AnalyticsEvents.postCreationCancelled,
      parameters: {
        AnalyticsParameters.postSection: section,
      },
    );
  }

  // Comment Events

  Future<void> logCommentCreated({
    required String postId,
    required String commentId,
  }) async {
    await logEvent(
      name: AnalyticsEvents.commentCreated,
      parameters: {
        AnalyticsParameters.contentId: commentId,
        'post_id': postId,
      },
    );
  }

  Future<void> logCommentsViewed(String postId) async {
    await logEvent(
      name: AnalyticsEvents.commentsViewed,
      parameters: {
        'post_id': postId,
      },
    );
  }

  // Moderation Events

  Future<void> logContentReported({
    required String contentId,
    required String contentType,
    required String reason,
  }) async {
    await logEvent(
      name: AnalyticsEvents.contentReported,
      parameters: {
        AnalyticsParameters.contentId: contentId,
        AnalyticsParameters.reportedContentType: contentType,
        AnalyticsParameters.reportReason: reason,
      },
    );
  }

  Future<void> logUserBlocked(String blockedUserId) async {
    await logEvent(
      name: AnalyticsEvents.userBlocked,
      parameters: {
        'blocked_user_id': blockedUserId,
      },
    );
  }

  Future<void> logUserUnblocked(String unblockedUserId) async {
    await logEvent(
      name: AnalyticsEvents.userUnblocked,
      parameters: {
        'unblocked_user_id': unblockedUserId,
      },
    );
  }

  // Notification Events

  Future<void> logNotificationOpened({
    required String notificationType,
    String? actionTaken,
  }) async {
    await logEvent(
      name: AnalyticsEvents.notificationOpened,
      parameters: {
        AnalyticsParameters.notificationType: notificationType,
        if (actionTaken != null) AnalyticsParameters.actionTaken: actionTaken,
      },
    );
  }

  Future<void> logNotificationReceived(String notificationType) async {
    await logEvent(
      name: AnalyticsEvents.notificationReceived,
      parameters: {
        AnalyticsParameters.notificationType: notificationType,
      },
    );
  }

  Future<void> logNotificationSettingsChanged({
    required String setting,
    required bool enabled,
  }) async {
    await logEvent(
      name: AnalyticsEvents.notificationSettingsChanged,
      parameters: {
        'setting': setting,
        'enabled': enabled,
      },
    );
  }

  // Share Events

  Future<void> logContentShared({
    required String contentId,
    required String contentType,
    String? shareMethod,
  }) async {
    await logEvent(
      name: AnalyticsEvents.contentShared,
      parameters: {
        AnalyticsParameters.contentId: contentId,
        AnalyticsParameters.contentType: contentType,
        if (shareMethod != null) AnalyticsParameters.shareMethod: shareMethod,
      },
    );
  }

  // Search Events

  Future<void> logSearchPerformed({
    required String query,
    required int resultCount,
  }) async {
    await logEvent(
      name: AnalyticsEvents.searchPerformed,
      parameters: {
        AnalyticsParameters.searchQuery: query,
        AnalyticsParameters.resultCount: resultCount,
      },
    );
  }

  Future<void> logSearchResultClicked({
    required String query,
    required String resultId,
    required String resultType,
  }) async {
    await logEvent(
      name: AnalyticsEvents.searchResultClicked,
      parameters: {
        AnalyticsParameters.searchQuery: query,
        AnalyticsParameters.contentId: resultId,
        AnalyticsParameters.contentType: resultType,
      },
    );
  }

  // Profile Events

  Future<void> logProfileViewed(String profileId) async {
    await logEvent(
      name: AnalyticsEvents.profileViewed,
      parameters: {
        'profile_id': profileId,
      },
    );
  }

  Future<void> logProfileEdited() async {
    await logEvent(name: AnalyticsEvents.profileEdited);
  }

  // Privacy Events

  Future<void> logPrivacySettingsChanged(String settingName) async {
    await logEvent(
      name: AnalyticsEvents.privacySettingsChanged,
      parameters: {
        'setting_name': settingName,
      },
    );
  }

  Future<void> logAnalyticsOptedOut() async {
    await logEvent(name: AnalyticsEvents.analyticsOptedOut);
    await setEnabled(false);
  }

  Future<void> logAnalyticsOptedIn() async {
    await setEnabled(true);
    await logEvent(name: AnalyticsEvents.analyticsOptedIn);
  }

  /// Set screen name for Firebase Analytics
  Future<void> setCurrentScreen({
    required String screenName,
    String? screenClass,
  }) async {
    if (!_isEnabled) return;

    try {
      await _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );
    } catch (e) {
      _logger.e('Error setting screen: $e');
    }
  }

  // Rate Limiting Events
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
      },
    );
  }

  // Trust Level Events
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

  Future<void> logTrustBadgeTap(String trustLevel) async {
    await logEvent(
      name: 'trust_badge_tap',
      parameters: {
        'trust_level': trustLevel,
      },
    );
  }
}
