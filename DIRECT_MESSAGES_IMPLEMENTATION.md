# Direct Messages Implementation

This document describes the Direct Messages (DM) feature implementation for TeenTalk.

## Overview

The Direct Messages feature allows users to:
- Start conversations with other users once they are friends
- Exchange text messages with real-time updates
- See read/unread status for messages
- Block users to prevent unwanted messages
- Receive push notifications for new messages
- Manage friends and friend requests to gate conversations

## Data Structure

### Firestore Collections

#### Friend Requests Collection
```
friendRequests/{requestId}
├── senderId: string (required)
├── receiverId: string (required)
├── status: string (pending | accepted | rejected | cancelled)
├── createdAt: timestamp (required)
├── respondedAt: timestamp (optional)
└── conversationId: string (optional, populated on acceptance)
```

#### Friends Collection
```
friends/{userId}/list/{friendId}
├── conversationId: string (required)
└── createdAt: timestamp (required)
```

#### Conversations Collection
```
conversations/{conversationId}
├── userId1: string (required)
├── userId2: string (required)
├── participantIds: array<string> (required)
├── lastMessageId: string (optional)
├── lastMessage: string (optional)
├── lastSenderId: string (optional)
├── lastMessageTime: timestamp (optional)
├── unreadCount: number (required, default: 0)
├── unreadCounts: map<string, number> (optional)
├── createdAt: timestamp (required)
├── updatedAt: timestamp (optional)
└── messages/ (subcollection)
    └── {messageId}
        ├── conversationId: string (required)
        ├── senderId: string (required)
        ├── receiverId: string (required)
        ├── text: string (required)
        ├── imageUrl: string (optional)
        ├── isRead: boolean (required, default: false)
        ├── createdAt: timestamp (required)
        └── readAt: timestamp (optional)

blocks/{userId}
└── blockedUsers/ (subcollection)
    └── {blockedUserId}
        ├── blockedUserId: string (required)
        └── createdAt: timestamp (required)
```

## Conversation IDs

Conversation IDs are generated deterministically from user IDs to ensure consistency:
```dart
String _generateConversationId(String userId1, String userId2) {
  final ids = [userId1, userId2]..sort();
  return '${ids[0]}_${ids[1]}';
}
```

This ensures that a conversation between user A and user B always has the same ID, regardless of who initiates the conversation.

## Privacy Controls

### Friends System

Users must be accepted friends before they can message each other:

1. **Send Friend Request**: Creates a pending request document in `friendRequests`
2. **Accept Request**: Updates request status, creates friend entries for both users, and creates a conversation
3. **Reject Request**: Updates request status to rejected
4. **Cancel Request**: Sender can cancel pending requests

### Blocking Users

Users can block other users to prevent receiving messages:

1. **Block User**: Creates a document in `blocks/{userId}/blockedUsers/{blockedUserId}`
2. **Unblock User**: Deletes the blocking document
3. **Check Block Status**: Queries the blocking collection

### Message Sending Restrictions

When sending a message:
1. **Check Friendship**: Verify users are friends before allowing messages
2. Check if the sender is blocked by the receiver
3. If not friends or blocked, throw an exception and prevent the message from being sent
4. Only authenticated users can send messages

## Security Rules

Firestore Security Rules enforce:

1. **Authentication**: Only authenticated users can access DMs
2. **Privacy**: Users can only read their own conversations
3. **Message Permissions**: Only conversation participants can view messages
4. **Write Restrictions**: Only the message sender can write messages
5. **Block Management**: Only the blocker can manage their own block list
6. **Friend Requests**: Only senders/receivers can read requests; only the sender can cancel and the receiver can accept/reject
7. **Friends List**: Only the user can read their friends list
8. **Friends-Only Messaging**: Conversations require existing friend entries for both participants

## Features

### 1. Send Message
```dart
await repository.sendMessage(
  senderId: 'user1',
  receiverId: 'user2',
  text: 'Hello!',
  imageUrl: null, // optional
);
```

Creates:
- A conversation if it doesn't exist
- A message document
- Updates the conversation's last message metadata

### 2. Real-time Message Updates
```dart
Stream<List<DirectMessage>> messages = 
  repository.watchMessages(conversationId);
```

Returns messages in chronological order (oldest first) with real-time updates via Firestore snapshots.

### 3. Read Receipts
```dart
// Mark single message as read
await repository.markMessageAsRead(conversationId, messageId);

// Mark all messages in conversation as read
await repository.markConversationAsRead(conversationId);
```

Updates the `isRead` flag and sets `readAt` timestamp.

### 4. Block Management
```dart
// Block a user
await repository.blockUser(blockerId, blockedUserId);

// Unblock a user
await repository.unblockUser(blockerId, blockedUserId);

// Check if blocked
bool isBlocked = await repository.isUserBlocked(blockerId, userId);

// Get blocked users list
List<String> blocked = await repository.getBlockedUsers(userId);
```

### 5. Conversation Management
```dart
// Get conversation list (real-time)
Stream<List<Conversation>> conversations = 
  repository.watchConversations(userId);

// Get single conversation
Conversation? conv = await repository.getConversation(user1, user2);

// Delete conversation
await repository.deleteConversation(conversationId);

// Get unread count
int unreadCount = await repository.getUnreadCount(userId);
```

