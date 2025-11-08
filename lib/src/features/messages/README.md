# Messages Feature

The Messages feature provides direct messaging capabilities between users.

## Structure

```
messages/
├── data/
│   ├── models/
│   │   ├── direct_message.dart       # DirectMessage model
│   │   ├── conversation.dart         # Conversation model
│   │   └── block.dart                # Block model
│   ├── repositories/
│   │   └── direct_messages_repository.dart  # DM repository with Firestore operations
│   └── services/
│       └── fcm_messaging_service.dart       # Firebase Cloud Messaging service
└── presentation/
    ├── pages/
    │   ├── messages_page.dart        # Main messages tab
    │   └── chat_screen.dart          # Chat interface
    ├── widgets/
    │   ├── conversation_list_item.dart   # Conversation list item
    │   └── message_bubble.dart           # Message display
    └── providers/
        └── direct_messages_provider.dart # State management providers
```

## Usage

### Initialize User ID
Before using messaging features, set the current user ID:

```dart
ref.read(currentUserIdProvider.notifier).state = userId;
```

### Send a Message
```dart
final notifier = ref.read(sendMessageProvider.notifier);
await notifier.sendMessage(
  receiverId: 'target-user-id',
  text: 'Hello!',
);
```

### Watch Conversations
```dart
final conversationsAsync = ref.watch(conversationsProvider);
conversations.when(
  data: (conversations) => ListView.builder(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stackTrace) => ErrorWidget(),
);
```

### Watch Messages in Conversation
```dart
final messagesAsync = ref.watch(messagesProvider(conversationId));
messages.when(
  data: (messages) => ListView.builder(...),
  loading: () => CircularProgressIndicator(),
  error: (error, stackTrace) => ErrorWidget(),
);
```

### Block a User
```dart
final notifier = ref.read(blockUserProvider.notifier);
await notifier.blockUser('user-id-to-block');
```

### Unblock a User
```dart
final notifier = ref.read(blockUserProvider.notifier);
await notifier.unblockUser('user-id-to-unblock');
```

## Models

### DirectMessage
Represents a single message in a conversation.

Fields:
- `id`: Unique message ID
- `conversationId`: ID of the conversation
- `senderId`: ID of the sender
- `receiverId`: ID of the receiver
- `text`: Message content
- `imageUrl`: Optional image URL
- `isRead`: Read status
- `createdAt`: Creation timestamp
- `readAt`: Read timestamp (if read)

### Conversation
Represents a conversation between two users.

Fields:
- `id`: Conversation ID (generated from user IDs)
- `userId1`: First user ID
- `userId2`: Second user ID
- `lastMessage`: Last message preview
- `lastMessageTime`: Time of last message
- `unreadCount`: Number of unread messages
- `createdAt`: Creation timestamp

### Block
Represents a user block relationship.

Fields:
- `blockerId`: ID of user doing the blocking
- `blockedUserId`: ID of blocked user
- `createdAt`: Block timestamp

## Providers

### currentUserIdProvider
State provider for the current authenticated user's ID.

```dart
final userId = ref.read(currentUserIdProvider);
ref.read(currentUserIdProvider.notifier).state = newUserId;
```

### conversationsProvider
Stream provider that watches all conversations for the current user.

```dart
final conversationsAsync = ref.watch(conversationsProvider);
// AsyncValue<List<Conversation>>
```

### messagesProvider
Family stream provider that watches messages in a specific conversation.

```dart
final messagesAsync = ref.watch(messagesProvider(conversationId));
// AsyncValue<List<DirectMessage>>
```

### blockedUsersProvider
Future provider that gets blocked users list.

```dart
final blockedAsync = ref.watch(blockedUsersProvider);
// AsyncValue<List<String>>
```

### unreadCountProvider
Future provider that gets total unread count.

```dart
final countAsync = ref.watch(unreadCountProvider);
// AsyncValue<int>
```

### sendMessageProvider
State notifier provider for sending messages.

```dart
final notifier = ref.read(sendMessageProvider.notifier);
await notifier.sendMessage(
  receiverId: 'user-id',
  text: 'Hello!',
  imageUrl: null,
);
```

### blockUserProvider
State notifier provider for blocking/unblocking users.

```dart
final notifier = ref.read(blockUserProvider.notifier);
await notifier.blockUser('user-id');
await notifier.unblockUser('user-id');
```

## Repository

### DirectMessagesRepository

Core repository for all messaging operations.

Key methods:
- `sendMessage()`: Send a message
- `watchConversations()`: Watch conversations (stream)
- `watchMessages()`: Watch messages in conversation (stream)
- `markMessageAsRead()`: Mark single message as read
- `markConversationAsRead()`: Mark all messages as read
- `blockUser()`: Block a user
- `unblockUser()`: Unblock a user
- `isUserBlocked()`: Check if user is blocked
- `getBlockedUsers()`: Get list of blocked users
- `deleteConversation()`: Delete a conversation
- `deleteMessage()`: Delete a message
- `getUnreadCount()`: Get total unread count

## FCM Service

### FCMMessagingService

Handles push notifications for messages.

Methods:
- `initialize()`: Initialize FCM and request permissions
- `getToken()`: Get device FCM token
- `sendMessageNotification()`: Send notification for new message
- `subscribeToTopic()`: Subscribe to topic
- `unsubscribeFromTopic()`: Unsubscribe from topic
- `setupBackgroundMessageHandler()`: Set up background handler

## Features

### Real-time Updates
Messages and conversations update in real-time via Firestore snapshots.

### Read Receipts
Messages track read/unread status with timestamps.

### Privacy Controls
- Block users to prevent receiving messages
- Blocked users cannot send messages to blocker
- Block list is private

### Typing Indicators
Stub implementation provided for future enhancement.

### Push Notifications
Integration with Firebase Cloud Messaging:
- Background/foreground message handling
- Topic subscriptions
- Token management
- Notification tap handling

## Security

Firestore rules ensure:
1. Only authenticated users can access messages
2. Users can only read their own conversations
3. Users can only write messages they send
4. Only users in conversation can view messages
5. Block list is private to the blocker
6. Users cannot bypass blocks

## Testing

Unit tests cover:
- Sending messages
- Creating conversations
- Blocking/unblocking
- Read receipts
- Message deletion
- Error handling
- Model serialization

Run tests:
```bash
flutter test test/features/messages/
```

## Performance

### Optimizations
- Conversations sorted by last message time
- Messages paginated (50 per query)
- Efficient real-time subscriptions
- Indexed queries for fast retrieval

### Scalability
- Subcollection structure avoids document size limits
- Deterministic conversation IDs prevent duplicates
- Batch operations for atomic updates

## Future Enhancements

See [DIRECT_MESSAGES_IMPLEMENTATION.md](../../DIRECT_MESSAGES_IMPLEMENTATION.md) for:
- Typing indicators
- Message reactions
- Message search
- Group chats
- Voice messages
- Message forwarding
- Pinned messages
