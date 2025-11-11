# Testing Guide for TeenTalk

This document provides comprehensive guidance on testing the TeenTalk application, including unit tests, widget tests, and integration tests.

## Table of Contents

1. [Overview](#overview)
2. [Test Types](#test-types)
3. [Running Tests](#running-tests)
4. [Integration Tests](#integration-tests)
5. [Firebase Emulator Setup](#firebase-emulator-setup)
6. [Writing New Tests](#writing-new-tests)
7. [CI/CD Integration](#cicd-integration)
8. [Troubleshooting](#troubleshooting)

## Overview

TeenTalk uses a comprehensive testing strategy that includes:

- **Unit Tests**: Test individual functions, classes, and business logic
- **Widget Tests**: Test UI components in isolation
- **Integration Tests**: Test complete user flows end-to-end
- **Firebase Emulator Tests**: Test security rules and backend logic

## Test Types

### Unit Tests

Located in: `test/src/`

Unit tests focus on testing individual components in isolation:
- Services
- Repositories
- Providers
- Utilities
- Models

**Example:**
```dart
test('UserProfile serialization works correctly', () {
  final profile = UserProfile(
    uid: 'test123',
    nickname: 'testuser',
    // ...
  );
  
  final json = profile.toJson();
  final decoded = UserProfile.fromJson(json);
  
  expect(decoded.uid, profile.uid);
  expect(decoded.nickname, profile.nickname);
});
```

### Widget Tests

Located in: `test/features/`

Widget tests verify UI components render correctly and respond to user interactions:

**Example:**
```dart
testWidgets('LoginForm shows validation errors', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: LoginForm()),
  );
  
  await tester.tap(find.text('Sign In'));
  await tester.pumpAndSettle();
  
  expect(find.text('Email is required'), findsOneWidget);
});
```

### Integration Tests

Located in: `integration_test/`

Integration tests verify complete user flows work correctly from start to finish using the actual app with Firebase emulators.

## Running Tests

### Prerequisites

1. Install Flutter SDK
2. Install Firebase CLI: `npm install -g firebase-tools`
3. Install project dependencies: `flutter pub get`
4. Install Cloud Functions dependencies:
   ```bash
   cd functions
   npm install
   cd ..
   ```

### Run Unit & Widget Tests

```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run specific test file
flutter test test/src/features/auth/auth_service_test.dart

# Run tests matching a name pattern
flutter test --name "authentication"

# Run tests in a specific directory
flutter test test/src/features/auth/
```

### View Coverage Report

```bash
# Generate coverage report
flutter test --coverage

# View HTML coverage report (requires lcov)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

## Integration Tests

Integration tests provide end-to-end testing of user flows using Firebase emulators.

### Setup

#### Automated Workflow (Recommended)

Use the automated script to run the complete integration test workflow:

```bash
./scripts/run_integration_tests.sh
```

This script will:
- Start Firebase emulators
- Wait for emulators to be ready
- Run all integration tests
- Stop emulators when complete
- Report test results

#### Manual Workflow

For more control, run each step manually:

1. **Start Firebase Emulators**
   ```bash
   ./scripts/start_emulator.sh
   ```

   This script will:
   - Start Auth, Firestore, Storage, and Functions emulators
   - Wait for emulators to be ready
   - Display emulator URLs and status

2. **Run Integration Tests**
   ```bash
   # Run all integration tests
   flutter test integration_test/

   # Run specific integration test
   flutter test integration_test/app_test.dart

   # Run on connected device/emulator
   flutter drive \
     --driver=test_driver/integration_test.dart \
     --target=integration_test/app_test.dart
   ```

3. **Stop Firebase Emulators**
   ```bash
   ./scripts/stop_emulator.sh
   ```

### Integration Test Coverage

The integration test suite covers:

1. **Authentication Flow**
   - User sign-up with email/password
   - User sign-in for existing users
   - Email validation
   - Password validation

2. **Onboarding Flow**
   - Nickname selection and validation
   - Personal information entry
   - Interests selection
   - Consent management
   - Privacy preferences

3. **Post Creation**
   - Text post creation
   - Post with image upload
   - Post validation
   - Data persistence verification

4. **Comment System**
   - Adding comments to posts
   - Comment persistence
   - Comment count updates

5. **Like Functionality**
   - Liking posts
   - Like count updates
   - Like persistence in Firestore

6. **Direct Messaging**
   - Conversation creation
   - Message sending
   - Message persistence
   - Conversation list updates

7. **Notifications**
   - Notification creation
   - Notification stream updates
   - Notification persistence

### Integration Test Example

```dart
testWidgets('User can create a post', (tester) async {
  // Setup
  final userId = await TestHelpers.createTestUser(
    email: 'test@example.com',
    password: 'password123',
  );
  
  await TestHelpers.createUserProfile(
    uid: userId,
    nickname: 'testuser',
  );
  
  // Launch app
  await tester.pumpWidget(const TeenTalkApp());
  await tester.pumpAndSettle();
  
  // Navigate to post composer
  await TestHelpers.tapButton(
    tester,
    find.byIcon(Icons.add),
  );
  
  // Enter post content
  await TestHelpers.enterText(
    tester,
    find.byType(TextField),
    'Test post content',
  );
  
  // Submit post
  await TestHelpers.tapButton(
    tester,
    find.text('Post'),
  );
  
  // Verify post was created
  final firestore = FirebaseFirestore.instance;
  final posts = await firestore
      .collection('posts')
      .where('content', isEqualTo: 'Test post content')
      .get();
  
  expect(posts.docs.length, 1);
});
```

## Firebase Emulator Setup

### Configuration

Firebase emulator configuration is defined in `firebase.json`:

```json
{
  "emulators": {
    "auth": {"port": 9099},
    "firestore": {"port": 8080},
    "storage": {"port": 9199},
    "functions": {"port": 5001},
    "ui": {"enabled": true, "port": 4000}
  }
}
```

### Emulator UI

Access the emulator UI at `http://localhost:4000` to:
- View Firestore data in real-time
- Inspect authenticated users
- Monitor Storage buckets
- View function logs
- Test queries directly

### Connecting App to Emulator

For manual testing, configure your app to use emulators:

```dart
await Firebase.initializeApp();

// Connect to emulators
FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
```

## Writing New Tests

### Test Structure

Follow this structure for organizing tests:

```
test/
├── src/
│   ├── features/
│   │   ├── auth/
│   │   │   ├── auth_service_test.dart
│   │   │   └── auth_provider_test.dart
│   │   ├── feed/
│   │   └── messages/
│   └── core/
│       ├── services/
│       └── utilities/
├── helpers/
│   └── test_helpers.dart
└── widget_test.dart

integration_test/
├── app_test.dart
├── auth_flow_test.dart
├── messaging_test.dart
└── helpers/
    └── test_helpers.dart
```

### Test Naming Conventions

- Test files should end with `_test.dart`
- Use descriptive test names: `test('should return user when login succeeds', ...)`
- Group related tests: `group('Authentication', () { ... })`

### Best Practices

1. **Arrange-Act-Assert Pattern**
   ```dart
   test('description', () {
     // Arrange: Set up test data
     final service = AuthService();
     
     // Act: Perform the action
     final result = await service.signIn(email, password);
     
     // Assert: Verify the outcome
     expect(result.isSuccess, true);
   });
   ```

2. **Use Test Helpers**
   - Create reusable helper functions in `test/helpers/`
   - Reduce code duplication
   - Improve test readability

3. **Mock External Dependencies**
   ```dart
   final mockFirestore = MockFirebaseFirestore();
   when(mockFirestore.collection('users'))
       .thenReturn(mockCollection);
   ```

4. **Clean Up After Tests**
   ```dart
   tearDown(() async {
     await TestHelpers.clearFirestoreData();
     await TestHelpers.signOut();
   });
   ```

5. **Test Edge Cases**
   - Invalid input
   - Network errors
   - Empty states
   - Permission denied scenarios

### Integration Test Helpers

Use the helper utilities in `integration_test/helpers/test_helpers.dart`:

- `TestHelpers.connectToEmulators()`: Connect to Firebase emulators
- `TestHelpers.createTestUser()`: Create a test user
- `TestHelpers.createUserProfile()`: Create user profile
- `TestHelpers.createTestPost()`: Create a test post
- `TestHelpers.likePost()`: Like a post
- `TestHelpers.sendMessage()`: Send a direct message
- `TestHelpers.waitForWidget()`: Wait for widget to appear
- `TestHelpers.tapButton()`: Tap a button
- `TestHelpers.enterText()`: Enter text in a field

## CI/CD Integration

### GitHub Actions Example

Create `.github/workflows/test.yml`:

```yaml
name: Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.6'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Run unit & widget tests
        run: flutter test --coverage
      
      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          files: coverage/lcov.info

  integration-test:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.6'
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
      
      - name: Install Firebase CLI
        run: npm install -g firebase-tools
      
      - name: Install dependencies
        run: |
          flutter pub get
          cd functions && npm install && cd ..
      
      - name: Start emulators
        run: ./scripts/start_emulator.sh
      
      - name: Run integration tests
        run: flutter test integration_test/
      
      - name: Stop emulators
        run: ./scripts/stop_emulator.sh
```

## Troubleshooting

### Common Issues

#### 1. Emulator Won't Start

**Problem**: Emulator fails to start or ports are already in use

**Solution**:
```bash
# Check what's using the ports
lsof -i :8080  # Firestore
lsof -i :9099  # Auth
lsof -i :9199  # Storage

# Kill process on port
kill -9 <PID>

# Or use stop script
./scripts/stop_emulator.sh

# Then start again
./scripts/start_emulator.sh
```

#### 2. Tests Timeout

**Problem**: Tests timeout waiting for widgets

**Solution**:
- Increase timeout duration: `TestHelpers.waitForWidget(tester, finder, timeout: Duration(seconds: 30))`
- Check emulator is running: `curl http://localhost:4000`
- Check emulator logs: `cat emulator.log`

#### 3. Firebase Not Initialized

**Problem**: `Firebase has not been initialized` error

**Solution**:
```dart
setUpAll(() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await TestHelpers.connectToEmulators();
});
```

#### 4. Widget Not Found

**Problem**: `findsNothing` when widget should exist

**Solution**:
- Add pump/settle calls: `await tester.pumpAndSettle()`
- Use `waitForWidget` helper instead of direct find
- Check widget is actually rendered with `print(tester.allWidgets)`
- Verify navigation completed

#### 5. Flaky Tests

**Problem**: Tests pass sometimes, fail other times

**Solution**:
- Add proper waits between actions
- Clear state between tests in `setUp`/`tearDown`
- Avoid hardcoded delays, use `pumpAndSettle()`
- Ensure emulator is clean before each test

### Debug Mode

Run tests with verbose output:

```bash
# Flutter tests
flutter test -v

# Integration tests with driver logs
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/app_test.dart \
  --verbose
```

### Emulator Logs

Check emulator logs for issues:

```bash
# View logs
cat emulator.log

# Tail logs in real-time
tail -f emulator.log
```

## Additional Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Firebase Emulator Suite](https://firebase.google.com/docs/emulator-suite)
- [Integration Testing in Flutter](https://flutter.dev/docs/testing/integration-tests)
- [Mockito Documentation](https://pub.dev/packages/mockito)

## Contributing

When adding new features:

1. Write unit tests for business logic
2. Write widget tests for UI components
3. Add integration tests for complete flows
4. Ensure all tests pass before submitting PR
5. Maintain test coverage above 80%

---

**Last Updated**: 2024
**Maintained By**: TeenTalk Development Team
