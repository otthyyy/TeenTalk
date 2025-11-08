# Firebase Emulator Testing Guide

Quick guide to setting up and running comprehensive tests for Firestore security rules and Cloud Functions using the Firebase Emulator Suite.

## Quick Start

### 1. Install Dependencies

```bash
# Project dependencies
flutter pub get

# Cloud Functions dependencies
cd functions
npm install
cd ..

# Install Firebase CLI if not already installed
npm install -g firebase-tools
```

### 2. Start the Emulator Suite

```bash
# Start all emulators
firebase emulators:start

# Or in a separate terminal for background running
firebase emulators:start > emulator.log 2>&1 &

# View emulator UI
# Open http://localhost:4000 in your browser
```

### 3. Run Tests

#### Firestore & Storage Rules Tests

```bash
# Run all emulator tests
flutter test test/firebase_emulator_test.dart

# Run specific test group
flutter test test/firebase_emulator_test.dart -n "Users Collection"

# Run with verbose output
flutter test test/firebase_emulator_test.dart -v

# Run with coverage
flutter test --coverage test/firebase_emulator_test.dart
```

#### Cloud Functions Tests

```bash
cd functions

# Run all tests
npm test

# Run specific test suite
npm test -- --grep "nicknameValidation"

# Watch mode (re-run on file changes)
npm test -- --watch

# Generate coverage report
npm test -- --coverage

# Run with verbose output
npm test -- --reporter spec
```

## Test Organization

### Firestore Security Rules Tests

Located in: `test/firebase_emulator_test.dart`

#### Test Groups

1. **Users Collection** (5 tests)
   - Read visible profiles
   - Update own profile
   - Immutable field protection
   - Delete account
   - Batch operations

2. **Posts Collection** (3 tests)
   - Create with validation
   - Invalid content rejection
   - Initial count values

3. **Comments Collection** (2 tests)
   - Comment creation
   - Like count tracking

4. **DirectMessages Collection** (2 tests)
   - Conversation reading
   - Message addition

5. **ReportedPosts Collection** (2 tests)
   - Report creation
   - Reason validation

6. **Post Likes** (2 tests)
   - Like addition
   - Like removal

7. **Storage Rules** (2 tests)
   - Profile photo upload
   - File size enforcement

8. **Batch Operations** (1 test)
   - Batch write consistency

9. **Query Performance** (2 tests)
   - Query by author
   - Query by nickname

10. **Data Validation** (2 tests)
    - Empty content rejection
    - Oversized content rejection

### Cloud Functions Tests

Located in: `functions/src/index.test.ts`

#### Test Groups

1. **nicknameValidation** (2 tests)
   - Uniqueness validation
   - Duplicate detection

2. **postCounters** (4 tests)
   - Initial zero counts
   - Comment increment tracking
   - Like increment tracking
   - Like removal handling

3. **commentCounters** (1 test)
   - Comment like tracking

4. **moderationQueue** (3 tests)
   - Queue item creation
   - Priority calculation
   - Admin actions

5. **pushNotifications** (2 tests)
   - FCM token registration
   - Duplicate token prevention

6. **dataCleanup** (1 test)
   - Notification cleanup simulation

7. **Authorization** (2 tests)
   - Unauthorized access prevention
   - Privacy settings enforcement

8. **Batch Operations** (1 test)
   - Batch write correctness

## Running Specific Scenarios

### Scenario 1: Test User Registration Flow

```bash
# 1. Ensure emulator is running
firebase emulators:start

# 2. Run user-related tests
flutter test test/firebase_emulator_test.dart -n "Users Collection"

# 3. Test nickname validation
cd functions && npm test -- --grep "nicknameValidation" && cd ..
```

### Scenario 2: Test Post and Comment System

```bash
firebase emulators:start

# Test post creation
flutter test test/firebase_emulator_test.dart -n "Posts Collection"

# Test comment operations
flutter test test/firebase_emulator_test.dart -n "Comments Collection"

# Test counters
cd functions && npm test -- --grep "Counters" && cd ..
```

### Scenario 3: Test Moderation System

```bash
firebase emulators:start

# Test report creation
flutter test test/firebase_emulator_test.dart -n "ReportedPosts Collection"

# Test moderation queue
cd functions && npm test -- --grep "moderationQueue" && cd ..
```

### Scenario 4: Test Direct Messaging

```bash
firebase emulators:start

# Test messaging
flutter test test/firebase_emulator_test.dart -n "DirectMessages Collection"

# Test message notifications
cd functions && npm test -- --grep "pushNotifications" && cd ..
```

## Emulator UI

Access the Emulator UI at http://localhost:4000 during testing to:

