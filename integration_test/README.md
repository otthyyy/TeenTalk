# Integration Tests

This directory contains end-to-end integration tests for the TeenTalk application using Firebase emulators.

## Directory Structure

```
integration_test/
├── app_test.dart              # Main integration test suite
├── helpers/
│   └── test_helpers.dart      # Helper functions for tests
└── README.md                  # This file
```

## Test Files

### app_test.dart

Contains comprehensive integration tests covering:

1. **Complete User Flow**
   - Sign up with email
   - Onboarding completion
   - Post creation
   - Commenting
   - Liking posts
   - Direct messaging
   - Notification verification

2. **Sign-In Flow**
   - Existing user authentication
   - Navigation to feed

3. **Post with Image**
   - Post creation with image URL
   - Firestore persistence verification

4. **Notification Stream**
   - Real-time notification updates
   - Notification persistence

### helpers/test_helpers.dart

Provides utility functions for integration tests:

- **Emulator Connection**: `connectToEmulators()`
- **Data Management**: `clearFirestoreData()`, `signOut()`
- **User Creation**: `createTestUser()`, `createUserProfile()`
- **Content Creation**: `createTestPost()`, `createTestComment()`
- **Interactions**: `likePost()`, `sendMessage()`
- **Verification**: `notificationExists()`
- **Widget Testing**: `waitForWidget()`, `tapButton()`, `enterText()`

## Running Tests

### Quick Start

Run the automated integration test script:

```bash
./scripts/run_integration_tests.sh
```

### Manual Execution

```bash
# 1. Start emulators
./scripts/start_emulator.sh

# 2. Run tests
flutter test integration_test/

# 3. Stop emulators
./scripts/stop_emulator.sh
```

### Run Specific Test

```bash
flutter test integration_test/app_test.dart
```

### Run on Device/Emulator

For testing on a physical device or emulator:

```bash
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart
```

## Writing New Integration Tests

### Basic Test Structure

```dart
testWidgets('Test description', (WidgetTester tester) async {
  // 1. Setup test data
  final userId = await TestHelpers.createTestUser(
    email: 'test@example.com',
    password: 'password123',
  );
  
  await TestHelpers.createUserProfile(
    uid: userId,
    nickname: 'testuser',
  );
  
  // 2. Initialize app
  final crashlyticsService = CrashlyticsService();
  await crashlyticsService.initialize();
  
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        crashlyticsServiceProvider.overrideWithValue(crashlyticsService),
      ],
      child: const TeenTalkApp(),
    ),
  );
  await tester.pumpAndSettle();
  
  // 3. Perform interactions
  await TestHelpers.waitForWidget(tester, find.text('Feed'));
  await TestHelpers.tapButton(tester, find.byIcon(Icons.add));
  
  // 4. Verify results
  expect(find.text('Create Post'), findsOneWidget);
});
```

### Best Practices

1. **Clean State**: Always clear data in `setUp()`/`tearDown()`
2. **Use Helpers**: Leverage test helper functions for common operations
3. **Wait for UI**: Use `waitForWidget()` instead of fixed delays
4. **Verify Data**: Check Firestore directly to verify persistence
5. **Descriptive Names**: Use clear, descriptive test names
6. **Independent Tests**: Each test should be independent and not rely on others

### Common Patterns

#### Creating Test User and Profile

```dart
final userId = await TestHelpers.createTestUser(
  email: 'test@example.com',
  password: 'password123',
  displayName: 'Test User',
);

await TestHelpers.createUserProfile(
  uid: userId,
  nickname: 'testuser',
  bio: 'Test bio',
  isAdmin: false,
);
```

#### Navigating and Interacting

```dart
// Wait for a specific widget
await TestHelpers.waitForWidget(tester, find.text('Feed'));

// Tap a button
await TestHelpers.tapButton(tester, find.text('Submit'));

// Enter text
await TestHelpers.enterText(
  tester,
  find.byType(TextField),
  'Hello, world!',
);
```

#### Verifying Data in Firestore

```dart
final firestore = FirebaseFirestore.instance;
final snapshot = await firestore
    .collection('posts')
    .where('content', isEqualTo: 'Test post')
    .get();

expect(snapshot.docs.isNotEmpty, true);
expect(snapshot.docs.first.data()['authorId'], userId);
```

## Debugging Tests

### Enable Verbose Logging

```dart
print('Debug: Current state - ${tester.allWidgets}');
```

### Check Emulator Logs

```bash
tail -f emulator.log
```

### Access Emulator UI

Visit `http://localhost:4000` to:
- View Firestore data
- Check authenticated users
- Inspect storage files
- View function logs

## Troubleshooting

### Tests Timeout

- Increase timeout: `TestHelpers.waitForWidget(tester, finder, timeout: Duration(seconds: 30))`
- Verify emulators are running: `curl http://localhost:4000`
- Check emulator logs for errors

### Firebase Not Initialized

Ensure setup is correct in `setUpAll()`:

```dart
setUpAll(() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await TestHelpers.connectToEmulators();
});
```

### Widget Not Found

- Use `waitForWidget()` helper
- Add `await tester.pumpAndSettle()`
- Check navigation completed
- Print widget tree: `print(tester.allWidgets)`

### Data Persistence Issues

- Verify emulator connection
- Check security rules
- Ensure proper field names
- Review Firestore UI at `http://localhost:4000`

## CI/CD Integration

See [docs/TESTING.md](../docs/TESTING.md) for GitHub Actions configuration to run integration tests in CI.

## Related Documentation

- [Main Testing Guide](../docs/TESTING.md)
- [Firebase Emulator Guide](../EMULATOR_TESTING_GUIDE.md)
- [Flutter Integration Testing](https://flutter.dev/docs/testing/integration-tests)

## Contributing

When adding new features:

1. Write integration tests for user-facing flows
2. Use existing helper functions where possible
3. Add new helpers for reusable operations
4. Ensure tests are independent and can run in any order
5. Document complex test scenarios
