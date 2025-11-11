# Screenshot Protection Implementation

## Overview

This document describes the implementation of screenshot protection/detection features in the TeenTalk app to protect user privacy and discourage unauthorized sharing of content.

## Feature Summary

The screenshot protection feature provides platform-specific privacy measures:

- **Android**: Uses `FLAG_SECURE` to prevent screenshots (screen turns black in captures)
- **iOS**: Detects screenshots and screen recording, shows warnings and optionally blurs content
- **Global Setting**: Users can enable/disable the feature via profile settings

## Implementation Details

### Architecture

```
lib/src/features/screenshot_protection/
├── data/
│   └── services/
│       └── screenshot_protection_service.dart  # Platform-specific implementation
├── presentation/
│   ├── providers/
│   │   └── screenshot_protection_providers.dart  # State management
│   └── widgets/
│       ├── screenshot_warning_dialog.dart  # Warning modal
│       └── screenshot_blur_overlay.dart    # iOS blur overlay
└── services/
    └── screenshot_protection_service.dart  # Export
```

### Platform-Specific Implementation

#### Android (FLAG_SECURE)

Uses `flutter_windowmanager` plugin to apply `FLAG_SECURE`:

```dart
await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
```

**Behavior:**
- When enabled, screenshots show a black screen
- Screen recordings show black content
- Does NOT interfere with video playback (tested with common video players)

**Limitations:**
- Can be bypassed on rooted devices
- Does not prevent screen mirroring via cables

#### iOS (Detection + Warning + Blur)

Uses native platform channels and iOS APIs:

1. **Screenshot Detection**: Uses `UIApplication.userDidTakeScreenshotNotification`
2. **Screen Recording Detection**: Uses `UIScreen.main.isCaptured` (iOS 11+)

**Implementation in AppDelegate.swift:**
```swift
// Screenshot notification
NotificationCenter.default.addObserver(
  self,
  selector: #selector(didTakeScreenshot),
  name: UIApplication.userDidTakeScreenshotNotification,
  object: nil
)

// Screen capture KVO
isCapturedObserver = UIScreen.main.observe(\.isCaptured, options: [.new]) { ... }
```

**Behavior:**
- Detects when user takes a screenshot → Shows warning dialog
- Detects when screen recording starts → Applies blur overlay
- Cannot physically prevent screenshots (iOS limitation)

**Limitations:**
- Cannot prevent screenshots (only detect and warn)
- Users can dismiss warnings
- Screen recording blur can be bypassed by restarting recording

### User Profile Integration

Added `screenshotProtectionEnabled` field to UserProfile model:

```dart
final bool screenshotProtectionEnabled;  // Default: true
```

This field is:
- Stored in Firestore
- Editable via Profile Edit page
- Displayed in Profile page privacy settings

### Analytics Events

The following analytics events are logged:

| Event Name | Parameters | Trigger |
|------------|------------|---------|
| `screenshot_protection_enabled` | - | User enables protection in settings |
| `screenshot_protection_disabled` | - | User disables protection in settings |
| `screenshot_attempt_detected` | - | Screenshot taken (iOS only) |
| `screen_capture_detected` | `platform: 'ios'`, `is_captured: bool` | Screen recording status changes (iOS) |

### UI Components

#### Warning Dialog

Displayed when a screenshot is detected on iOS:

- **Icon**: Warning icon in error color
- **Title**: "Screenshot Detected"
- **Content**: 
  - Reminds user to respect privacy
  - Lists privacy guidelines
  - Warns about potential account suspension
- **Action**: "I Understand" button

#### Blur Overlay (iOS)

Applied when screen recording is active:

- **Effect**: Gaussian blur (sigma: 12.0) + dark overlay
- **Indicator**: Icon and text explaining content is blurred
- **Dismissal**: Automatically removed when recording stops

### Settings UI

Located in Profile Edit page under "Privacy Settings":

```
Screenshot Protection [Toggle]
Discourage screenshots; Android blocks captures, iOS shows warnings and blur.
```

