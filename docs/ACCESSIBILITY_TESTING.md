# Accessibility Testing Guide

## Overview

This document describes the accessibility (a11y) testing strategy for the TeenTalk app. The test suite ensures that accessibility features remain functional and prevents regressions.

## Test Suite Structure

```
test/
├── a11y/                               # Accessibility tests
│   ├── post_card_a11y_test.dart       # PostCard widget a11y tests
│   ├── navigation_bar_a11y_test.dart  # Navigation bar a11y tests
│   └── color_contrast_test.dart       # Color contrast tests
└── helpers/                            # Test utilities
    ├── test_helpers.dart               # Common test helpers
    ├── golden_test_config.dart         # Golden test configuration
    └── color_contrast_matcher.dart     # Custom contrast matcher
```

## Running Tests

### Run All Accessibility Tests

```bash
flutter test test/a11y/
```

### Run Specific Test File

```bash
flutter test test/a11y/post_card_a11y_test.dart
flutter test test/a11y/navigation_bar_a11y_test.dart
flutter test test/a11y/color_contrast_test.dart
```

### Run with Coverage

```bash
flutter test --coverage test/a11y/
```

### Update Golden Files

When UI changes are intentional, update the golden files:

```bash
flutter test --update-goldens test/a11y/
```

## Test Categories

### 1. Semantic Label Tests

These tests verify that widgets expose proper semantic labels for screen readers:

- **PostCard Tests**: Verify post header, content, buttons have semantic labels
- **Navigation Bar Tests**: Verify navigation items are properly labeled
- **Feed List Tests**: Verify list container has appropriate semantics

**Example:**
```dart
testWidgets('has correct semantic labels for post header', (tester) async {
  // Test verifies that semantic labels are present
  final semanticsFinder = find.bySemanticsLabel(
    RegExp('Post by TestUser.*2h ago'),
  );
  expect(semanticsFinder, findsOneWidget);
});
```

### 2. Golden Tests

Golden tests capture UI screenshots at different text scale factors to catch overflow issues:

- **1.0x scale**: Baseline rendering
- **1.3x scale**: Moderate accessibility setting
- **2.0x scale**: Maximum accessibility setting

**Text Scale Factors:**
- 1.0x: Default text size
- 1.3x: WCAG AA large text recommendation
- 2.0x: Extreme case for maximum accessibility

**Example:**
```dart
testWidgets('renders correctly at 2.0x text scale', (tester) async {
  await tester.pumpWidget(
    createTestApp(
      widget,
      textScaleFactor: 2.0,
    ),
  );
  
  await expectLater(
    find.byType(Widget),
    matchesGoldenFile('goldens/widget_2.0x.png'),
  );
});
```

### 3. Overflow Tests

These tests verify that widgets don't overflow at increased text scales:

```dart
testWidgets('no overflow at 2.0x text scale', (tester) async {
  await tester.pumpWidget(
    createTestApp(widget, textScaleFactor: 2.0),
  );
  
  expect(tester.takeException(), isNull);
});
```

### 4. Color Contrast Tests

Tests verify that color combinations meet WCAG standards:

- **WCAG AA**: Minimum contrast ratio of 4.5:1 for normal text
- **WCAG AAA**: Minimum contrast ratio of 7:1 for normal text
- **Large Text**: Minimum contrast ratio of 3:1 (WCAG AA)

**Example:**
```dart
test('primary color has sufficient contrast with white', () {
  const primaryColor = Color(0xFF9333EA);
  const backgroundColor = Colors.white;
  
  expect(
    primaryColor,
    hasSufficientContrastWith(backgroundColor, ratio: 4.5),
  );
});
```

## Custom Matchers

### `hasSufficientContrastWith()`

Custom matcher that verifies color contrast ratios:

```dart
expect(
  textColor,
  hasSufficientContrastWith(backgroundColor, ratio: 4.5),
);
```

**Parameters:**
- `background`: Background color to test against
- `ratio`: Minimum contrast ratio (default: 4.5 for WCAG AA)

## Acceptance Criteria

All tests must pass to ensure:

1. ✅ **Semantic Labels**: All interactive elements have descriptive labels
2. ✅ **Text Scaling**: UI renders correctly at 1.3x and 2.0x text scale
3. ✅ **No Overflow**: No text overflow at increased scales
4. ✅ **Color Contrast**: Colors meet WCAG AA standards (4.5:1 minimum)
5. ✅ **Regression Prevention**: Tests fail when a11y features are removed

## Golden Test Files

Golden test baseline images are stored in:

```
test/a11y/goldens/
├── post_card_1.0x.png
├── post_card_1.3x.png
├── post_card_2.0x.png
├── navigation_bar_1.0x.png
├── navigation_bar_1.3x.png
└── navigation_bar_2.0x.png
```

## CI/CD Integration

### GitHub Actions Example

```yaml
- name: Run Accessibility Tests
  run: flutter test test/a11y/
  
- name: Check Golden Files
  run: |
    flutter test --update-goldens test/a11y/
    git diff --exit-code test/a11y/goldens/
```

## Best Practices

### Adding New Widgets

When adding new widgets, ensure:

1. Add semantic labels using `Semantics` widget
2. Create corresponding a11y tests
3. Generate golden files at all text scales
4. Verify color contrast for all color combinations

### Example Widget with Semantics

```dart
Semantics(
  label: 'Button description',
  button: true,
  child: IconButton(
    icon: Icon(Icons.add),
    onPressed: () {},
  ),
)
```

### Test Organization

- Group related tests using `group()`
- Use descriptive test names
- Include reason parameters in expectations
- Test both positive and negative cases

## Troubleshooting

### Golden Tests Failing

If golden tests fail unexpectedly:

1. Check if the failure is due to intentional UI changes
2. Visually inspect the diff images
3. Update goldens if changes are correct: `flutter test --update-goldens`
4. Commit updated golden files

### Semantics Tests Failing

If semantics tests fail:

1. Verify semantic labels are not removed
2. Check label text matches expected format
3. Ensure `Semantics` widgets are properly configured
4. Use Flutter DevTools to inspect semantics tree

### Contrast Tests Failing

If contrast tests fail:

1. Verify colors meet WCAG standards
2. Use online contrast checkers to validate
3. Adjust colors if needed
4. Document any exceptions with reasons

## Resources

- [Flutter Accessibility Guide](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Design Accessibility](https://material.io/design/usability/accessibility.html)
- [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)

## Continuous Improvement

The a11y test suite should be expanded as new features are added:

- Add tests for new interactive widgets
- Test complex user flows
- Expand golden test coverage
- Monitor and improve test execution time
