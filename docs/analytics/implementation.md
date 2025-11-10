# Analytics Implementation Guide

## Overview

This document describes how to instrument analytics throughout the TeenTalk app using the `AnalyticsService` and Riverpod providers.

## Quick Start

### 1. Import the Analytics Service

```dart
import 'package:teen_talk_app/src/core/analytics/analytics_provider.dart';
import 'package:teen_talk_app/src/core/analytics/analytics_constants.dart';
```

### 2. Use in a ConsumerWidget

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsService = ref.read(analyticsServiceProvider);
    
    // Log an event
    onPressed: () {
      analyticsService.logPostCreated(
        postId: 'post123',
        section: 'spotted',
        isAnonymous: false,
      );
    }
  }
}
```

### 3. Use Event Constants

Always use constants from `AnalyticsConstants` to ensure consistency:

```dart
// ✅ CORRECT
analyticsService.logEvent(
  name: AnalyticsEvents.postCreated,
  parameters: {
    AnalyticsParameters.section: AnalyticsSections.spotted,
  },
);

// ❌ WRONG - Don't use string literals
analyticsService.logEvent(
  name: 'post_created',
  parameters: {'section': 'spotted'},
);
```

## Common Instrumentation Patterns

### Feed Interactions

```dart
// Feed section changed
void _onSectionChanged(FeedSection section) {
  ref.read(analyticsServiceProvider).logFeedSectionChanged(
    section: section.value,
    previousSection: _selectedSection.value,
  );
  setState(() => _selectedSection = section);
}

// Post liked
void _onLikePost(String postId, String section) {
  ref.read(analyticsServiceProvider).logPostLiked(
    postId: postId,
    section: section,
  );
}

// Feed refreshed
void _onRefresh() async {
  ref.read(analyticsServiceProvider).logFeedRefreshed(_selectedSection.value);
  await _loadPosts();
}
```

### Post Creation

```dart
// Post creation started
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.read(analyticsServiceProvider).logPostCreationStarted(_section);
  });
}

// Post created successfully
Future<void> _submitPost() async {
  final postId = await _repository.createPost(...);
  
  await ref.read(analyticsServiceProvider).logPostCreated(
    postId: postId,
    section: _section,
    isAnonymous: _isAnonymous,
  );
}

// Post creation cancelled
@override
void dispose() {
  if (!_posted) {
    ref.read(analyticsServiceProvider).logPostCreationCancelled(_section);
  }
  super.dispose();
}
```

### Comments

```dart
// Comments opened
void _onOpenComments(String postId) {
  ref.read(analyticsServiceProvider).logCommentsViewed(postId);
  _navigateToComments(postId);
}

// Comment created
Future<void> _submitComment() async {
  final commentId = await _repository.createComment(...);
  
  await ref.read(analyticsServiceProvider).logCommentCreated(
    postId: _postId,
    commentId: commentId,
  );
}
```

### Moderation

```dart
// Report content
Future<void> _reportPost(Post post) async {
  await ref.read(analyticsServiceProvider).logContentReported(
    contentId: post.id,
    contentType: AnalyticsContentTypes.post,
    reason: _selectedReason.toString(),
  );
  
  await _submitReport();
}

// Block user
Future<void> _blockUser(String userId) async {
  await ref.read(analyticsServiceProvider).logUserBlocked(userId);
  await _repository.blockUser(userId);
}
```

### Notifications

```dart
// Notification opened
void _onNotificationTap(AppNotification notification) {
  ref.read(analyticsServiceProvider).logNotificationOpened(
    notificationType: notification.type,
    actionTaken: 'open',
  );
  
  _handleNotificationAction(notification);
}

// Notification received (in messaging handler)
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  await FirebaseAnalytics.instance.logEvent(
    name: AnalyticsEvents.notificationReceived,
    parameters: {
      AnalyticsParameters.notificationType: message.data['type'],
    },
  );
}
```

### Profile

```dart
// Profile viewed
void _onViewProfile(String profileId) {
  ref.read(analyticsServiceProvider).logProfileViewed(profileId);
  context.push('/profile/$profileId');
}

// Profile edited
Future<void> _saveProfile() async {
  await _repository.updateProfile(...);
  await ref.read(analyticsServiceProvider).logProfileEdited();
}
```

## Privacy Considerations

### What to Log ✅
- User IDs (anonymized by Firebase)
- School names (contextual, not personal)
- Trust levels (is_minor, has_parental_consent)
- Feature usage (sections, actions)
- Content IDs (post/comment IDs)

### What NOT to Log ❌
- Email addresses
- Phone numbers
- Real names
- Exact locations
- Message content
- Images

### User Control

Users can opt out of analytics during onboarding or in privacy settings:

```dart
// Check if analytics is enabled
final analyticsEnabled = ref.watch(analyticsPreferencesProvider);

// Toggle analytics
Future<void> _toggleAnalytics(bool enabled) async {
  if (enabled) {
    await ref.read(analyticsPreferencesProvider.notifier).optIn();
  } else {
    await ref.read(analyticsPreferencesProvider.notifier).optOut();
  }
}
```

## Setting User Properties

Set user properties once after authentication or profile updates:

```dart
Future<void> _onUserProfileLoaded(UserProfile profile) async {
  await ref.read(analyticsServiceProvider).setUserProperties(
    school: profile.school,
    isMinor: profile.isMinor,
    hasParentalConsent: profile.parentalConsentGiven,
    isAdmin: profile.isAdmin,
    isModerator: profile.isModerator,
  );
}
```

## Testing

### Mock Analytics in Tests

```dart
final mockAnalytics = MockAnalyticsService();
when(mockAnalytics.logPostCreated(any, any, any)).thenAnswer((_) async => {});

await tester.pumpWidget(
  ProviderScope(
    overrides: [
      analyticsServiceProvider.overrideWithValue(mockAnalytics),
    ],
    child: MyApp(),
  ),
);

// Verify analytics was called
verify(mockAnalytics.logPostCreated(
  postId: any,
  section: 'spotted',
  isAnonymous: false,
)).called(1);
```

### Debug View

Monitor events in real-time using Firebase's DebugView:

1. Enable debug mode:
   ```bash
   # iOS
   adb shell setprop debug.firebase.analytics.app YOUR_PACKAGE_NAME
   
   # Android  
   adb shell setprop debug.firebase.analytics.app YOUR_PACKAGE_NAME
   ```

2. Open Firebase Console → Analytics → DebugView
3. Interact with the app and watch events appear in real-time

## Best Practices

1. **Always use constants** - Never use string literals for event names or parameters
2. **Log at the right time** - Log when the action completes, not when it starts
3. **Keep it simple** - Don't over-parameterize events
4. **Test thoroughly** - Verify events fire in DebugView before deploying
5. **Respect privacy** - Double-check that no PII is being logged
6. **Handle errors** - Analytics failures should never crash the app
7. **Document new events** - Update `events.md` when adding new events

## Troubleshooting

### Events not appearing in Firebase Console?
- Check that analytics is enabled in `FirebaseBootstrap`
- Verify user has not opted out
- Events can take up to 24 hours to appear in reports (use DebugView for real-time)

### Analytics disabled in debug mode?
- By default, analytics is disabled in debug builds
- Enable for testing: `FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(true)`

### Getting compile errors?
- Ensure all imports are correct
- Check that constants match the defined names in `analytics_constants.dart`
- Verify Riverpod providers are properly scoped

## Resources

- [Firebase Analytics Documentation](https://firebase.google.com/docs/analytics)
- [Event Reference](./events.md) - Complete list of tracked events
- [Privacy Policy](../privacy_policy.md) - Our privacy commitments to users