## Limitations & Caveats

### Platform Limitations

1. **Web Platform**: 
   - Cannot prevent or detect screenshots
   - Browser APIs don't provide screenshot detection
   - Recommendation: Show privacy overlay on web

2. **Android Rooted Devices**:
   - FLAG_SECURE can be bypassed
   - No reliable detection method for root status

3. **iOS**:
   - Cannot physically prevent screenshots
   - Can only detect and warn
   - Screen recording blur can be bypassed

### Video Playback Compatibility

- **Android**: FLAG_SECURE is compatible with standard Flutter video players
- If using native video views, may need to handle secure flags per surface
- Tested with common video player plugins without issues

### Performance Impact

- **Minimal overhead**: Detection listeners are lightweight
- **No battery impact**: Passive notification listeners
- **Memory**: Two stream subscriptions per active session

## QA Plan

### Manual Testing Checklist

#### Android
- [ ] Enable protection → Screenshot attempt → Verify black screen in capture
- [ ] Disable protection → Screenshot attempt → Verify normal capture
- [ ] Screen recording with protection on → Verify black recording
- [ ] Video playback with protection on → Verify playback works normally
- [ ] Toggle protection multiple times → Verify state consistency

#### iOS
- [ ] Enable protection → Take screenshot → Verify warning dialog appears
- [ ] Enable protection → Start screen recording → Verify blur overlay appears
- [ ] Enable protection → Stop screen recording → Verify blur overlay disappears
- [ ] Disable protection → Take screenshot → Verify no warning
- [ ] Disable protection → Screen recording → Verify no blur

#### Settings Integration
- [ ] Profile page → Verify "Screenshot Protection" row shows correct status
- [ ] Profile edit page → Toggle protection → Save → Verify persisted
- [ ] Sign out and back in → Verify setting is maintained
- [ ] New user → Verify protection is enabled by default

### Automated Testing

```dart
// Widget tests for components
test('ScreenshotWarningDialog shows correct content', () { ... });
test('ScreenshotBlurOverlay renders blur effect', () { ... });

// Integration tests
test('Toggle protection updates Firestore', () { ... });
test('Screenshot detection triggers analytics event', () { ... });

// Platform tests
testWidgets('Android FLAG_SECURE is applied', (tester) async { ... });
testWidgets('iOS method channel communicates correctly', (tester) async { ... });
```

### Test Devices

- **Android**: Test on API 28+ (required for flutter_windowmanager)
- **iOS**: Test on iOS 11+ (required for isCaptured detection)
- **Both**: Test on physical devices (simulators may not trigger screenshot APIs correctly)

## Known Issues

1. **Android Emulator**: FLAG_SECURE may not work correctly on emulators
2. **iOS Simulator**: Screenshot detection does not work in simulator (hardware-only feature)
3. **Video Calls**: Some video calling SDKs may conflict with FLAG_SECURE

## Dependencies

- `flutter_windowmanager: ^0.2.0` - Android FLAG_SECURE support
- Native platform channels - iOS detection

## Future Enhancements

1. **Watermarking**: Add user-specific watermarks to sensitive content
2. **Analytics Dashboard**: Admin view of screenshot attempt statistics
3. **Graduated Response**: Multiple warnings before account action
4. **Content-Specific**: Apply protection only to specific post types
5. **Web Overlay**: Privacy reminder overlay for web platform

## References

- [Android FLAG_SECURE Documentation](https://developer.android.com/reference/android/view/WindowManager.LayoutParams#FLAG_SECURE)
- [iOS UIScreen isCaptured Documentation](https://developer.apple.com/documentation/uikit/uiscreen/2921651-iscaptured)
- [iOS Screenshot Detection](https://developer.apple.com/documentation/uikit/uiapplication/1622966-userdidtakescreenshotnotificatio)

## Support

For issues or questions:
- Check GitHub issues for known problems
- Contact development team
- Review platform-specific documentation links above
