# Widget Tests & Golden Testing Guide

This guide explains how to run, maintain, and extend widget tests with golden file testing in this Flutter project.

## Overview

Widget tests validate UI components render correctly across different states, themes, and device widths. We use:

- **`flutter_test`**: Flutter's built-in widget testing framework
- **`golden_toolkit`**: For snapshot-based visual regression testing
- **Riverpod mocks**: To provide deterministic test data

## Test Coverage

### Current Widget Tests

1. **PostCard Widget** (`test/widget_tests/post_card_widget_test.dart`, `post_card_golden_test.dart`)
   - Normal posts, anonymous posts, high engagement, images
   - Light/dark themes, phone/tablet layouts
   - Like/unlike states, new post shimmer animations

2. **NotificationCard Widget** (`test/widget_tests/notification_card_test.dart`)
   - Comment mentions, replies, post mentions, general notifications
   - Read/unread states
   - Light/dark themes, responsive layouts

3. **Feed List** (`test/widget_tests/feed_list_test.dart`)
   - Multiple posts in scrollable feed
   - Empty feed state
   - Mixed post types (regular, anonymous, images)

4. **Notifications Page** (`test/widget_tests/notifications_page_test.dart`)
   - Notifications list with mark all read
   - Empty state, loading state
   - Theme and responsive variations

5. **Chat/Messages** (`test/widget_tests/chat_screen_test.dart`)
   - Message bubbles (sent/received)
   - Read/unread indicators, timestamps
   - Messages with images
   - Empty chat state

## Running Tests

### Run all widget tests:
```bash
flutter test test/widget_tests/
```

### Run specific test file:
```bash
flutter test test/widget_tests/post_card_widget_test.dart
```

### Update golden baseline images (after intentional UI changes):
```bash
flutter test --update-goldens test/widget_tests/
```

### Update goldens for specific test:
```bash
flutter test --update-goldens test/widget_tests/post_card_widget_test.dart
```

### Run tests with coverage:
```bash
flutter test --coverage test/widget_tests/
```

## Golden Files

Golden files are stored in `test/goldens/` directory. Each golden file is a PNG snapshot of a widget in a specific state.

### Naming Convention:
```
widget_name_state_theme.png

Examples:
- post_card_normal_light.png
- notification_card_comment_mention_unread.png
- feed_list_tablet.png
- message_bubble_current_user_dark.png
```

### When to Update Goldens:

✅ **Update when:**
- You've made intentional UI changes
- Design specifications have changed
- Theme updates affect appearance
- New widget states are added

❌ **Don't update when:**
- Tests fail unexpectedly
- You haven't reviewed the visual diffs
- Changes weren't intentional

### Reviewing Golden Diffs:

1. Run tests without `--update-goldens` first
2. Check failure output for visual diffs
3. Review images in `test/failures/` directory
4. Compare against expected goldens in `test/goldens/`
5. If changes are correct, update with `--update-goldens`

## Writing New Widget Tests

### Basic Structure:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import '../helpers/golden_test_helper.dart';

void main() {
  setUpAll(() async {
    await loadTestFonts();
  });

  group('MyWidget Tests', () {
    testGoldens('MyWidget displays correctly', (tester) async {
      await tester.pumpWidgetBuilder(
        MyWidget(data: mockData),
        wrapper: materialAppWrapper(
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
              brightness: Brightness.light,
            ),
          ),
        ),
        surfaceSize: const Size(400, 600),
      );

      await screenMatchesGolden(tester, 'my_widget_light');
    });
  });
}
```

### Mocking Riverpod Providers:

```dart
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      myDataProvider.overrideWith((ref) => Stream.value(mockData)),
      myActionsProvider.overrideWithValue(mockActions),
    ],
    child: MaterialApp(
      home: MyWidget(),
    ),
  ),
);
```

### Testing Multiple States:

```dart
testGoldens('Widget with multiple states', (tester) async {
  final builder = GoldenBuilder.column()
    ..addScenario('default state', MyWidget())
    ..addScenario('loading state', MyWidget(isLoading: true))
    ..addScenario('error state', MyWidget(hasError: true));

  await tester.pumpWidgetBuilder(
    builder.build(),
    wrapper: materialAppWrapper(),
    surfaceSize: const Size(400, 1200),
  );

  await screenMatchesGolden(tester, 'my_widget_states');
});
```

## Best Practices

### 1. Test Device Sizes
Always test both phone and tablet widths:
```dart
surfaceSize: const Size(400, 600)  // Phone
surfaceSize: const Size(800, 600)  // Tablet
```

### 2. Test Both Themes
Create separate test cases for light and dark themes:
```dart
brightness: Brightness.light
brightness: Brightness.dark
```

### 3. Use Deterministic Data
Always use fixed dates and predictable data:
```dart
final now = DateTime(2024, 1, 15, 10, 30);
final post = Post(
  createdAt: now.subtract(const Duration(hours: 2)),
  // ... other fields
);
```

### 4. Mock External Dependencies
Mock providers, services, and network calls:
```dart
class MockAnalyticsService extends AnalyticsService {
  @override
  void logEvent(String name) {}
}
```

### 5. Test Edge Cases
Include tests for:
- Empty states
- Loading states
- Error states
- Long text content
- Maximum values (999+ likes)
- Minimum values (0 likes)

### 6. Organize Golden Files
Use subdirectories for related widgets:
```
test/goldens/
├── post_card/
│   ├── post_card_variants_light.png
│   └── post_card_variants_dark.png
├── notifications/
│   └── ...
└── messages/
    └── ...
