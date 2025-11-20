# TeenTalk Style & Motion Guide

This guide describes the design system, motion principles, and asset conventions for TeenTalk.

## Table of Contents

- [Color Palette](#color-palette)
- [Typography](#typography)
- [Spacing & Layout](#spacing--layout)
- [Motion System](#motion-system)
- [Icons & Assets](#icons--assets)
- [Accessibility](#accessibility)

## Color Palette

TeenTalk uses Material Design 3 theming with custom color schemes for light and dark modes.

### Light Theme
- **Primary**: Material Blue (#2196F3)
- **Secondary**: Material Orange (#FF9800)
- **Surface**: White (#FFFFFF)
- **Background**: Light Grey (#F5F5F5)
- **Error**: Red (#F44336)

### Dark Theme
- **Primary**: Light Blue (#64B5F6)
- **Secondary**: Light Orange (#FFB74D)
- **Surface**: Dark Grey (#1E1E1E)
- **Background**: Darker Grey (#121212)
- **Error**: Light Red (#EF5350)

### High Contrast Mode
When `prefersHighContrast` is enabled:
- Increase contrast ratios to meet WCAG AAA standards (7:1 minimum)
- Use stronger text weights (e.g., w600 instead of w400)
- Increase border widths and visual separation
- Use more saturated colors for interactive elements

### WCAG Compliance
All color combinations must meet **WCAG AA** standards (4.5:1 contrast ratio for normal text, 3:1 for large text). Use high contrast mode to achieve WCAG AAA (7:1) when needed.

## Typography

TeenTalk uses the default system font (Roboto on Android, SF Pro on iOS, Segoe UI on Windows).

### Text Styles
- **Display Large**: 57sp, w400
- **Display Medium**: 45sp, w400
- **Display Small**: 36sp, w400
- **Headline Large**: 32sp, w400
- **Headline Medium**: 28sp, w400
- **Headline Small**: 24sp, w400
- **Title Large**: 22sp, w500
- **Title Medium**: 16sp, w500
- **Title Small**: 14sp, w500
- **Body Large**: 16sp, w400
- **Body Medium**: 14sp, w400
- **Body Small**: 12sp, w400
- **Label Large**: 14sp, w500
- **Label Medium**: 12sp, w500
- **Label Small**: 11sp, w500

### Dynamic Text Scaling
All text must support iOS/Android dynamic text scaling. Test with:
- Small text (0.85x)
- Default text (1.0x)
- Large text (1.3x)
- Extra large text (1.7x)

Use `MediaQuery.textScalerOf(context)` to get the current text scale factor. Avoid hardcoded text sizes in layouts that can cause overflow.

## Spacing & Layout

### Spacing Scale
Use consistent spacing values throughout the app:
- **4px**: Micro spacing (between icon and label)
- **8px**: Small spacing (list item padding)
- **12px**: Medium spacing (card content padding)
- **16px**: Default spacing (horizontal screen padding)
- **20px**: Large spacing (vertical section spacing)
- **24px**: Extra large spacing (section headers)
- **32px**: Section divider spacing

### Border Radius
- **Small**: 8px (buttons, chips)
- **Medium**: 12px (cards, containers)
- **Large**: 16px (bottom sheets, dialogs)
- **Extra large**: 24px (hero images)
- **Circle**: 50% (avatars, FABs)

### Elevation
- **Level 0**: No shadow (background, surface)
- **Level 1**: 1dp (cards, list items)
- **Level 2**: 2dp (app bar, elevated cards)
- **Level 3**: 4dp (FAB, dialogs)
- **Level 4**: 6dp (navigation drawer)
- **Level 5**: 8dp (modal bottom sheets)

## Motion System

TeenTalk implements a comprehensive motion system that respects user accessibility preferences.

### Motion Preferences

Users can control motion behavior through three settings:

1. **Reduced Motion** (`prefersReducedMotion`): Minimizes animations and transitions
2. **High Contrast** (`prefersHighContrast`): Increases visual contrast (not motion-related but affects design)
3. **Heavy Animations** (`allowHeavyAnimations`): Enables experimental/intensive animations (Beta feature)

#### Platform Integration
The app checks platform accessibility settings via the `MotionPreferencesService`:
- iOS: `UIAccessibilityIsReduceMotionEnabled`
- Android: Settings.Secure.TRANSITION_ANIMATION_SCALE
- Web: prefers-reduced-motion media query

### Animation Durations

#### Standard Durations
- **Instant**: 0ms (reduced motion: 0ms)
- **Quick**: 100ms (reduced motion: 0ms)
- **Fast**: 200ms (reduced motion: 100ms)
- **Standard**: 300ms (reduced motion: 150ms)
- **Slow**: 500ms (reduced motion: 200ms)
- **Sluggish**: 800ms (reduced motion: 300ms)

#### Heavy Animation Durations
These only run when `allowHeavyAnimations` is true:
- **Hero transitions**: 600ms
- **Page transitions**: 500ms
- **Complex staggered animations**: 800-1200ms
- **Lottie/Rive animations**: Varies per asset

### Easing Curves

Use Material Design easing curves:

```dart
// Standard easing (most animations)
Curves.easeInOut

// Emphasized easing (hero transitions, important actions)
Curves.fastOutSlowIn

// Deceleration (incoming elements)
Curves.decelerate

// Acceleration (outgoing elements)
Curves.accelerate

// Linear (progress indicators, loading)
Curves.linear
```

### Motion Guidelines

#### When to Animate
- **Do**: Page transitions, state changes, feedback, progressive disclosure
- **Don't**: Decorative animations, continuous looping, distracting motion

#### Respecting Motion Preferences

Always check motion preferences before animating:

```dart
// Import the motion preferences provider
import 'package:spotted/src/core/providers/motion_preferences_provider.dart';

// In your widget
@override
Widget build(BuildContext context, WidgetRef ref) {
  final motionPrefs = ref.watch(motionPreferencesProvider);
  
  // Short-circuit heavy animations
  if (motionPrefs.shouldDisableAnimations) {
    return MyStaticWidget();
  }
  
  // Standard animation
  return AnimatedContainer(
    duration: Duration(
      milliseconds: motionPrefs.prefersReducedMotion ? 150 : 300,
    ),
    curve: Curves.easeInOut,
    child: MyWidget(),
  );
}
```

#### Interruptible Animations

All animations must be interruptible (user can navigate away without waiting):

```dart
// Use AnimatedWidget or explicitly check mounted state
class MyAnimatedWidget extends StatefulWidget {
  // ...
}

class _MyAnimatedWidgetState extends State<MyAnimatedWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose(); // Always dispose controllers
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        // Animation logic
      },
    );
  }
}
```

#### Staggered Animations

For staggered list animations, ensure they can be interrupted:

```dart
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

AnimationConfiguration.staggeredList(
  position: index,
  duration: motionPrefs.prefersReducedMotion 
    ? const Duration(milliseconds: 100)
    : const Duration(milliseconds: 375),
  child: SlideAnimation(
    verticalOffset: 50.0,
    child: FadeInAnimation(
      child: MyListItem(),
    ),
  ),
);
```

### Empty State Animations

For empty states, use lightweight animations or static illustrations when motion is reduced:

```dart
Widget _buildEmptyState(MotionPreferences motionPrefs) {
  if (motionPrefs.shouldDisableAnimations) {
    return Icon(
      Icons.chat_bubble_outline_rounded,
      size: 80,
      color: Colors.grey[300],
    );
  }
  
  // Only load heavy animation asset when allowed
  if (motionPrefs.allowHeavyAnimations) {
    return LazyLottie(
      assetPath: 'assets/animations/empty_messages.json',
      width: 200,
      height: 200,
    );
  }
  
  // Standard animation
  return TweenAnimationBuilder<double>(
    duration: const Duration(milliseconds: 500),
    tween: Tween(begin: 0.0, end: 1.0),
    builder: (context, value, child) {
      return Opacity(
        opacity: value,
        child: Transform.scale(
          scale: 0.8 + (0.2 * value),
          child: child,
        ),
      );
    },
    child: Icon(
      Icons.chat_bubble_outline_rounded,
      size: 80,
      color: Colors.grey[300],
    ),
  );
}
```

## Icons & Assets

### Icon Sets

TeenTalk uses two primary icon sets:

1. **Material Icons** (default): Built-in Flutter Material Icons
2. **Remix Icon** (optional): For unique/branded icons (see `assets/icons/`)

#### When to Use Which
- **Material Icons**: Standard UI elements (navigation, actions, status)
- **Remix Icon**: Brand-specific icons, social features, custom illustrations

### Asset Organization

```
assets/
├── animations/          # Lottie (.json) and Rive (.riv) animations
│   ├── onboarding/     # Onboarding flow animations
│   ├── empty_states/   # Empty state illustrations
│   └── feedback/       # Loading, success, error animations
├── icons/              # Custom icon sets (SVG or PNG)
│   └── remix/          # Remix Icon set
├── images/             # Static images (JPEG, PNG, WebP)
│   ├── branding/       # Logos, splash screens
│   ├── placeholders/   # Profile avatars, image placeholders
│   └── illustrations/  # Marketing, onboarding illustrations
└── fonts/              # Custom fonts (if any)
```

### Lazy Loading Animations

For performance, use lazy loading for heavy animation assets:

```dart
// Only load when in viewport and motion allowed
class LazyLottie extends StatelessWidget {
  final String assetPath;
  final double width;
  final double height;

  const LazyLottie({
    required this.assetPath,
    this.width = 200,
    this.height = 200,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Lottie.asset(
        assetPath,
        width: width,
        height: height,
        fit: BoxFit.contain,
        repeat: false,
      ),
    );
  }
}
```

### Adding New Animations

1. Export your animation as Lottie JSON or Rive file
2. Place in appropriate `assets/animations/` subfolder
3. Add to `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/animations/my_animation.json
   ```
4. Use with motion preference checks:
   ```dart
   if (!motionPrefs.shouldDisableAnimations && motionPrefs.allowHeavyAnimations) {
     return Lottie.asset('assets/animations/my_animation.json');
   }
   ```

### Image Optimization

- Use **WebP** format for images when possible (smaller size, better quality)
- Provide 1x, 2x, 3x variants for different DPIs:
  ```
  assets/images/
  ├── logo.webp       # 1x
  ├── 2.0x/
  │   └── logo.webp   # 2x
  └── 3.0x/
      └── logo.webp   # 3x
  ```
- Compress images with tools like `imagemin` or `squoosh`
- Use vector (SVG) when possible for icons and simple illustrations

## Accessibility

### Semantic Labels

All interactive elements must have semantic labels:

```dart
Semantics(
  label: 'Send message',
  button: true,
  child: IconButton(
    icon: Icon(Icons.send),
    onPressed: _sendMessage,
  ),
);
```

### Focus Management

Support keyboard navigation and screen readers:

```dart
Focus(
  autofocus: true,
  child: TextField(
    decoration: InputDecoration(
      labelText: 'Message',
      hintText: 'Type your message here',
    ),
  ),
);
```

### Testing Accessibility

Test with:
- **VoiceOver** (iOS): Settings > Accessibility > VoiceOver
- **TalkBack** (Android): Settings > Accessibility > TalkBack
- **Keyboard Navigation**: Tab through all interactive elements
- **Text Scaling**: Settings > Display > Font size (increase to max)
- **Reduced Motion**: Settings > Accessibility > Motion > Reduce Motion
- **High Contrast**: Settings > Accessibility > Display > Increase Contrast

### Accessibility Checklist

- [ ] All images have `semanticLabel` or are marked `excludeFromSemantics: true` if decorative
- [ ] All buttons have clear labels
- [ ] Color is not the only indicator of state (use icons, text, or patterns)
- [ ] Touch targets are at least 44x44 points (iOS) or 48x48 dp (Android)
- [ ] Text scales properly without overflow
- [ ] Animations respect `prefersReducedMotion`
- [ ] Focus order is logical (top to bottom, left to right)

## Feature Flags

### Heavy Animations Flag

The `allowHeavyAnimations` preference is a **developer/beta feature** that enables resource-intensive animations:

- **Default**: `false` (disabled for all users)
- **Purpose**: Test complex animations in beta builds without affecting production users
- **Location**: Profile > Accessibility & Motion > Heavy Animations (Beta)

To use in code:

```dart
final motionPrefs = ref.watch(motionPreferencesProvider);

if (motionPrefs.allowHeavyAnimations) {
  // Show complex Lottie animation
  return LazyLottie(assetPath: 'assets/animations/hero.json');
}

// Fallback to simple animation
return Icon(Icons.star, size: 64);
```

### Disabling Heavy Animations in Dev/Test

To disable heavy animations during testing:

```dart
// In test setup
final container = ProviderContainer(
  overrides: [
    motionPreferencesServiceProvider.overrideWith((ref) {
      final mockPrefs = MockSharedPreferences();
      return MotionPreferencesService(mockPrefs)
        ..setAllowHeavyAnimations(false);
    }),
  ],
);
```

## Additional Resources

- [Material Design 3 Guidelines](https://m3.material.io/)
- [Flutter Animation Basics](https://docs.flutter.dev/ui/animations)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [iOS Human Interface Guidelines - Motion](https://developer.apple.com/design/human-interface-guidelines/motion)
- [Android Motion Guidelines](https://material.io/design/motion/)

---

## Contributing to the Style Guide

When adding new patterns or updating existing ones:

1. Update this guide with examples and rationale
2. Ensure changes align with accessibility standards
3. Add visual examples in `docs/style_guide_examples/` (if applicable)
4. Update `assets/README.md` to document new assets or icon usage
5. Test changes across different accessibility settings

For questions or suggestions, contact the design team or open an issue in the repository.
