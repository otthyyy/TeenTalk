# Rate Limiting Implementation

## Overview
This document outlines the comprehensive rate limiting system implemented for the Teen Talk app to prevent abuse and maintain platform quality.

## Features

### 1. **Per-User Rate Limits**
- **Posts**: 50 per day
- **Comments**: 30 per hour  
- **Messages**: 100 per hour

### 2. **Trust Score System**
- Users start with a trust score of 1.0
- Each rate limit violation decreases trust score by 0.1
- Users with trust score ≤ 0.3 are flagged for moderation
- Trust score affects automated moderation decisions

### 3. **Automatic Enforcement**
- Firestore Security Rules prevent writes when limits are exceeded
- Cloud Functions track usage and update counters in real-time
- Automated flagging of repeat offenders

### 4. **Admin Controls**
- View rate limit metrics across all users
- Reset rate limits for specific users
- Review flagged users in moderation queue

## Architecture

### Cloud Functions (`functions/src/functions/rateLimits.ts`)

#### Callable Functions

**`checkRateLimit(data, context)`**
- Called before creating content to verify user is within limits
- Parameters: `{contentType: 'post' | 'comment' | 'message'}`
- Returns: `{allowed: boolean, currentCount: number, limit: number, resetAt: string, trustScore: number, errorCode?: string}`

**`getRateLimitStatus(data, context)`**
- Get current rate limit status for authenticated user
- Returns counters and limits for all content types

**`getRateLimitMetrics(data, context)`**
- Admin-only function to get system-wide metrics
- Returns: total users, violations, low trust users, flagged users

**`resetUserRateLimits(data, context)`**
- Admin-only function to reset a user's rate limits
- Parameters: `{targetUserId: string}`

#### Firestore Triggers

**`onPostCreatedRateLimit`**
- Triggered when a post is created
- Increments post counter
- Checks for violations
- Flags users exceeding limits

**`onCommentCreatedRateLimit`**
- Triggered when a comment is created
- Increments comment counter
- Checks for violations

**`onMessageCreatedRateLimit`**
- Triggered when a message is created
- Increments message counter
- Checks for violations

### Firestore Security Rules

Rate limit checks are enforced at the database level using helper functions:

```javascript
function canCreatePost() {
  let rateLimitDoc = getRateLimitDoc();
  if (rateLimitDoc == null || !rateLimitDoc.exists) {
    return false;
  }
  
  let limit = rateLimitDoc.data.postLimit != null ? rateLimitDoc.data.postLimit : 50;
  let count = rateLimitDoc.data.postsToday != null ? rateLimitDoc.data.postsToday : 0;
  let resetAt = rateLimitDoc.data.resetPostsAt;
  
  if (resetAt.toMillis() <= request.time.toMillis()) {
    return true;  // Counter expired, allow
  }
  
  return count < limit;
}
```

Similar functions exist for comments (`canCreateComment`) and messages (`canSendMessage`).

## Data Structure

### Rate Limits Collection (`rateLimits/{userId}`)

```typescript
{
  userId: string;
  
  // Counters
  postsToday: number;
  commentsThisHour: number;
  messagesThisHour: number;
  
  // Reset timestamps
  resetPostsAt: Timestamp;      // Next midnight
  resetCommentsAt: Timestamp;   // Next hour boundary
  resetMessagesAt: Timestamp;   // Next hour boundary
  
  // Trust and violations
  violationCount: number;
  lastViolationAt: Timestamp;
  trustScore: number;           // 0.0 to 1.0
  
  // Metadata
  updatedAt: Timestamp;
  
  // Optional admin overrides
  postLimit?: number;           // Default: 50
  commentLimit?: number;        // Default: 30
  messageLimit?: number;        // Default: 100
}
```

## Error Codes

The system exposes specific error codes for client handling:

- `rate-limit-exceeded-posts`: User has exceeded daily post limit
- `rate-limit-exceeded-comments`: User has exceeded hourly comment limit
- `rate-limit-exceeded-messages`: User has exceeded hourly message limit

