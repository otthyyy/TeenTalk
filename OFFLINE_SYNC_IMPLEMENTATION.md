# Offline Sync Queue Implementation

## Overview
This implementation provides offline sync functionality for posts, comments, and direct messages, allowing users to compose content offline and automatically sync when connectivity is restored.

## Architecture

### Core Components

1. **Models** (`lib/src/features/offline_sync/models/`)
   - `QueuedAction`: Represents a pending action with metadata
   - Supported types: Post, Comment, DirectMessage
   - Status tracking: Pending, Syncing, Failed, Completed

2. **Services** (`lib/src/features/offline_sync/services/`)
   - `ConnectivityService`: Monitors network status
   - `SyncQueueService`: Manages the persistent queue using Hive
   - `OfflineSubmissionHelper`: Provides easy-to-use methods for enqueueing actions

3. **UI** (`lib/src/features/offline_sync/presentation/`)
   - `SyncQueuePage`: View and manage queued items
   - `SyncStatusIndicator`: Show pending sync count in app bar

## Features Implemented

### Queue Management
- ✅ Persistent storage using Hive
- ✅ Automatic retry logic (max 3 attempts)
- ✅ Duplicate detection
- ✅ Conflict handling
- ✅ Automatic cleanup of old completed actions (7 days)

### Connectivity Monitoring
- ✅ Real-time network status monitoring
- ✅ Automatic sync trigger when online
- ✅ Periodic sync every 5 minutes
- ✅ Connection status indication

### Sync Process
- ✅ Sequential processing of queued items
- ✅ Status tracking (pending → syncing → completed/failed)
- ✅ Error handling and retry mechanism
- ✅ Graceful failure handling

### User Feedback
- ✅ Queue management page
- ✅ Sync status indicator
- ✅ Manual retry for failed items
- ✅ Manual queue clearing

## Usage

### For Posts

```dart
// Check connectivity
final helper = ref.read(offlineSubmissionHelperProvider);
final isOnline = await helper.isOnline();

if (!isOnline) {
  // Enqueue for offline sync
  await helper.enqueuePost(
    authorId: userId,
    authorNickname: nickname,
    isAnonymous: false,
    content: content,
    section: 'spotted',
    school: school,
  );
  // Show user feedback
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Post queued for sync when online')),
  );
} else {
  // Normal online submission
  await repository.createPost(...);
}
```

### For Comments

```dart
final helper = ref.read(offlineSubmissionHelperProvider);

if (!await helper.isOnline()) {
  await helper.enqueueComment(
    postId: postId,
    authorId: userId,
    authorNickname: nickname,
    isAnonymous: false,
    content: content,
    school: school,
  );
}
```

### For Direct Messages

```dart
final helper = ref.read(offlineSubmissionHelperProvider);

if (!await helper.isOnline()) {
  await helper.enqueueDirectMessage(
    senderId: senderId,
    receiverId: receiverId,
    text: text,
  );
}
```

### Accessing Queue Status

```dart
// Get pending count
final pendingCount = ref.watch(pendingQueueCountProvider);

// Get all queued actions
final actions = ref.watch(queuedActionsProvider);

// Navigate to queue page
context.push('/profile/sync-queue');
```

## Integration Points

To integrate offline sync into existing submission flows:

1. **Import the helper**:
   ```dart
   import 'package:teen_talk_app/src/features/offline_sync/services/offline_submission_helper.dart';
   ```

2. **Check connectivity before submission**:
   ```dart
   final helper = ref.read(offlineSubmissionHelperProvider);
   final isOnline = await helper.isOnline();
   ```

3. **Enqueue if offline, submit normally if online**

4. **Provide appropriate user feedback**

## Testing

### Unit Tests
Location: `test/src/features/offline_sync/models/queued_action_test.dart`

Run tests:
```bash
flutter test test/src/features/offline_sync/
```

Tests cover:
- Action creation and state transitions
- Retry logic
- Status tracking
- JSON serialization/deserialization

### Integration Testing
To test offline-to-online scenario:

1. Enable airplane mode or disable network
2. Create posts/comments/messages
3. Verify items appear in sync queue
4. Re-enable network
5. Verify automatic sync
6. Check queue clears completed items

## Configuration

### Retry Settings
Edit in `lib/src/features/offline_sync/models/queued_action.dart`:
```dart
bool get canRetry => retryCount < 3; // Max 3 retries
```

### Sync Interval
Edit in `lib/src/features/offline_sync/services/sync_queue_service.dart`:
```dart
_syncTimer = Timer.periodic(const Duration(minutes: 5), ...); // Every 5 minutes
```

### Cleanup Period
Edit in `lib/src/features/offline_sync/services/sync_queue_service.dart`:
```dart
final cutoffDate = now.subtract(const Duration(days: 7)); // 7 days
```

## Known Limitations

1. **Image uploads**: Currently not supported in offline queue (only text-based content)
2. **Order preservation**: Items sync in queue order, not creation order
3. **Post edits**: Not supported while queued
4. **Deletion conflicts**: If post/comment is deleted while queued, sync will fail

## Future Enhancements

1. Support for image uploads in queue
2. Background sync using workmanager/background_fetch
3. Conflict resolution UI
4. Queue priority levels
5. Batch sync optimization
6. User-configurable sync settings

## Dependencies

Added to `pubspec.yaml`:
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  workmanager: ^0.5.2
  background_fetch: ^1.2.4
  connectivity_plus: ^5.0.2

dev_dependencies:
  hive_generator: ^2.0.1
```

## Routes

New route added:
- `/profile/sync-queue` - Queue management page

## Providers

New providers:
- `connectivityServiceProvider` - Connectivity monitoring
- `syncQueueServiceProvider` - Queue management
- `queuedActionsProvider` - Stream of all actions
- `pendingQueueCountProvider` - Count of pending items
- `offlineSubmissionHelperProvider` - Easy submission helper

## Security Considerations

- Queue stored locally using Hive (encrypted on device)
- No sensitive data stored in queue (follows same rules as online submission)
- Queue clears automatically after successful sync
- User can manually clear queue from settings
