# Push Notifications Implementation

This document describes the implementation of push notifications for the TeenTalk app using Firebase Cloud Messaging (FCM).

## Overview

The push notifications feature enables the app to send real-time notifications to users for:
- New comments on their posts
- Likes on their posts
- Direct messages
- Follows and mentions
- System notifications

## Architecture

### Core Components

1. **PushNotificationsService** (`lib/src/services/push_notifications_service.dart`)
   - Main service handling FCM operations
   - Manages token registration/unregistration via Cloud Functions
   - Handles foreground notification display using flutter_local_notifications
   - Stores last-sent token locally to avoid redundant registrations
   - Listens to token refresh events

2. **PushNotificationsProvider** (`lib/src/services/push_notifications_provider.dart`)
   - Riverpod provider exposing the service
   - Manages SharedPreferences provider for local storage

3. **PushNotificationsController** (`lib/src/services/push_notifications_controller.dart`)
   - Wires push notifications to authentication events
   - Refreshes tokens on sign-in
   - Clears tokens on sign-out

4. **NotificationPreferences Model** (`lib/src/services/models/notification_preferences.dart`)
   - Data model for user notification preferences
   - Stored at `users/{uid}/preferences/notifications` in Firestore
   - Includes toggles for different notification types

### Backend Integration

The service integrates with two Cloud Functions:
- `registerFCMToken`: Registers a device token in Firestore under the user document
- `unregisterFCMToken`: Removes a device token from the user document

The Cloud Functions are already implemented and handle:
- Comment notifications (`onCommentNotification`)
- Like notifications (`onPostLikeNotification`)
- Direct message notifications (`onDirectMessageNotification`)

## Configuration

### Dependencies Added

```yaml
flutter_local_notifications: ^17.1.2
```

### Android Configuration

**AndroidManifest.xml**:
- Added `POST_NOTIFICATIONS` permission for Android 13+
- Added FCM default channel metadata

### iOS Configuration

**Info.plist**:
- Added `NSUserNotificationsUsageDescription` permission

**AppDelegate.swift**:
- Set `UNUserNotificationCenter.current().delegate` to self
- Register for remote notifications

### Web Configuration

**firebase-messaging-sw.js**:
- Service worker for handling background messages on web
- Configured with Firebase project credentials

## Features

### Permission Handling
- Requests notification permissions on first launch after sign-in
- Graceful fallback if permission is denied
- Supports iOS and Android permission models

### Token Management
- Retrieves FCM token on initialization
- Stores token locally to avoid redundant API calls
- Automatically syncs token changes via `onTokenRefresh`
- Unregisters old tokens when new ones are received
- Clears tokens on sign-out

### Foreground Notifications
- Uses flutter_local_notifications to display in-app banners
- Styled with Android notification channels
- Supports iOS notification presentation
- Includes title, body, and custom payload

### Background/Terminated Handling
- Background message handler in main.dart
- Logs message details for debugging
- Can be extended for background processing

### Message Opened Handling
- Handles notification taps with payload data
- Logs notification type for routing
- Ready for navigation integration

## Notification Flow

### User Sign-In
1. User authenticates
2. PushNotificationsController detects auth state change
3. Service requests notification permissions
4. Service retrieves FCM token
5. Token is registered via `registerFCMToken` Cloud Function
6. Token stored in Firestore at `users/{uid}/fcmTokens` (array)

### Token Refresh
1. FCM triggers token refresh (e.g., app reinstall)
2. `onTokenRefresh` listener catches new token
3. Old token unregistered via `unregisterFCMToken`
4. New token registered via `registerFCMToken`
5. Only new token remains in Firestore

### Receiving Notifications

**Foreground**:
1. FCM delivers message while app is open
2. `onMessage` listener receives message
3. flutter_local_notifications displays styled banner
4. User can tap to open (handled by `onNotificationTapped`)

**Background**:
1. FCM delivers message while app is in background
2. `_firebaseMessagingBackgroundHandler` processes message
3. System displays notification
4. User taps notification
5. `onMessageOpenedApp` handles the tap with payload

**Terminated**:
1. FCM delivers message while app is closed
2. System displays notification
3. User taps notification
4. App launches and `getInitialMessage` retrieves the message
5. Navigation can be triggered based on payload

### User Sign-Out
1. User signs out
2. PushNotificationsController detects auth state change
3. Service retrieves stored token
4. Token unregistered via `unregisterFCMToken`
5. Token removed from Firestore
6. Local token deleted from device

## Localization

- Italian locale support added to main.dart
- Notification permission descriptions in Italian and English
- Ready for additional language support

## Testing

### Manual Testing Steps

1. **Permission Request**:
   - Install app and sign in
   - Verify permission prompt appears
   - Grant permission and verify in device settings

2. **Token Registration**:
   - Check Firestore after sign-in
   - Verify `fcmTokens` array exists under `users/{uid}`
   - Verify token is present in array

3. **Foreground Notification**:
   - Send test notification via Firebase Console
   - Verify notification banner appears while app is open
   - Tap notification and verify log output

4. **Background Notification**:
   - Send test notification via Firebase Console
   - Background the app
   - Verify notification appears in notification tray
   - Tap notification and verify app opens

5. **Token Refresh**:
   - Uninstall and reinstall app
   - Sign in again
   - Verify new token in Firestore
   - Verify old token was removed

6. **Sign-Out**:
   - Sign out of app
   - Check Firestore
   - Verify `fcmTokens` array is empty or token removed

### Using Firebase Cloud Messaging Test

In Firebase Console:
1. Go to Cloud Messaging
2. Send test message
3. Add device FCM token
4. Verify delivery on device

### Using Cloud Functions

Trigger notifications by:
- Adding a comment to a post
- Liking a post
- Sending a direct message

Verify notifications are received on other user's device.

## Future Enhancements

1. **Navigation on Tap**:
   - Parse notification payload
   - Navigate to specific screens (post, conversation, etc.)
   - Requires integration with app router

2. **Notification Preferences UI**:
   - Settings page for notification toggles
   - Per-type notification controls
   - Quiet hours / Do Not Disturb

3. **Rich Notifications**:
   - Images in notifications
   - Action buttons (reply, like, etc.)
   - Grouped notifications

4. **Analytics**:
   - Track notification delivery rates
   - Measure notification engagement
   - A/B test notification content

## Troubleshooting

### Token Not Registered
- Check user authentication state
- Verify Cloud Functions are deployed
- Check Firestore security rules allow token writes
- Review service logs for errors

### Notifications Not Received
- Verify device has internet connection
- Check notification permissions in device settings
- Verify FCM token is valid and in Firestore
- Test with Firebase Console first

### Foreground Display Issues
- Check flutter_local_notifications initialization
- Verify Android channel is created
- Check iOS notification presentation permissions

### Background Handler Issues
- Ensure handler is top-level function
- Check background execution limits
- Review platform-specific background restrictions

## References

- [Firebase Cloud Messaging Documentation](https://firebase.google.com/docs/cloud-messaging)
- [flutter_local_notifications Package](https://pub.dev/packages/flutter_local_notifications)
- [FlutterFire Messaging Documentation](https://firebase.flutter.dev/docs/messaging/overview)
