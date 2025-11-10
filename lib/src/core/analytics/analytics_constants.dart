/// Analytics event names and parameters constants
/// Use these constants instead of string literals to ensure consistency
class AnalyticsEvents {
  // Auth & Onboarding Events
  static const String signUp = 'sign_up';
  static const String signIn = 'sign_in';
  static const String signOut = 'sign_out';
  static const String onboardingStarted = 'onboarding_started';
  static const String onboardingCompleted = 'onboarding_completed';
  static const String onboardingStepCompleted = 'onboarding_step_completed';

  // Feed Events
  static const String feedSectionChanged = 'feed_section_changed';
  static const String feedRefreshed = 'feed_refreshed';
  static const String postViewed = 'post_viewed';
  static const String postLiked = 'post_liked';
  static const String postUnliked = 'post_unliked';

  // Post Creation Events
  static const String postCreationStarted = 'post_creation_started';
  static const String postCreated = 'post_created';
  static const String postCreationCancelled = 'post_creation_cancelled';

  // Comment Events
  static const String commentCreated = 'comment_created';
  static const String commentsViewed = 'comments_viewed';

  // Moderation Events
  static const String contentReported = 'content_reported';
  static const String userBlocked = 'user_blocked';
  static const String userUnblocked = 'user_unblocked';

  // Notification Events
  static const String notificationOpened = 'notification_opened';
  static const String notificationReceived = 'notification_received';
  static const String notificationSettingsChanged = 'notification_settings_changed';

  // Share Events
  static const String contentShared = 'content_shared';

  // Search Events (for future implementation)
  static const String searchPerformed = 'search_performed';
  static const String searchResultClicked = 'search_result_clicked';

  // Profile Events
  static const String profileViewed = 'profile_viewed';
  static const String profileEdited = 'profile_edited';

  // Privacy Events
  static const String privacySettingsChanged = 'privacy_settings_changed';
  static const String analyticsOptedOut = 'analytics_opted_out';
  static const String analyticsOptedIn = 'analytics_opted_in';
}

class AnalyticsParameters {
  // User Context Parameters (non-PII)
  static const String school = 'school';
  static const String isMinor = 'is_minor';
  static const String hasParentalConsent = 'has_parental_consent';
  static const String isAdmin = 'is_admin';
  static const String isModerator = 'is_moderator';

  // Content Parameters
  static const String contentType = 'content_type';
  static const String contentId = 'content_id';
  static const String postSection = 'post_section';
  static const String isAnonymous = 'is_anonymous';

  // Interaction Parameters
  static const String method = 'method';
  static const String source = 'source';
  static const String destination = 'destination';
  static const String success = 'success';
  static const String errorMessage = 'error_message';

  // Onboarding Parameters
  static const String stepNumber = 'step_number';
  static const String stepName = 'step_name';

  // Feed Parameters
  static const String section = 'section';
  static const String previousSection = 'previous_section';

  // Report Parameters
  static const String reportReason = 'report_reason';
  static const String reportedContentType = 'reported_content_type';

  // Notification Parameters
  static const String notificationType = 'notification_type';
  static const String actionTaken = 'action_taken';

  // Search Parameters
  static const String searchQuery = 'search_query';
  static const String resultCount = 'result_count';

  // Share Parameters
  static const String shareMethod = 'share_method';
  static const String shareDestination = 'share_destination';
}

class AnalyticsContentTypes {
  static const String post = 'post';
  static const String comment = 'comment';
  static const String profile = 'profile';
  static const String notification = 'notification';
}

class AnalyticsSections {
  static const String spotted = 'spotted';
  static const String general = 'general';
}

class AnalyticsAuthMethods {
  static const String email = 'email';
  static const String phone = 'phone';
  static const String google = 'google';
  static const String anonymous = 'anonymous';
}
