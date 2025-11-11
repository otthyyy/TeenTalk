# Trust Score System

## Overview

The Trust Score System is a reputation-based mechanism designed to aid moderation and build community trust in TeenTalk. Each user has a numerical **trust score** (0-100) and a categorical **trust level** that dynamically adjusts based on their behavior and contributions to the community.

## Trust Score Scale

Trust scores range from **0 to 100**, with the following trust level thresholds:

| Trust Score Range | Trust Level | Description |
|-------------------|-------------|-------------|
| 0 - 40 | **Newcomer** | New users or those with multiple violations |
| 41 - 65 | **Member** | Regular users with positive contributions |
| 66 - 85 | **Trusted** | Established users with consistently good behavior |
| 86 - 100 | **Veteran** | Highly trusted community members |

### Initial Score

All new users start with a trust score of **50** (Member level) to allow them to participate normally while the system learns their behavior patterns.

## Trust Score Events

The trust score automatically adjusts based on the following user actions:

### Positive Events (Increase Score)

| Event | Score Change | Description |
|-------|--------------|-------------|
| Post Created | **+2** | User creates a new post |
| Comment Created | **+1** | User adds a comment to a post |
| Valid Report (Reporter) | **+3** | User files a report that is upheld by moderators |
| Positive Engagement | **+1** | User receives likes or helpful reactions |

### Negative Events (Decrease Score)

| Event | Score Change | Description |
|-------|--------------|-------------|
| Post Auto-Hidden | **-5** | User's post is automatically hidden due to multiple reports |
| Post Removed | **-10** | Moderator removes user's post for policy violations |
| Report Upheld (Author) | **-8** | User's content is flagged and report is upheld |
| False Report | **-2** | User files a report that is dismissed |
| Blocked by User | **-1** | Another user blocks this user |

## Trust Level Benefits

Different trust levels may unlock different privileges:

- **Newcomer (0-40)**: May have additional rate limiting or moderation checks
- **Member (41-65)**: Standard community access
- **Trusted (66-85)**: May get priority in feeds, reduced moderation delays
- **Veteran (86-100)**: Potential community leadership opportunities

## Cloud Functions

### Automatic Updates

The trust score system uses Firestore triggers to automatically update scores:

1. **`onUserCreated`** - Initializes trust score for new users
2. **`onPostCreatedForTrust`** - Awards points when posts are created
3. **`onCommentCreatedForTrust`** - Awards points for comments
4. **`onPostModerated`** - Deducts points when content is flagged/hidden
5. **`onReportResolved`** - Adjusts scores based on report outcomes
6. **`onUserBlocked`** - Deducts points when user is blocked

### Callable Functions

#### `adjustTrustScore`

Allows admins to manually adjust a user's trust score.

**Auth Required**: Admin only

**Parameters**:
- `userId` (string): The ID of the user whose score to adjust
- `scoreDelta` (number): The amount to change the score (-100 to 100)
- `reason` (string): Explanation for the adjustment

**Example**:
```javascript
const result = await firebase.functions().httpsCallable('adjustTrustScore')({
  userId: 'user123',
  scoreDelta: 10,
  reason: 'Excellent community contribution'
});
```

#### `getTrustHistory`

Retrieves the trust score change history for a user.

**Auth Required**: User (own history) or Admin (any user)

**Parameters**:
- `userId` (string): The ID of the user
- `limit` (number, optional): Maximum number of history entries (default: 50)

**Returns**:
- `currentScore` (number): Current trust score
- `currentLevel` (string): Current trust level
- `history` (array): List of trust score changes with timestamps and reasons

**Example**:
```javascript
const result = await firebase.functions().httpsCallable('getTrustHistory')({
  userId: 'user123',
  limit: 20
});

console.log(result.data.currentScore); // 72
console.log(result.data.currentLevel); // "trusted"
console.log(result.data.history); // [{previousScore: 70, newScore: 72, ...}, ...]
```

#### `getTrustScoreConfig`

Returns the current trust score configuration for reference.

**Auth Required**: Any authenticated user

