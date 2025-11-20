# Animation Integration Guide

This document describes the Rive and Lottie animation integration in TeenTalk.

## Overview

The app now supports:
- **Rive animations** for splash screen and intro overlay
- **Lottie animations** for onboarding, loading states, and empty states
- **Lazy loading** with offline fallbacks
- **Test-friendly toggles** for CI/CD

## Architecture

### Asset Management

All animation paths are centralized in `lib/src/core/constants/tt_assets.dart`:

```dart
class TTAssets {
  static const String riveSplashLogo = 'assets/animations/rive/splash_logo.riv';
  static const String riveIntroBackground = 'assets/animations/rive/intro_background.riv';
  static const String lottieOnboardingWelcome = 'assets/animations/lottie/onboarding_welcome.json';
  static const String lottieEmptyState = 'assets/animations/lottie/empty_state.json';
  // ... more paths
}
```

### Preference Management

Animation preferences are managed through:
- `lib/src/core/services/animation_preferences_service.dart` - SharedPreferences wrapper
- `lib/src/core/providers/animation_preferences_provider.dart` - Riverpod providers

Key preferences:
- `has_seen_intro` - Whether user has seen the first-run intro
- `motion_enabled` - User's motion preference (default: true)

### Environment Variables

For testing/CI, use the environment variable:
```bash
flutter test --dart-define=SKIP_SPLASH_ANIMATION=true
```

## Components

### 1. RiveSplash Widget

**Location:** `lib/src/core/widgets/rive_splash.dart`

Displays the TeenTalk logo Rive animation on app launch.

**Features:**
- Max duration: 1.5 seconds
- Platform detection (graceful degradation on unsupported platforms)
- Fallback to static logo if animation fails to load
- Respects `shouldAnimate` parameter
- Calls `onAnimationComplete` callback when done

**Usage:**
```dart
RiveSplash(
  onAnimationComplete: () {
    // Navigate to next screen
  },
  shouldAnimate: true,
  maxDuration: Duration(milliseconds: 1500),
)
```

### 2. FirstRunIntroOverlay Widget

**Location:** `lib/src/core/widgets/first_run_intro_overlay.dart`

Shows a one-time intro dialog with Rive background animation.

**Features:**
- Full-screen overlay with animated background
- Skip/Continue buttons
- Persists completion via SharedPreferences
- Respects motion preferences

**Usage:**
```dart
FirstRunIntroOverlay(
  shouldAnimate: true,
  onContinue: () { /* proceed */ },
  onSkip: () { /* skip */ },
)
```

### 3. LazyLottie Widget

**Location:** `lib/src/core/widgets/lazy_lottie.dart`

Reusable Lottie animation player with lazy loading and fallbacks.

**Features:**
- Lazy loading with loading indicator
- Offline detection (uses connectivity provider)
- Fallback to static icon/message on error or offline
- Configurable size, fit, and repeat
- Respects motion preferences

**Usage:**
```dart
LazyLottie(
  assetPath: TTAssets.lottieEmptyState,
  shouldAnimate: true,
  width: 200,
  height: 200,
  fallbackIcon: Icons.sentiment_satisfied,
  fallbackMessage: 'No items',
)
```

## Integration Points

### Splash Screen

**File:** `lib/src/features/auth/presentation/pages/splash_page.dart`

The splash page now:
1. Checks if user has seen intro (`has_seen_intro` preference)
2. Checks if motion is enabled
3. Checks environment variable `SKIP_SPLASH_ANIMATION`
4. Shows RiveSplash if conditions are met
5. Shows FirstRunIntroOverlay after splash (first run only)
6. Falls back to standard splash screen for normal loading

### Empty States

#### Feed Empty State
**File:** `lib/src/features/feed/presentation/widgets/empty_state_widget.dart`

Now uses `LazyLottie` with fallback icon based on feed section.

#### Comments Empty State
**File:** `lib/src/features/comments/presentation/widgets/comments_list_widget.dart`

Uses `LazyLottie` in the `_buildEmptyState` method.

### Onboarding

**File:** `lib/src/features/onboarding/presentation/widgets/nickname_step.dart`

The first onboarding step now displays a welcome Lottie animation instead of a static icon.

## Asset Requirements

### Rive Assets