## State Management (Riverpod)

### Providers

#### `currentUserIdProvider`
State provider for the current user's ID. Must be initialized from auth state.

```dart
ref.read(currentUserIdProvider.notifier).state = userId;
```

#### `conversationsProvider`
Stream provider that watches conversations for the current user.

```dart
final conversations = ref.watch(conversationsProvider);
```

#### `messagesProvider(conversationId)`
Family stream provider that watches messages for a specific conversation.

```dart
final messages = ref.watch(messagesProvider(conversationId));
```

#### `blockedUsersProvider`
Future provider that gets the list of blocked users.

```dart
final blocked = ref.watch(blockedUsersProvider);
```

#### `unreadCountProvider`
Future provider that gets the total unread count.

```dart
final count = ref.watch(unreadCountProvider);
```

### State Notifiers

#### `SendMessageNotifier`
Handles sending messages with loading and error states.

```dart
final notifier = ref.read(sendMessageProvider.notifier);
await notifier.sendMessage(
  receiverId: 'user2',
  text: 'Hello!',
);
```

#### `BlockUserNotifier`
Handles blocking/unblocking users.

```dart
final notifier = ref.read(blockUserProvider.notifier);
await notifier.blockUser('userId');
await notifier.unblockUser('userId');
```

## UI Components

### MessagesPage
Main tab showing conversation list with:
- Unread message count badge
- Last message preview
- Last message timestamp
- Empty state when no conversations

### ChatScreen
Chat interface with:
- Real-time message stream
- Message input field with send button
- Message bubbles with read status indicator
- Loading and error states

### ConversationListItem
List item widget showing:
- User avatar
- User display name
- Last message preview
- Timestamp
- Unread badge

### MessageBubble
Message display widget with:
- Message text
- Optional image display
- Send time
- Read status icon (for sent messages)
- Different styling for sent vs. received messages

## Push Notifications

### FCM Integration

The `FCMMessagingService` provides:

1. **Initialize FCM**
   ```dart
   await fcmService.initialize();
   ```
   Requests permissions and listens for incoming messages.

2. **Get FCM Token**
   ```dart
   String? token = await fcmService.getToken();
   ```
   Get device token for targeted notifications.

3. **Subscribe to Topics**
   ```dart
   await fcmService.subscribeToTopic('messages');
   ```
   Subscribe to notification topics.

4. **Background Message Handler**
   ```dart
   await FCMMessagingService.setupBackgroundMessageHandler();
   ```
   Handle notifications when app is in background.

### Implementation Notes

- Current implementation is a stub with logging
- Actual notifications should be sent from Cloud Functions
- Cloud Functions can be triggered by Firestore write events
- Store FCM tokens in user profile for targeted notifications

## Testing

### Unit Tests
Located in `test/features/messages/direct_messages_repository_test.dart`

Tests cover:
- Message sending
- Conversation creation
- Block operations
- Read receipts
- Message deletion
- Error handling
- Model serialization (JSON/Firestore)

### Run Tests
```bash
flutter test test/features/messages/direct_messages_repository_test.dart
```

## Error Handling

The repository throws exceptions for:
- Blocked user attempts to send message: `"This user has blocked you"`
- User not authenticated: `"User not authenticated"`
- Invalid operations

Handle these in UI with try-catch and show user-friendly error messages.

## Scalability Considerations

1. **Pagination**: Messages are limited to 50 per query, implement pagination for older messages
2. **Archiving**: Implement conversation archiving instead of deletion
3. **Encryption**: Consider end-to-end encryption for sensitive conversations
4. **Search**: Add message search using Algolia or similar
5. **Media Handling**: Current implementation supports image URLs, extend for file storage

## Future Enhancements

1. **Typing Indicators**: Real-time typing status (stub implementation provided)
2. **Message Reactions**: Add emoji reactions to messages
3. **Message Search**: Search within conversations
4. **Group Chats**: Extend to support group conversations
5. **Voice Messages**: Support voice/audio messages
6. **Message Forwarding**: Forward messages between conversations
7. **Pinned Messages**: Pin important messages in conversations
8. **Read Receipts Display**: Show when user is typing
9. **Delivery Status**: Distinguish between sent, delivered, and read
10. **Message Editing**: Allow editing messages after sending

## Deployment

1. **Deploy Firestore Rules**
   ```bash
   firebase deploy --only firestore:rules
   ```

2. **Deploy Firestore Indexes**
   ```bash
   firebase deploy --only firestore:indexes
   ```

3. **Enable Cloud Messaging**
   - Configure FCM in Firebase Console
   - Add service-account-key.json for backend operations

4. **Cloud Functions** (Optional)
   - Deploy notification functions
   - Set up message broadcast topics

## Performance

### Query Optimization
- Conversations indexed by userId1 and lastMessageTime
- Messages indexed by conversationId and createdAt
- Efficient pagination with limit(50)

### Real-time Updates
- Uses Firestore snapshots for real-time updates
- Automatically unsubscribes when providers are disposed
- Handles network disconnections gracefully

## Monitoring

Track these metrics:
- Average message send latency
- Message delivery success rate
- Read receipt update time
- FCM notification delivery rate
- User engagement (messages per day, active conversations)