**Example**:
```javascript
const config = await firebase.functions().httpsCallable('getTrustScoreConfig')();
console.log(config.data.config);
```

## Data Structure

### User Document Fields

```javascript
{
  uid: "user123",
  nickname: "JohnDoe",
  trustScore: 72,        // Numeric score 0-100
  trustLevel: "trusted", // Categorical level
  // ... other fields
}
```

### Trust History Subcollection

Each user document has a `trustHistory` subcollection that logs all score changes:

```javascript
// users/{userId}/trustHistory/{historyId}
{
  previousScore: 70,
  newScore: 72,
  scoreDelta: 2,
  previousLevel: "trusted",
  newLevel: "trusted",
  reason: "post_created",
  metadata: {
    postId: "post123"
  },
  timestamp: Timestamp
}
```

## Security Rules

### Trust Score Protection

Trust scores are **read-only** for users and can only be modified by Cloud Functions or admins:

- Users **can read** their own trust score and level
- Users **cannot modify** their trust score or level
- Cloud Functions **can update** trust scores automatically
- Admins **can manually adjust** trust scores via callable functions

### Trust History Access

- Users can read their own trust history
- Admins can read any user's trust history
- Only Cloud Functions can write to trust history (system-managed)

## Implementation Details

### Score Clamping

Trust scores are always clamped to the valid range (0-100). If an event would push the score outside this range, it is automatically adjusted to the nearest boundary.

### Transactional Updates

All trust score updates use Firestore transactions to ensure consistency:
1. Read current user data
2. Calculate new score and level
3. Update user document
4. Create history entry
5. Commit transaction atomically

### Error Handling

- If a user document doesn't exist, the update is skipped with a warning
- Failed updates are logged but don't throw errors to prevent blocking other operations
- All trust score operations include detailed logging for debugging

## Testing

Trust score functions include comprehensive unit tests covering:

- Score calculation and clamping
- Trust level transitions
- Individual event score changes
- Admin functions and auth checks
- Edge cases (rapid changes, boundary conditions)

Run tests with:
```bash
cd functions
npm test
```

## Monitoring and Analytics

Trust score changes are automatically logged and can be monitored:

1. Check Cloud Functions logs for trust score updates
2. Query `trustHistory` subcollections for detailed change tracking
3. Use admin dashboard to view user trust scores and levels
4. Track aggregate trust score distribution across the community

## Best Practices

### For Moderators

1. **Review patterns**: Look for users with rapidly declining trust scores
2. **Context matters**: Check trust history to understand score changes
3. **Manual adjustments**: Use sparingly and document reasons clearly
4. **False positives**: Consider restoring points for mistakenly flagged content

### For Developers

1. **Don't expose scores prominently**: Avoid gamification of the system
2. **Use for moderation**: Trust scores should aid decisions, not dictate them
3. **Monitor thresholds**: Adjust scoring rules based on community behavior
4. **Privacy**: Trust scores are user data - handle with appropriate permissions

## Future Enhancements

Potential future improvements to the trust system:

- Dynamic scoring based on community size
- Time-decay for old violations
- Trust score influence on content visibility
- Peer endorsement system
- Integration with ML-based content moderation
- Custom scoring rules per school/community

## FAQs

### Can users see their trust score?

Yes, users can view their own trust score and trust level in their profile, along with a history of changes.

### Can trust scores be reset?

Admins can manually adjust trust scores, effectively allowing resets if needed for legitimate reasons.

### What happens at very low trust scores?

Users with very low trust scores (Newcomer level) may face additional rate limits or content moderation, but they are not automatically banned.

### How often do trust scores update?

Trust scores update in real-time as events occur (posts, comments, reports, etc.).

### Are trust scores visible to other users?

By default, trust levels (not exact scores) may be visible to help users assess content credibility, but this is configurable.

## Support

For questions or issues with the trust score system:

1. Check Cloud Functions logs for errors
2. Review trust history for specific users
3. Contact the development team for scoring adjustments
4. Submit feedback on scoring thresholds and rules