## Client Integration

### Checking Rate Limits Before Creating Content

```dart
final functions = FirebaseFunctions.instance;

try {
  final result = await functions
      .httpsCallable('checkRateLimit')
      .call({'contentType': 'post'});
  
  final data = result.data as Map<String, dynamic>;
  
  if (data['allowed'] == true) {
    // Proceed with post creation
    await createPost(...);
  } else {
    // Show error message to user
    final errorCode = data['errorCode'] as String;
    final resetAt = DateTime.parse(data['resetAt'] as String);
    
    showRateLimitError(errorCode, resetAt);
  }
} catch (e) {
  // Handle error
  print('Rate limit check failed: $e');
}
```

### Getting User's Rate Limit Status

```dart
final result = await functions
    .httpsCallable('getRateLimitStatus')
    .call();

final data = result.data as Map<String, dynamic>;

// Display to user
final posts = data['posts'] as Map<String, dynamic>;
print('Posts today: ${posts['count']}/${posts['limit']}');

final comments = data['comments'] as Map<String, dynamic>;
print('Comments this hour: ${comments['count']}/${comments['limit']}');

final messages = data['messages'] as Map<String, dynamic>;
print('Messages this hour: ${messages['count']}/${messages['limit']}');

final trustScore = data['trustScore'] as double;
print('Trust score: $trustScore');
```

### Handling Rate Limit Errors

```dart
void showRateLimitError(String errorCode, DateTime resetAt) {
  String message;
  
  switch (errorCode) {
    case 'rate-limit-exceeded-posts':
      message = 'You have reached the daily limit of 50 posts. '
                'Try again after ${formatTime(resetAt)}.';
      break;
    case 'rate-limit-exceeded-comments':
      message = 'You have reached the hourly limit of 30 comments. '
                'Try again after ${formatTime(resetAt)}.';
      break;
    case 'rate-limit-exceeded-messages':
      message = 'You have reached the hourly limit of 100 messages. '
                'Try again after ${formatTime(resetAt)}.';
      break;
    default:
      message = 'Rate limit exceeded. Please try again later.';
  }
  
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Rate Limit Reached'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('OK'),
        ),
      ],
    ),
  );
}
```

## Admin Dashboard Integration

### View Rate Limit Metrics

```dart
// Admin-only
final result = await functions
    .httpsCallable('getRateLimitMetrics')
    .call();

final data = result.data as Map<String, dynamic>;

print('Total users tracked: ${data['totalUsers']}');
print('Total violations: ${data['totalViolations']}');
print('Low trust users: ${data['lowTrustUsers']}');
print('Flagged users: ${data['flaggedUsers']}');

final limits = data['limits'] as Map<String, dynamic>;
print('Posts per day: ${limits['postsPerDay']}');
print('Comments per hour: ${limits['commentsPerHour']}');
print('Messages per hour: ${limits['messagesPerHour']}');
```

### Reset User Rate Limits

```dart
// Admin-only
await functions
    .httpsCallable('resetUserRateLimits')
    .call({'targetUserId': userId});

showMessage('Rate limits reset for user $userId');
```

## Moderation Integration

### Automatic Flagging

When a user violates rate limits repeatedly, they are automatically flagged in the moderation queue:

1. Trust score drops below 0.3, OR
2. Violation count reaches 3 or more