- View Firestore documents in real-time
- Inspect rule compilation results
- View function logs
- Monitor Storage buckets
- Test queries directly

## Debugging Tests

### Enable Verbose Logging

```bash
# Firestore tests
flutter test test/firebase_emulator_test.dart -v

# Cloud Functions tests
npm test -- --reporter spec
```

### Connect App to Emulator for Manual Testing

```dart
// In your Firebase initialization code
await Firebase.initializeApp();

FirebaseFirestore.instance.settings = const Settings(
  host: 'localhost:8080',
  sslEnabled: false,
  persistenceEnabled: false,
);

// For Cloud Functions
FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
```

### Run Functions Locally

```bash
# Test a specific function
firebase functions:shell
> validateNicknameUniqueness({nickname: 'testuser'})
```

## Common Test Patterns

### Test User Creation with All Fields

```dart
test('User creation validates all required fields', () async {
  final userId = 'testUser123';
  final docRef = firestore.collection('users').doc(userId);

  await docRef.set({
    'uid': userId,
    'nickname': 'testuser',
    'nicknameLowercase': 'testuser',
    'profileVisible': true,
    'privacyConsentGiven': true,
    'privacyConsentTimestamp': Timestamp.now(),
    'createdAt': Timestamp.now(),
    'anonymousPostsCount': 0,
    'isAdmin': false,
    'blockedUsers': [],
    'isSuspended': false,
  });

  final doc = await docRef.get();
  expect(doc.exists, isTrue);
  expect(doc['nickname'], 'testuser');
});
```

### Test Cloud Function with Parameters

```typescript
it('should validate nickname uniqueness', async () => {
  const userId = 'testUser123';
  await db.collection('users').doc(userId).set({
    uid: userId,
    nickname: 'testnicname',
    nicknameLowercase: 'testnicname',
    // ... other fields
  });

  const query = db
    .collection('users')
    .where('nicknameLowercase', '==', 'testnicname');
  const snapshot = await query.get();

  expect(snapshot.size).to.equal(1);
});
```

## Troubleshooting

### Emulator Won't Start

```bash
# Check if ports are in use
lsof -i :8080  # Firestore
lsof -i :9199  # Storage
lsof -i :5001  # Functions

# Kill process on port
kill -9 <PID>

# Try again
firebase emulators:start
```

### Tests Failing with Permission Denied

1. Check rules syntax: `firebase validate`
2. Verify test data structure matches rules
3. Ensure authentication is properly set
4. Check blocking/privacy settings

### Functions Not Triggering

1. Verify function is deployed to emulator
2. Check function logs: `firebase functions:log`
3. Ensure document write matches trigger path
4. Verify Cloud Functions are in the emulator config

### Slow Test Execution

1. Close unnecessary applications
2. Use `--concurrency` flag in Flutter tests
3. Run specific test groups instead of all
4. Check emulator logs for issues

## Best Practices

1. **Clear State Between Tests**
   - Use `tearDown()` to clean database
   - Reset collections after each test

2. **Comprehensive Coverage**
   - Test valid and invalid inputs
   - Test edge cases
   - Test permission boundaries

3. **Realistic Data**
   - Use realistic field values
   - Include required timestamps
   - Test with various data types

4. **Performance Testing**
   - Measure query times
   - Test with larger datasets
   - Verify index usage

5. **Documentation**
   - Document complex test logic
   - Add comments for non-obvious tests
   - Update this guide as tests evolve

## CI/CD Integration

### GitHub Actions Example

```yaml
name: Firebase Emulator Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.6'
      
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '18'
      
      - name: Install dependencies
        run: |
          flutter pub get
          cd functions && npm install && cd ..
      
      - name: Start emulator
        run: |
          firebase emulators:start > /dev/null 2>&1 &
          sleep 10
      
      - name: Run Flutter tests
        run: flutter test test/firebase_emulator_test.dart
      
      - name: Run Cloud Functions tests
        run: cd functions && npm test && cd ..
```

## Next Steps

1. ✅ Run all tests successfully
2. ✅ Deploy to development environment
3. ✅ Test with actual app
4. ✅ Monitor production deployment
5. ✅ Collect feedback and iterate

## Additional Resources

- [Firebase Emulator Documentation](https://firebase.google.com/docs/emulator-suite)
- [Firestore Security Rules](https://firebase.google.com/docs/firestore/security/start)
- [Cloud Functions Testing](https://firebase.google.com/docs/functions/testing/overview)
- [Flutter Testing](https://flutter.dev/docs/testing)

---

**Last Updated**: 2024
**Version**: 1.0
**Maintained By**: TeenTalk Development Team