```

## Troubleshooting

### Test Failures

**Problem:** Golden tests fail unexpectedly
```
The following TestFailure was thrown running a test:
Golden "my_widget_light.png": Pixel test failed
```

**Solution:**
1. Check `test/failures/` directory for actual vs expected comparison
2. Review your recent code changes
3. If changes are intentional, run with `--update-goldens`

### Font Rendering Issues

**Problem:** Text appears differently across machines

**Solution:**
- Ensure `loadTestFonts()` is called in `setUpAll()`
- Use same Flutter version as CI
- `golden_toolkit` handles fonts automatically

### Platform Differences

**Problem:** Goldens differ between macOS/Linux/Windows

**Solution:**
- Regenerate goldens on the target platform (CI)
- Use Docker for consistent environment
- Configure `flutter_test_config.dart` properly

### CI Failures

**Problem:** Tests pass locally but fail in CI

**Solution:**
1. Check Flutter version consistency
2. Verify dependencies are installed in CI
3. Consider regenerating goldens in CI environment
4. Check for font or rendering differences

## CI Integration

### GitHub Actions Example:
```yaml
- name: Run widget tests
  run: flutter test test/widget_tests/

- name: Check golden file differences
  run: |
    if git diff --exit-code test/goldens/; then
      echo "✓ Golden files unchanged"
    else
      echo "⚠️ Golden files changed - review carefully"
      exit 1
    fi
```

### Pre-commit Hook:
```bash
#!/bin/bash
# Run widget tests before committing golden files
if git diff --cached --name-only | grep -q "test/goldens/"; then
  echo "Golden files modified - running tests..."
  flutter test test/widget_tests/
fi
```

## Maintenance

### Regular Tasks:
- **Weekly:** Review and update outdated golden files
- **Before releases:** Run full golden test suite
- **After design changes:** Update affected goldens
- **On dependency updates:** Verify golden compatibility

### Cleanup:
```bash
# Remove orphaned golden files
find test/goldens/ -type f -name "*.png" | while read file; do
  if ! grep -r "$(basename "$file" .png)" test/widget_tests/; then
    echo "Orphaned: $file"
  fi
done
```

## Helper Functions

Located in `test/helpers/golden_test_helper.dart`:

- `loadTestFonts()`: Loads fonts for testing
- `wrapWithMaterialApp()`: Wraps widget in MaterialApp with theme
- `wrapWithScaffold()`: Wraps widget in Scaffold
- `testGolden()`: Convenience function for golden testing with multiple devices

## Resources

- [Flutter Widget Testing](https://docs.flutter.dev/testing/overview#widget-tests)
- [Golden File Testing](https://docs.flutter.dev/testing/overview#golden-file-testing)
- [golden_toolkit package](https://pub.dev/packages/golden_toolkit)
- [Riverpod Testing](https://riverpod.dev/docs/essentials/testing)

## Getting Help

If you encounter issues:
1. Check this guide
2. Review existing test files for examples
3. Check `test/goldens/README.md` for golden-specific info
4. Consult the Flutter testing documentation
5. Ask the team in #testing Slack channel

## Contributing

When adding new widgets:
1. Write widget tests with golden snapshots
2. Test multiple states (empty, loading, error, success)
3. Test both themes (light/dark)
4. Test responsive layouts (phone/tablet)
5. Update this guide if introducing new patterns
6. Ensure all tests pass before creating PR

---

**Last Updated:** January 2024
**Maintained By:** Engineering Team
