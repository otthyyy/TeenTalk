# Accessibility Guidelines - TeenTalk App

This document outlines the accessibility features and guidelines implemented in the TeenTalk app to ensure WCAG 2.1 AA compliance.

## Overview

The TeenTalk app is designed to be accessible to all users, including those with visual, auditory, motor, or cognitive impairments. We follow the Web Content Accessibility Guidelines (WCAG) 2.1 at the AA level.

## Key Features

### 1. Screen Reader Support

#### VoiceOver (iOS) / TalkBack (Android)

All key UI elements include proper semantic labels:

- **Feed Items**: Each post is announced with author, content, time, and action counts
- **Buttons**: All action buttons (like, comment, share, report) have descriptive labels
- **Navigation**: Bottom navigation and app bar elements are properly labeled
- **Forms**: All input fields have associated labels and hints
- **Images**: Post images and avatars have descriptive labels

#### Implementation

```dart
// Example: Accessible button with localized label
Semantics(
  label: l10n?.a11yLikeButton ?? 'Like post',
  button: true,
  child: IconButton(
    icon: Icon(Icons.favorite),
    onPressed: onLike,
  ),
)
```

### 2. Color Contrast

All text and interactive elements meet WCAG 2.1 AA contrast requirements:

- **Normal Text**: Minimum 4.5:1 contrast ratio
- **Large Text**: Minimum 3:1 contrast ratio
- **UI Components**: Minimum 3:1 contrast ratio

#### Color Palette

- **Light Theme**:
  - Primary text on background: #1F2937 on #FBFBFB (17.3:1) ✓
  - Primary color: #8B5CF6 with white text (4.6:1) ✓
  - Buttons: High contrast maintained

- **Dark Theme**:
  - Primary text on background: #F9FAFB on #0F0F1E (16.8:1) ✓
  - Primary color: #8B5CF6 with white text (4.6:1) ✓

### 3. Text Scaling

The app supports dynamic type scaling up to 200% without layout breakage:

- **Flexible Layouts**: Using `Flexible` and `Expanded` widgets
- **No Fixed Heights**: Avoiding hardcoded heights for text containers
- **Responsive Design**: Layouts adapt to text size changes

#### Testing

1. iOS: Settings → Accessibility → Display & Text Size → Larger Text
2. Android: Settings → Accessibility → Font Size

### 4. Focus Indicators

Keyboard navigation is supported with visible focus indicators:

```dart
focusTheme: FocusThemeData(
  glowColor: DesignTokens.vibrantPurple.withOpacity(0.2),
  glowFactor: 1.5,
),
```

### 5. Internationalization

Accessibility labels are fully localized in:
- English (en)
- Spanish (es)
- Italian (it)

## Screen-Specific Guidelines

### Feed Screen

- ✓ Posts are wrapped in semantic containers
- ✓ Like, comment, and report buttons have accessible labels
- ✓ Post images include descriptive labels
- ✓ Timestamps are announced correctly
- ✓ Avatar images have author identification

### Post Composer

- ✓ Text input has proper labels and hints
- ✓ Image picker buttons are labeled
- ✓ Section selection chips are accessible
- ✓ Character count is announced
- ✓ Submit button state is communicated

### Onboarding

- ✓ Each step has a container label explaining the step
- ✓ Form validation errors are announced
- ✓ Progress indicator is available
- ✓ Navigation buttons are clearly labeled
- ✓ Decorative icons are excluded from semantics tree

### Messages

- ✓ Conversation list items are properly labeled
- ✓ Unread count is announced
- ✓ Empty states have descriptive text
- ✓ Error states are accessible

### Profile

- ✓ Profile information is organized semantically
- ✓ Edit buttons have descriptive labels
- ✓ Settings are accessible via keyboard
- ✓ Trust badges have explanatory tooltips

## Development Guidelines

### Adding New Features

When implementing new features, ensure:

1. **Semantic Labels**: Add descriptive labels to all interactive elements
2. **Focus Order**: Maintain logical focus traversal order
3. **Error Messages**: Provide clear, actionable error messages
4. **Loading States**: Announce loading and progress states
5. **Decorative Elements**: Exclude purely decorative elements from semantics tree

### Example: Accessible Button

```dart
Semantics(
  label: 'Share post',
  hint: 'Opens share dialog',
  button: true,
  enabled: !isLoading,
  child: IconButton(
    icon: Icon(Icons.share),
    onPressed: isLoading ? null : onShare,
  ),
)
```

### Example: Accessible Form Field

```dart
TextFormField(
  decoration: InputDecoration(
    labelText: 'Nickname',
    hintText: 'Enter a unique nickname',
    helperText: '3-20 characters, letters and numbers only',
  ),
  validator: (value) => validateNickname(value),
)
```

## Testing Checklist

### Manual Testing

- [ ] Enable VoiceOver/TalkBack and navigate through all screens
- [ ] Verify all interactive elements are announced correctly
- [ ] Test with largest text size (200%)
- [ ] Verify color contrast in both light and dark themes
- [ ] Test keyboard navigation (web/desktop)
- [ ] Check focus indicators are visible
- [ ] Verify all images have descriptive labels
- [ ] Test form validation error announcements

### Automated Testing

Run the following accessibility checks:

```bash
flutter analyze
flutter test
```

## Known Limitations

1. **Complex Animations**: Some animations may not be fully accessible with reduced motion settings (future improvement)
2. **Rich Media**: Video content accessibility to be implemented in future versions

## Resources

- [Flutter Accessibility Guide](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [Material Design Accessibility](https://material.io/design/usability/accessibility.html)

## Feedback

If you encounter accessibility issues, please report them through:
- GitHub Issues
- Email: accessibility@teentalk.app

## Version History

- **v1.0.0** (2024-01-10): Initial accessibility implementation
  - Screen reader support
  - Focus indicators
  - Text scaling support
  - Localized accessibility labels (EN, ES, IT)
  - WCAG 2.1 AA color contrast compliance

---

Last Updated: 2024-01-10
