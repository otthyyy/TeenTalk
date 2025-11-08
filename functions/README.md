# TeenTalk Cloud Functions

This directory contains all Cloud Functions for the TeenTalk Firebase backend.

## Structure

```
functions/
├── src/
│   ├── index.ts                    # Main entry point, exports all functions
│   ├── functions/
│   │   ├── nicknameValidation.ts   # Nickname uniqueness validation
│   │   ├── postCounters.ts         # Post likes/comments counter maintenance
│   │   ├── commentCounters.ts      # Comment likes counter maintenance
│   │   ├── moderationQueue.ts      # Moderation workflow
│   │   ├── pushNotifications.ts    # Push notification dispatch
│   │   └── dataCleanup.ts          # Scheduled cleanup tasks
│   └── index.test.ts               # Function tests
├── package.json                    # Dependencies and scripts
├── tsconfig.json                   # TypeScript configuration
├── .eslintrc.js                    # Linting rules
└── README.md                       # This file
```

## Setup

### Prerequisites

- Node.js 18+
- npm or yarn
- Firebase CLI
- Active Firebase project

### Installation

```bash
cd functions
npm install
```

## Development

### Build TypeScript

```bash
npm run build
```

### Run Linter

```bash
npm run lint
```

### Run Tests

```bash
npm test
```

### Watch Mode (Development)

```bash
npm run lint -- --watch
```

## Deployment

### Deploy to Production

```bash
firebase deploy --only functions
```

### Deploy Specific Function

```bash
firebase deploy --only functions:validateNicknameUniqueness
```

### View Deployment Logs

```bash
firebase functions:log
```

## Function Reference

### Nickname Validation

#### `validateNicknameUniqueness`
- **Type**: HTTPS Callable
- **Auth Required**: Yes
- **Input**: `{ nickname: string }`
- **Output**: `{ unique: boolean, message: string }`
- **Description**: Validates if a nickname is available for registration

**Example Usage**:
```dart
final functionsService = FunctionsService();
final result = await functionsService.callFunction<Map<String, dynamic>>(
  'validateNicknameUniqueness',
  parameters: {'nickname': 'testuser'},
);
print(result['unique']); // true or false
```

### Post Counters

#### `syncPostCounts` (HTTPS Callable)
- **Auth Required**: Yes
- **Input**: `{ postId: string }`
- **Output**: `{ success: boolean, commentCount: number, likeCount: number }`
- **Description**: Synchronizes comment and like counts from subcollections

**Example Usage**:
```dart
final result = await functionsService.callFunction<Map<String, dynamic>>(
  'syncPostCounts',
  parameters: {'postId': 'post123'},
);
```

### Comment Counters

#### `syncCommentCounts` (HTTPS Callable)
- **Auth Required**: Yes
- **Input**: `{ postId: string, commentId: string }`
- **Output**: `{ success: boolean, likeCount: number }`
- **Description**: Synchronizes comment like counts

### Moderation Queue

#### `processModerationAction` (HTTPS Callable)
- **Auth Required**: Yes (admin only in production)
- **Input**: `{ reportId: string, action: "approve"|"reject"|"delete", reason?: string }`
- **Output**: `{ success: boolean, message: string }`
- **Description**: Processes moderation actions on reported posts

**Example Usage**:
```dart
final result = await functionsService.callFunction<Map<String, dynamic>>(
  'processModerationAction',
  parameters: {
    'reportId': 'report123',
    'action': 'approve',
    'reason': 'Violates community guidelines',
  },
);
```

#### `getPendingModerations` (HTTPS Callable)
- **Auth Required**: Yes (admin only)
- **Input**: `{ limit?: number, offset?: number }`
- **Output**: `{ items: ModerationItem[], count: number }`
- **Description**: Retrieves pending moderation items

### Push Notifications

#### `registerFCMToken` (HTTPS Callable)
- **Auth Required**: Yes
- **Input**: `{ token: string }`
- **Output**: `{ success: boolean, message: string }`
- **Description**: Registers device token for push notifications

#### `unregisterFCMToken` (HTTPS Callable)
- **Auth Required**: Yes
- **Input**: `{ token: string }`
- **Output**: `{ success: boolean, message: string }`
- **Description**: Unregisters device token

### Health Check

#### `healthCheck` (HTTPS Callable)
- **Auth Required**: Yes
- **Output**: `{ status: "healthy", timestamp: Timestamp, userId: string }`
- **Description**: Simple health check endpoint for monitoring

## Testing

### Run All Tests

```bash
npm test
```

### Run Specific Test Suite

```bash
npm test -- --grep "nicknameValidation"
```

### Test Coverage

```bash
npm test -- --coverage
```

## Monitoring

### View Function Logs

```bash
firebase functions:log
```

### View Real-time Logs

```bash
firebase functions:log -f
```

### Monitor Specific Function

```bash
firebase functions:log --only validateNicknameUniqueness
```

### View Function Details

```bash
gcloud functions describe validateNicknameUniqueness --region us-central1
```

## Environment Variables

For production deployments, set environment variables:

```bash
firebase functions:config:set custom.api_key="YOUR_KEY"
firebase functions:config:get
firebase deploy --only functions
```

## Scheduled Functions

The following functions run on a schedule:

| Function | Schedule | Purpose |
|----------|----------|---------|
| cleanupOldNotifications | Daily 2 AM UTC | Delete notifications > 30 days |
| cleanupOldModerationItems | Daily 3 AM UTC | Delete resolved reports > 90 days |
| cleanupTemporaryUploads | Every 6 hours | Clean draft uploads > 1 day |
| generateUsageStatistics | Weekly Sunday 4 AM UTC | Generate usage statistics |

## Troubleshooting

### Function Not Triggering

1. Check if function is deployed: `firebase functions:list`
2. Verify the event matches the trigger
3. Check function logs: `firebase functions:log -f`
4. Ensure Cloud Functions API is enabled in GCP

### Permission Errors

1. Check service account has proper permissions
2. Verify `firebaseConfig` is correct
3. Ensure user is authenticated for callable functions
4. Check admin SDK initialization

### Cold Start Issues

- Cold starts are normal for serverless functions
- Functions warm up after first invocation
- Consider keeping functions warm with periodic health checks

## Best Practices

1. **Error Handling**: Always wrap database operations in try-catch
2. **Input Validation**: Validate all function parameters
3. **Logging**: Use console logging for debugging
4. **Performance**: Use batch operations for multiple writes
5. **Security**: Never trust client input, validate in functions
6. **Testing**: Write tests for all new functions
7. **Deployment**: Test in emulator before production deployment

## Contributing

When adding new functions:

1. Create a new file in `src/functions/`
2. Export function from `src/index.ts`
3. Add comprehensive tests to `src/index.test.ts`
4. Update this README with function documentation
5. Ensure code passes linting and tests
6. Create pull request with clear description

## Related Documentation

- [Security Rules Deployment Guide](../SECURITY_RULES_DEPLOYMENT.md)
- [Firestore Security Rules](../firestore.rules)
- [Storage Rules](../storage.rules)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Cloud Functions Documentation](https://cloud.google.com/functions/docs)

## Support

For issues or questions:
1. Check Firebase documentation
2. Review function logs: `firebase functions:log`
3. Test in emulator first
4. Contact the development team

---

**Version**: 1.0  
**Last Updated**: 2024  
**Maintained By**: TeenTalk Development Team