Place in `assets/animations/rive/`:

1. **splash_logo.riv**
   - TeenTalk logo animation
   - Duration: ≤1.5 seconds
   - Should have a "State Machine 1" controller (or adjust code)
   - Optimized for mobile/web

2. **intro_background.riv**
   - Background animation for intro overlay
   - Should loop seamlessly
   - Can be abstract/decorative

### Lottie Assets

Place in `assets/animations/lottie/`:

1. **onboarding_welcome.json**
   - Welcome animation for onboarding
   - Should convey friendliness/welcome

2. **empty_state.json**
   - Generic empty state animation
   - Should convey "nothing here yet"

3. **loading.json** (optional)
   - Loading spinner/animation

4. **success.json** (optional)
   - Success confirmation animation

### Asset Guidelines

- **File sizes**: Keep under 500KB each
- **Rive**: Export for runtime (not editor)
- **Lottie**: Standard JSON export from After Effects
- **Testing**: Test on both light and dark themes
- **Offline**: Ensure fallbacks work when assets can't load

## Testing

### Manual Testing

1. **First run experience:**
   ```bash
   # Clear app data, then launch
   flutter run
   ```
   - Should see Rive splash
   - Should see intro overlay
   - Should not see them on second launch

2. **Skip animations:**
   ```bash
   flutter run --dart-define=SKIP_SPLASH_ANIMATION=true
   ```
   - Should skip to loading screen immediately

3. **Offline mode:**
   - Disable network
   - Check empty states show fallback icons
   - Re-enable network
   - Animations should load

4. **Motion disabled:**
   - Set `motion_enabled` to false in SharedPreferences
   - All animations should show static fallbacks

### Automated Testing

Run tests with animation skip:
```bash
flutter test --dart-define=SKIP_SPLASH_ANIMATION=true
```

### CI/CD

The GitHub Actions workflow should pass `SKIP_SPLASH_ANIMATION=true` to avoid animation-related issues in headless environments.

## Performance Considerations

1. **Lazy loading**: Lottie animations load on-demand, not at startup
2. **Caching**: Lottie uses Flutter's asset bundle caching
3. **Rive efficiency**: Rive is GPU-accelerated and highly performant
4. **Graceful degradation**: Unsupported platforms fall back to static UI
5. **Motion preferences**: Users can disable animations to improve performance

## Migration Notes

If you're migrating from a version without animations:

1. Existing users will NOT see the splash animation (one-time only)
2. The intro overlay is also one-time
3. All other animations appear as enhancements to existing empty/loading states
4. No breaking changes to existing functionality
5. Tests remain stable with `SKIP_SPLASH_ANIMATION=true`

## Troubleshooting

### Animations not showing

1. Check `motion_enabled` in SharedPreferences
2. Verify asset files exist in correct directories
3. Check console for load errors
4. Ensure `pubspec.yaml` includes asset paths
5. Run `flutter clean && flutter pub get`

### Performance issues

1. Reduce animation complexity
2. Disable motion via preferences
3. Use `SKIP_SPLASH_ANIMATION` environment variable
4. Check asset file sizes (should be < 500KB)

### CI/CD failures

1. Ensure tests use `--dart-define=SKIP_SPLASH_ANIMATION=true`
2. Mock animation preferences service in tests
3. Use golden tests sparingly (animations may cause flakiness)

## Future Enhancements

Potential improvements:

1. **Reduced motion**: Detect OS-level reduced motion preference
2. **Preloading**: Preload critical Lottie animations at startup
3. **Analytics**: Track animation load failures
4. **A/B testing**: Test different animations
5. **Customization**: Let users choose from animation themes
6. **More animations**: Add success, error, loading variations

## Dependencies

- `rive: ^0.12.4` - Rive animation runtime
- `lottie: ^2.7.0` - Lottie animation player
- `shared_preferences: ^2.2.2` - Preference storage
- `connectivity_plus: ^5.0.2` - Offline detection

## References

- [Rive Documentation](https://rive.app/resources/)
- [Lottie Flutter Package](https://pub.dev/packages/lottie)
- [Material Design Motion](https://material.io/design/motion/)
- [WCAG 2.2 Animation Guidelines](https://www.w3.org/WAI/WCAG22/Understanding/animation-from-interactions)
