# Widget Tests

This directory contains widget tests for UI components using `flutter_test` and `golden_toolkit` for visual regression testing.

## Test Files

- **`post_card_test.dart`** - PostCard widget tests with golden snapshots
- **`notification_card_test.dart`** - Notification card widget tests
- **`message_bubble_test.dart`** - Message bubble widget tests for chat

## Running Tests

### Run all widget tests:
```bash
flutter test test/widget_tests/
```

### Run specific test file:
```bash
flutter test test/widget_tests/post_card_test.dart
```

### Update golden files:
```bash
flutter test --update-goldens test/widget_tests/
```

## Test Coverage

### PostCard Widget
- ✅ Normal posts with various content
- ✅ Anonymous posts
- ✅ Posts with images
- ✅ High engagement posts (999+ likes, many comments)
- ✅ New posts with shimmer effect
- ✅ Light and dark themes
- ✅ Phone and tablet layouts
- ✅ Like/unlike interactions
- ✅ Comment button interactions

### NotificationCard Widget
- ✅ Comment mention notifications (unread)
- ✅ Comment reply notifications
- ✅ Post mention notifications (read)
- ✅ General system notifications
- ✅ Light and dark themes
- ✅ Tablet layout

### MessageBubble Widget
- ✅ Sent messages (current user)
- ✅ Received messages (other users)
- ✅ Read/unread status indicators
- ✅ Messages with images
- ✅ Long messages with text wrapping
- ✅ Conversation flow
- ✅ Light and dark themes
- ✅ Tablet layout
- ✅ Timestamp formatting
- ✅ Sender avatars

## Golden Files

Golden files are stored in `test/goldens/` with subdirectories for each component:
- `post_card/` - PostCard golden images
- `notification_card/` - NotificationCard golden images
- `message_bubble/` - MessageBubble golden images

### Golden File Naming
Format: `{component}/{component}_variants_{theme}.png`

Examples:
- `post_card/post_card_variants_light.png`
- `notification_card/notification_variants_dark.png`
- `message_bubble/message_variants_light.png`

## Best Practices

1. **Use deterministic data** - Fixed dates, predictable IDs
2. **Test both themes** - Light and dark mode coverage
3. **Test multiple device sizes** - Phone (400-480px) and tablet (800-840px)
4. **Mock dependencies** - Use ProviderScope overrides for Riverpod providers
5. **Test interactions** - Not just visuals, but also button taps and callbacks
6. **Edge cases** - Empty states, long content, high numbers

## Adding New Tests

1. Create a new test file in this directory
2. Import necessary dependencies:
   ```dart
   import 'package:flutter_test/flutter_test.dart';
   import 'package:golden_toolkit/golden_toolkit.dart';
   import '../helpers/golden_test_helper.dart';
   ```
3. Call `loadTestFonts()` in `setUpAll()`
4. Use `testGoldens()` for golden tests
5. Use `GoldenBuilder` for multiple scenarios
6. Update this README with new test coverage

## Troubleshooting

### Golden test failures
1. Check `test/failures/` directory for visual diffs
2. Compare against expected golden in `test/goldens/`
3. If changes are intentional, run with `--update-goldens`

### Font rendering issues
- Ensure `loadTestFonts()` is called in `setUpAll()`
- The `golden_toolkit` package handles fonts automatically

### Provider overrides
Use ProviderScope overrides to mock Riverpod providers:
```dart
ProviderScope(
  overrides: [
    myProvider.overrideWith((ref) => mockValue),
  ],
  child: MyWidget(),
)
```

## Related Documentation

- [WIDGET_TESTS_GUIDE.md](../../WIDGET_TESTS_GUIDE.md) - Complete testing guide
- [test/goldens/README.md](../goldens/README.md) - Golden files maintenance
- [test/helpers/golden_test_helper.dart](../helpers/golden_test_helper.dart) - Helper functions
