# Unit Tests Documentation

This directory contains comprehensive unit tests for core repositories and domain logic.

## Test Structure

The test directory mirrors the `lib/src/features` structure:

```
test/
└── src/
    └── features/
        ├── comments/
        │   └── data/
        │       └── repositories/
        │           ├── posts_repository_test.dart
        │           └── comments_repository_test.dart
        ├── messages/
        │   └── data/
        │       └── repositories/
        │           └── direct_messages_repository_test.dart
        └── profile/
            ├── data/
            │   └── repositories/
            │       └── user_repository_test.dart
            └── domain/
                └── models/
                    └── user_profile_test.dart
```

## Coverage

### PostsRepository Tests
- ✅ Posts filtering by section
- ✅ Excluding moderated posts
- ✅ Post sorting by date
- ✅ Like/unlike post operations
  - Incrementing like count atomically
  - Preventing duplicate likes
  - Decrementing without going below zero
- ✅ Creating posts with mentions
- ✅ Anonymous post counting
- ✅ Content validation

**File**: `test/src/features/comments/data/repositories/posts_repository_test.dart`

### CommentsRepository Tests
- ✅ Comment creation with mentions
- ✅ Incrementing post comment count
- ✅ Reply creation and reply count tracking
- ✅ Like/unlike comment operations
  - Preventing duplicate likes
  - Not decrementing below zero
- ✅ Comment deletion
  - Decrementing post comment count
  - Decrementing reply count for replies
- ✅ Fetching comments by post
- ✅ Fetching replies for a comment

**File**: `test/src/features/comments/data/repositories/comments_repository_test.dart`

### DirectMessagesRepository Tests
- ✅ Conversation ID generation (consistent regardless of order)
- ✅ Sending messages
  - Creating new conversations
  - Updating existing conversations
  - Incrementing unread counts
  - Timestamping correctly
- ✅ Blocking behavior
  - Blocking users
  - Unblocking users
  - Checking if user is blocked
  - Blocking is directional (A blocks B ≠ B blocks A)
  - Preventing messages from blocked users
- ✅ Getting blocked user lists
- ✅ Getting conversations
- ✅ Marking conversations as read
- ✅ Deleting conversations and messages
- ✅ Calculating total unread count

**File**: `test/src/features/messages/data/repositories/direct_messages_repository_test.dart`

### UserRepository Tests
- ✅ Nickname availability checking (case-insensitive)
- ✅ Getting user profiles
- ✅ Creating user profiles with search keywords
- ✅ Updating user profiles
  - Regenerating search keywords on updates
  - Rejecting taken nicknames
  - Normalizing nicknames
  - Updating multiple fields
- ✅ Nickname change cooldown (30 days)
  - Checking if user can change nickname
  - Calculating days until nickname change

**File**: `test/src/features/profile/data/repositories/user_repository_test.dart`

### Search Keyword Generator Tests
- ✅ Generating keywords from nickname, school, interests, clubs
- ✅ Converting to lowercase
- ✅ Handling null/empty values
- ✅ Deduplicating keywords
- ✅ Handling accented characters (José, München, café, etc.)
- ✅ Handling special characters (O'Brien, St. Mary's, etc.)
- ✅ Handling Unicode (中文名, 日本語, 한국어, Русский)
- ✅ Handling numbers (User123, AI101)
- ✅ Handling emoji (User😊)
- ✅ Handling hyphens, apostrophes, periods
- ✅ Handling large keyword lists

**File**: `test/src/features/profile/domain/models/user_profile_test.dart`

## Running Tests

### All repository tests
```bash
flutter test test/src/features
```

### Specific repository
```bash
# Posts
flutter test test/src/features/comments/data/repositories/posts_repository_test.dart

# Comments
flutter test test/src/features/comments/data/repositories/comments_repository_test.dart

# Direct Messages
flutter test test/src/features/messages/data/repositories/direct_messages_repository_test.dart

# User profiles
flutter test test/src/features/profile/data/repositories/user_repository_test.dart

# Search keywords
flutter test test/src/features/profile/domain/models/user_profile_test.dart
```

### With coverage
```bash
flutter test --coverage test/src/features
```

### Watch mode (requires entr or watchexec)
```bash
# Using entr (macOS/Linux)
ls test/**/*_test.dart | entr -c flutter test /_

# Using watchexec
watchexec -e dart -w test -- flutter test
```

## Key Testing Patterns

### Using FakeFirebaseFirestore
All repository tests use `fake_cloud_firestore` to mock Firestore without requiring a live connection:

```dart
late FakeFirebaseFirestore firestore;
late MyRepository repository;

setUp(() {
  firestore = FakeFirebaseFirestore();
  repository = MyRepository(firestore: firestore);
});
```

### Testing Transactions
Firestore transactions are tested by verifying atomic updates:

```dart
test('increments like count atomically', () async {
  final docRef = await firestore.collection('posts').add({...});
  
  await repository.likePost(docRef.id, 'user1');
  
  final updated = await docRef.get();
  expect(updated.get('likeCount'), 1);
});
```

### Testing Edge Cases
Each repository test suite includes edge cases:
- Empty/null inputs
- Duplicate operations (double-like, double-unlike)
- Boundary conditions (like count not going below zero)
- Error conditions (missing documents)

### Testing Data Transforms
Model serialization and transformation is verified:

```dart
test('returns post with correct data transformation', () async {
  final post = await repository.getPostById(docRef.id);
  
  expect(post!.id, docRef.id);
  expect(post.likeCount, 5);
  expect(post.likedBy.length, 5);
});
```

## Best Practices

1. **Test Isolation**: Each test is independent with its own firestore instance
2. **Descriptive Names**: Test names clearly describe what is being tested
3. **Arrange-Act-Assert**: Tests follow AAA pattern
4. **Helper Functions**: Common setup logic is extracted to helpers
5. **Edge Cases**: Both happy path and edge cases are covered

## Coverage Goals

Target coverage for repositories:
- **Statements**: >80%
- **Branches**: >70%
- **Functions**: >85%

Check current coverage:
```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```
