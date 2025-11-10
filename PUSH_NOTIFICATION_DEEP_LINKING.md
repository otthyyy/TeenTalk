# Push Notification Deep-Linking Implementation

## Overview

This feature enables users to navigate directly to the relevant screen when tapping a push notification, regardless of app state (foreground, background, or terminated).

## Implementation Details

### Components

1. **PushNotificationHandler** (`lib/src/features/notifications/presentation/providers/push_notification_handler_provider.dart`)
   - Central handler for all push notification tap events
   - Subscribes to `FirebaseMessaging.onMessageOpenedApp` for background taps
   - Provides `handleInitialMessage()` for cold-start navigation
   - Maps notification payload types to GoRouter paths

2. **Single Post Provider** (`lib/src/features/feed/presentation/providers/single_post_provider.dart`)
   - Fetches individual posts by ID using `PostsRepository.getPostById()`
   - Validates school filters to prevent cross-school navigation
   - Returns error messages for missing/deleted posts

3. **Feed Deep-Linking** (Updated `feed_page.dart` and `feed_sections_page.dart`)
   - Accepts query parameter `openCommentsForPost` to automatically open comments drawer
   - Validates post existence and school membership before displaying
   - Shows snackbar errors for invalid posts

4. **App Initialization** (Updated `main.dart`)
   - Checks `FirebaseMessaging.getInitialMessage()` on app launch
   - Initializes PushNotificationHandler with router reference

### Notification Payload Types

#### Comment Reply / Post Mention
```json
{
  "type": "comment_reply",  // or "comment_mention", "post_mention"
  "postId": "abc123",
  "commentId": "xyz789"     // optional
}
```
**Navigation**: `/feed?openComments=true&postId=abc123`

#### Direct Message
```json
{
  "type": "direct_message",
  "conversationId": "conv-001",
  "otherUserId": "user-456",
  "displayName": "John Doe"  // optional
}
```
**Navigation**: `/messages/chat/conv-001/user-456?displayName=John+Doe`

#### Fallback
```json
{
  "type": "unknown_or_missing"
}
```
**Navigation**: `/notifications`

### Error Handling

- **Post Not Found**: Shows snackbar "Post not found or has been deleted"
- **School Mismatch**: Shows snackbar "This post is from a different school"
- **Missing Data**: Falls back to `/notifications` hub
- **Network Errors**: Shows generic error snackbar

## Testing

### Automated Tests
Run unit tests for navigation logic:
```bash
flutter test test/features/notifications/push_notification_handler_test.dart
```

### Manual QA Steps

#### 1. Cold Start (Terminated State)
1. Force-quit the app
2. Send a push notification with `type: comment_reply` and valid `postId`
3. Tap the notification
4. **Expected**: App launches and navigates directly to feed with comments drawer open
5. **Verify**: Correct post is displayed, comments are visible

#### 2. Background Tap
1. Run the app and minimize it (Home button)
2. Send a push notification with `type: direct_message` and valid `conversationId`, `otherUserId`
3. Tap the notification
4. **Expected**: App resumes and navigates to the specific chat screen
5. **Verify**: Chat conversation loads with correct partner

#### 3. Foreground (Future Enhancement)
1. Run the app with it in the foreground
2. Send a push notification
3. Tap the local notification banner (requires local notification integration)
4. **Expected**: In-app navigation to the target screen

#### 4. Missing/Deleted Post
1. Send notification with `type: comment_reply` but invalid/deleted `postId`
2. Tap the notification
3. **Expected**: Error snackbar appears: "Post not found or has been deleted"
4. **Verify**: User stays on feed, can dismiss snackbar

#### 5. School Filter
1. User A is in School 1
2. Send notification for a post from School 2 (different school)
3. Tap the notification
4. **Expected**: Error snackbar: "This post is from a different school"

#### 6. Incomplete Payload
1. Send notification with `type: comment_reply` but no `postId`
2. Tap the notification
3. **Expected**: Navigates to `/notifications` hub as fallback

#### 7. Multiple Notifications
1. Send 3 notifications rapidly (different types)
2. Tap each notification from system tray
3. **Expected**: Each tap navigates correctly, no duplicates or crashes

### Firebase Cloud Messaging Test Payload

Use Firebase Console or Cloud Functions to send test notifications:

**Comment Reply:**
```json
{
  "notification": {
    "title": "New comment reply",
    "body": "Someone replied to your comment"
  },
  "data": {
    "type": "comment_reply",
    "postId": "POST_ID_FROM_FIRESTORE",
    "commentId": "COMMENT_ID_FROM_FIRESTORE"
  }
}
```

**Direct Message:**
```json
{
  "notification": {
    "title": "New message",
    "body": "You have a new message from Alice"
  },
  "data": {
    "type": "direct_message",
    "conversationId": "CONVERSATION_ID",
    "otherUserId": "OTHER_USER_ID",
    "displayName": "Alice"
  }
}
```

## Analytics Hook (TODO)

The handler includes a placeholder for analytics logging:
```dart
// TODO: Add analytics logging here
// _logNotificationOpen(type: type, route: targetRoute);
```

To implement:
1. Create analytics service/provider
2. Log event with notification type and destination route
3. Track user engagement metrics

## Future Enhancements

1. **Local Notifications**: Integrate flutter_local_notifications to show in-app banners for foreground messages
2. **Deep-Link Comments**: Scroll directly to a specific comment when `commentId` is provided
3. **Notification Center**: Mark notifications as read when tapped
4. **Retry Logic**: Implement exponential backoff for failed post fetches
5. **Caching**: Cache recently viewed posts to improve cold-start performance

## Dependencies

- `firebase_messaging`: ^14.0.0+
- `go_router`: ^12.0.0+
- `flutter_riverpod`: ^2.4.0+

## Security Considerations

- School filter validation prevents unauthorized cross-school access
- Post existence checks prevent broken navigation states
- Error handling gracefully manages missing data without exposing internal structure

## Troubleshooting

**Issue**: Navigation doesn't work from terminated state
- Check Firebase console for `getInitialMessage()` logs
- Verify notification payload includes correct `data` field
- Ensure router is initialized before handling initial message

**Issue**: Comments drawer doesn't open automatically
- Verify query parameter `openComments=true&postId=...` in URL
- Check `_handleDeepLinkToPost` logs in FeedSectionsPage
- Ensure `singlePostWithSchoolCheckProvider` completes successfully

**Issue**: School filter blocks valid posts
- Verify user's profile has `school` field populated
- Check post's `school` field in Firestore
- Review `singlePostWithSchoolCheckProvider` logic for edge cases
