# Golden Test Files

This directory contains golden image files used for widget testing. Golden tests ensure UI consistency by comparing rendered widgets against baseline images.

## Directory Structure

```
test/goldens/
├── README.md                                    # This file
├── post_card_*.png                              # PostCard widget goldens
├── notification_card_*.png                      # NotificationCard widget goldens
├── feed_list_*.png                              # Feed list goldens
└── notifications_page_*.png                     # NotificationsPage goldens
```

## Running Golden Tests

### Execute all widget tests with goldens:
```bash
flutter test test/widget_tests/
```

### Update golden files (when UI changes are intentional):
```bash
flutter test --update-goldens
```

### Update specific test file:
```bash
flutter test --update-goldens test/widget_tests/post_card_widget_test.dart
```

## When to Update Goldens

Update golden files when:
- You've made intentional UI changes
- Design specifications have changed
- Theme updates affect appearance
- New widget states are added

**Always review changes carefully** before updating goldens to ensure they match design requirements.

## Golden Test Coverage

### PostCard Widget
- **States tested:**
  - Normal post (light/dark themes)
  - Anonymous post
  - Post with image
  - High engagement post (999+ likes)
  - Liked post state
  - New post with shimmer animation
- **Devices:** Phone (400px), Tablet (800px)

### NotificationCard Widget
- **States tested:**
  - Unread comment mention
  - Comment reply
  - Read post mention
  - General notification
  - Multiple notification types in list
- **Themes:** Light and dark
- **Devices:** Phone and tablet widths

### Feed List
- **States tested:**
  - Multiple posts scroll view
  - Empty feed state
  - Mixed post types (regular, anonymous, with images)
- **Themes:** Light and dark
- **Devices:** Phone and tablet widths

### Notifications Page
- **States tested:**
  - Page with notifications
  - Empty state
  - Loading state
- **Themes:** Light and dark
- **Devices:** Phone and tablet widths

## Best Practices

1. **Review Diffs:** Always visually inspect golden diffs before committing
2. **Consistent Environment:** Run tests in CI to ensure consistency across machines
3. **Meaningful Names:** Use descriptive names for golden files that indicate the state being tested
4. **Theme Coverage:** Test both light and dark themes for all components
5. **Device Coverage:** Test phone and tablet widths where appropriate
6. **Version Control:** Commit golden files to version control

## Troubleshooting

### Golden test failures
If golden tests fail unexpectedly:
1. Check if you've made unintended UI changes
2. Verify font rendering is consistent (see `test/helpers/golden_test_helper.dart`)
3. Ensure you're using the same Flutter version as CI
4. Check for platform-specific rendering differences

### Font rendering issues
The `golden_toolkit` package handles font loading automatically via `loadAppFonts()`. If you encounter font-related issues:
1. Ensure `golden_toolkit` is up to date in `pubspec.yaml`
2. Check that `loadTestFonts()` is called in `setUpAll()` in each test file

### CI failures
If goldens pass locally but fail in CI:
1. Regenerate goldens in CI environment or use a consistent Docker image
2. Check Flutter version consistency between local and CI
3. Verify all test dependencies are properly installed in CI

## Maintenance

- **Regular Review:** Periodically review golden files to ensure they remain relevant
- **Cleanup:** Remove outdated golden files when features are removed
- **Documentation:** Update this README when adding new golden test categories

## Related Files

- `test/helpers/golden_test_helper.dart` - Helper functions for golden testing
- `test/widget_tests/` - Widget test files that generate goldens
- `pubspec.yaml` - Dependencies including `golden_toolkit`

## Additional Resources

- [golden_toolkit package](https://pub.dev/packages/golden_toolkit)
- [Flutter Golden Tests Guide](https://flutter.dev/docs/testing/overview#golden-file-testing)
- [Visual Testing Best Practices](https://martinfowler.com/articles/visual-testing.html)
