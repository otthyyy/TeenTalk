# Friends Feature

The Friends feature provides friend request and friendship management to gate messaging functionality.

## Structure

```
friends/
├── data/
│   ├── models/
│   │   ├── friend_request.dart        # Friend request model with status enum
│   │   ├── friend_entry.dart          # Friend list entry model
│   │   └── friendship_status.dart     # Friendship status enum
│   └── repositories/
│       └── friends_repository.dart    # Repository for all friend operations
└── presentation/
    └── providers/
        └── friends_provider.dart      # Riverpod providers for friends state
```

## Usage

### Send Friend Request
```dart
final notifier = ref.read(sendFriendRequestProvider.notifier);
await notifier.sendRequest(targetUserId);
```

### Accept Friend Request
```dart
final notifier = ref.read(respondToFriendRequestProvider.notifier);
await notifier.accept(requestId, otherUserId);
```

### Check Friendship Status
```dart
final statusAsync = ref.watch(friendshipStatusProvider(otherUserId));
statusAsync.when(
  data: (status) {
    // status can be: none, pendingSent, pendingReceived, friends
  },
  ...
);
```

### Watch Friend Requests
```dart
// Incoming requests
final incomingAsync = ref.watch(incomingFriendRequestsProvider);

// Outgoing requests
final outgoingAsync = ref.watch(outgoingFriendRequestsProvider);
```

### Watch Friends List
```dart
final friendsAsync = ref.watch(friendsListProvider);
```

## Models

### FriendRequest
Represents a friend request between users.

Fields:
- `id`: Request ID
- `senderId`: User who sent the request
- `receiverId`: User who received the request
- `status`: pending, accepted, rejected, or cancelled
- `createdAt`: Request timestamp
- `respondedAt`: Response timestamp (if responded)

### FriendEntry
Represents an entry in a user's friend list.

Fields:
- `friendId`: The friend's user ID
- `conversationId`: The conversation ID for messaging
- `createdAt`: When they became friends

### FriendshipStatus
Enum representing the friendship status between two users:
- `none`: No relationship
- `pendingSent`: Current user sent a request
- `pendingReceived`: Current user received a request
- `friends`: Users are friends

## Repository

### FriendsRepository

Core repository for all friendship operations.

Key methods:
- `sendFriendRequest()`: Send a friend request
- `cancelFriendRequest()`: Cancel a sent request
- `acceptFriendRequest()`: Accept a request (creates conversation and friend entries)
- `rejectFriendRequest()`: Reject a request
- `watchIncomingRequests()`: Stream of incoming requests
- `watchOutgoingRequests()`: Stream of outgoing requests
- `watchFriends()`: Stream of friends list
- `areFriends()`: Check if two users are friends
- `getFriendshipStatus()`: Get friendship status between users
- `getPendingRequestId()`: Get pending request ID if exists
- `removeFriend()`: Remove a friend from both users' lists
- `getConversationId()`: Get conversation ID for friends

## Providers

### friendsCurrentUserIdProvider
Provider for the current authenticated user's ID.

### incomingFriendRequestsProvider
Stream provider that watches incoming friend requests.

### outgoingFriendRequestsProvider
Stream provider that watches outgoing friend requests.

### friendsListProvider
Stream provider that watches the current user's friends list.

### friendshipStatusProvider
Family future provider that gets friendship status with another user.

### sendFriendRequestProvider
State notifier for sending and cancelling friend requests.

### respondToFriendRequestProvider
State notifier for accepting and rejecting friend requests.

## Integration with Messages

The friends feature is integrated with the messages feature:

1. **Messaging Gated by Friendship**: Users can only send messages to accepted friends. The `DirectMessagesRepository.sendMessage` method validates friendship before allowing messages.

2. **Conversation Creation**: When a friend request is accepted, a conversation document is created automatically, enabling immediate messaging.

3. **UI Integration**: 
   - `PostWidget` shows friend action buttons based on friendship status
   - `ChatScreen` validates friendship and disables messaging if not friends
   - `MessagesPage` can display friend requests section

## Firestore Structure

### friendRequests Collection
```
friendRequests/
  {requestId}/
    senderId: string
    receiverId: string
    status: "pending" | "accepted" | "rejected" | "cancelled"
    createdAt: timestamp
    respondedAt: timestamp (optional)
    conversationId: string (added on accept)
```

### friends Collection
```
friends/
  {userId}/
    list/
      {friendId}/
        conversationId: string
        createdAt: timestamp
```

### conversations Collection
Automatically created when friend request is accepted (if not exists).

## Security Rules

Add these to your `firestore.rules`:

```
// Friend requests - readable by sender and receiver, writable by owner
match /friendRequests/{requestId} {
  allow read: if request.auth != null && (
    resource.data.senderId == request.auth.uid ||
    resource.data.receiverId == request.auth.uid
  );
  allow create: if request.auth != null &&
    request.resource.data.senderId == request.auth.uid &&
    request.resource.data.status == 'pending';
  allow update: if request.auth != null && (
    (resource.data.senderId == request.auth.uid && 
     request.resource.data.status in ['cancelled']) ||
    (resource.data.receiverId == request.auth.uid && 
     request.resource.data.status in ['accepted', 'rejected'])
  );
}

// Friends list - readable by owner, writable by system
match /friends/{userId}/list/{friendId} {
  allow read: if request.auth != null && request.auth.uid == userId;
  allow write: if request.auth != null && request.auth.uid == userId;
}

// Conversations - only between friends
match /conversations/{conversationId} {
  allow read, write: if request.auth != null &&
    request.auth.uid in resource.data.participantIds &&
    exists(/databases/$(database)/documents/friends/$(request.auth.uid)/list/$(
      resource.data.participantIds[0] == request.auth.uid ? 
      resource.data.participantIds[1] : 
      resource.data.participantIds[0]
    ));
}
```

## Testing

Unit tests cover:
- Sending friend requests
- Accepting/rejecting requests
- Friendship status checks
- Friends list management
- Integration with messaging

Run tests:
```bash
flutter test test/features/friends/
```

## Future Enhancements

- Friend suggestions based on mutual friends or interests
- Friend request notifications
- Block unfriend actions
- Friend nicknames
- Friend groups/categories