The system creates a moderation queue item:
```typescript
{
  contentId: userId,
  contentType: 'user',
  authorId: userId,
  reportCount: violationCount,
  status: 'flagged',
  reason: 'Repeated rate limit violations',
  trustScore: currentTrustScore,
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### User Record Updates

When flagged, the user's document is updated:
```typescript
{
  flaggedForReview: true,
  flagReason: 'repeated_rate_limit_violations',
  violationCount: number,
  trustScore: number,
  flaggedAt: Timestamp
}
```

## Testing

### Emulator Tests

Run the comprehensive test suite:
```bash
cd functions
npm test -- --grep "Rate Limit"
```

Tests cover:
- Rate limit document creation
- Post, comment, and message limits
- Counter resets
- Trust score calculations
- Violation tracking
- Counter increments

### Manual Testing

1. **Test Post Limits**
   - Create 50 posts in a day
   - Attempt 51st post - should fail with error code
   - Wait until midnight - counter should reset

2. **Test Comment Limits**
   - Create 30 comments in an hour
   - Attempt 31st comment - should fail
   - Wait 1 hour - counter should reset

3. **Test Message Limits**
   - Send 100 messages in an hour
   - Attempt 101st message - should fail
   - Wait 1 hour - counter should reset

4. **Test Violations**
   - Exceed limits multiple times
   - Check trust score decreases
   - Verify user is flagged after 3 violations

5. **Test Admin Controls**
   - View metrics as admin
   - Reset user's rate limits
   - Verify counters are cleared

## Configuration

### Adjusting Limits

To adjust rate limits, update the constants in `functions/src/functions/rateLimits.ts`:

```typescript
const RATE_LIMITS = {
  POSTS_PER_DAY: 50,        // Change daily post limit
  COMMENTS_PER_HOUR: 30,    // Change hourly comment limit
  MESSAGES_PER_HOUR: 100,   // Change hourly message limit
  
  LOW_TRUST_THRESHOLD: 0.3, // Trust score threshold for flagging
  REPEATED_VIOLATION_COUNT: 3, // Number of violations before flagging
};
```

After changes, redeploy functions:
```bash
firebase deploy --only functions
```

### Per-User Overrides

Admins can set custom limits for specific users by updating the rate limit document:

```typescript
await admin.firestore()
  .collection('rateLimits')
  .doc(userId)
  .update({
    postLimit: 100,      // Custom daily post limit
    commentLimit: 50,    // Custom hourly comment limit
    messageLimit: 200,   // Custom hourly message limit
  });
```

## Monitoring

### Cloud Function Logs

Monitor rate limit enforcement:
```bash
firebase functions:log --only rateLimits
```

Key log messages:
- `Rate limit violation for user {userId} ({contentType})`
- `User {userId} flagged for moderation`
- `Rate limits reset for user {userId} by admin {adminId}`

### Firestore Metrics

Track in Firestore console:
- `rateLimits` collection size (number of active users)
- `moderationQueue` items with `contentType: 'user'`
- User documents with `flaggedForReview: true`

## Security Considerations

1. **Rate limit documents are system-only**: Users cannot modify their own limits
2. **Security rules enforce limits**: Even if functions fail, rules prevent abuse
3. **Admin actions are logged**: All resets and overrides are tracked
4. **Trust scores are immutable to users**: Only functions can update scores

## Deployment Checklist

- [ ] Deploy Cloud Functions: `firebase deploy --only functions`
- [ ] Deploy Security Rules: `firebase deploy --only firestore:rules`
- [ ] Update client code to handle error codes
- [ ] Add rate limit status UI components
- [ ] Train moderators on flagged user review
- [ ] Set up monitoring and alerts
- [ ] Test all three content types (posts, comments, messages)
- [ ] Verify admin controls work
- [ ] Document limits in user guidelines

## Future Enhancements

1. **Dynamic Limits**: Adjust limits based on user trust score
2. **Grace Period**: First-time violations get warnings instead of penalties
3. **Appeal System**: Allow users to request limit resets
4. **Analytics Dashboard**: Visualize rate limit trends over time
5. **Machine Learning**: Predict abusive users before violations
6. **Temporary Bans**: Auto-suspend accounts with severe violations
7. **Graduated Penalties**: Increasing penalties for repeat offenders

## Support

For issues or questions:
- Check Cloud Function logs for errors
- Verify Firestore security rules are deployed
- Ensure rate limit documents exist for active users
- Review moderation queue for flagged users
- Contact admin team for limit adjustments
