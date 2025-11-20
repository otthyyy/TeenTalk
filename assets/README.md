# TeenTalk App Assets

This directory contains all the visual assets for the TeenTalk Flutter application.

## Directory Structure

### `branding/`
Source artwork for automated launcher icons and splash screens generated via `flutter_launcher_icons` and `flutter_native_splash`.

### `images/`
Contains image assets like logos, splash screens, and other graphics.

### `icons/`
Contains navigation and UI icons following Material Design guidelines.

## Placeholder Files

All `.placeholder` files should be replaced with actual PNG images before building for production.

### Required Images

#### App Logo
- `logo.png` (1x) - Standard resolution
- `logo@2x.png` (2x) - High resolution (Retina)
- `logo@3x.png` (3x) - Ultra high resolution

#### Splash Screen
- `splash.png` (1x) - Standard resolution
- `splash@2x.png` (2x) - High resolution
- `splash@3x.png` (3x) - Ultra high resolution

### Required Icons

#### Navigation Icons (Material Design)
- `home.png` - Home screen navigation
- `chat.png` - Chat/messages navigation
- `profile.png` - User profile navigation
- `settings.png` - Settings navigation

## Image Specifications

### Images
- **Format**: PNG
- **Color Mode**: RGB
- **Transparency**: Supported where needed

### Icons
- **Format**: PNG with transparency
- **Size**: 24dp (Material Design standard)
- **Resolution**: 
  - 1x: 24x24px
  - 2x: 48x48px
  - 3x: 72x72px

## Usage in Code

After replacing placeholder files with actual images, reference them in Flutter code like this:

```dart
// Images
Image.asset('assets/images/logo.png')
Image.asset('assets/images/splash.png')

// Icons
Image.asset('assets/icons/home.png')
Image.asset('assets/icons/chat.png')
```

## Flutter Asset Configuration

The `pubspec.yaml` file is already configured to include these assets:

```yaml
flutter:
  assets:
    - assets/images/
    - assets/icons/
```

## Branding Assets

### `branding/` - Automated Icon & Splash Generation
This directory contains the source artwork for TeenTalk's branded launcher icons and splash screens. Use these commands to regenerate platform assets:

```sh
# Regenerate launcher icons (Android, iOS, web, macOS, Windows, Linux)
flutter pub run flutter_launcher_icons

# Regenerate splash screens (Android, iOS, web)
flutter pub run flutter_native_splash:create
```

**Source Files:**
- `app_icon.png` (1024×1024) - Gradient icon with TeenTalk chat bubble logo
- `splash_logo.png` (512×512) - Transparent logo for splash screens
- `splash_background_light.png` - Light mode gradient background
- `splash_background_dark.png` - Dark mode gradient background

No manual editing of platform-specific folders required. These tools automatically generate all density-specific icons and splash screens.

## Icon System and Asset Pipeline

### Naming Conventions
All asset files must follow **kebab-case** naming (lowercase with hyphens):
- ✅ Good: `profile-icon.png`, `loading-animation.json`, `success-checkmark.riv`
- ❌ Bad: `ProfileIcon.png`, `loading_animation.json`, `SuccessCheckmark.riv`

### Storage Locations

#### Icons (Package-based)
The app uses the `remixicon` and `feather_icons` packages for all primary navigation and action icons. Access them via the `TTIcons` class:
```dart
import 'package:teen_talk_app/src/core/theme/app_icons.dart';

Icon(TTIcons.home)           // Primary state
Icon(TTIcons.homeFilled)     // Active/selected state
```

#### Custom Icons/Images
For custom icons or images not available in the icon packages:
- Location: `assets/icons/`
- Usage: Reference via `TTAssets` class
```dart
import 'package:teen_talk_app/src/core/constants/tt_assets.dart';

Image.asset(TTAssets.icon('custom-icon-name.png'))
// Or for predefined icons:
Image.asset(TTAssets.iconsGoogle)
```

#### Animations

**Rive Animations**
- Location: `assets/animations/rive/`
- Supported formats: `.riv`
- Usage:
```dart
import 'package:teen_talk_app/src/core/constants/tt_assets.dart';
RiveAnimation.asset(TTAssets.rive('loading-spinner.riv'))
```

**Lottie Animations**
- Location: `assets/animations/lottie/`
- Supported formats: `.json`
- Usage:
```dart
import 'package:teen_talk_app/src/core/constants/tt_assets.dart';
Lottie.asset(TTAssets.lottie('success-animation.json'))
```

### Adding New Assets

#### Icons
1. For standard UI icons, check if they exist in `TTIcons` first (covers 200+ icons)
2. For custom icons:
   - Add file to `assets/icons/` with kebab-case name
   - Use PNG format with transparency
   - Provide @2x and @3x variants for different densities
   - Reference via `TTAssets.icon('file-name.png')`

#### Animations
1. For Rive animations:
   - Export from Rive editor as `.riv` file
   - Use kebab-case naming
   - Place in `assets/animations/rive/`
   - Reference via `TTAssets.rive('animation-name.riv')`

2. For Lottie animations:
   - Export from After Effects or use LottieFiles
   - Use kebab-case naming
   - Place in `assets/animations/lottie/`
   - Reference via `TTAssets.lottie('animation-name.json')`

### Icon Sizes and Accessibility
All icons follow design tokens from `DesignTokens`:
- **Small**: 16dp (secondary actions)
- **Medium**: 20dp (inline actions)
- **Default**: 24dp (primary actions)
- **Large**: 32dp (featured actions)
- **Extra Large**: 40dp (hero elements)

**Important**: All interactive icon buttons must have a minimum tap target of 44dp × 44dp for accessibility. Use appropriate padding to ensure this.

### Asset Pipeline Checklist
When adding assets:
1. ✅ Use kebab-case naming
2. ✅ Place in correct directory (`icons/`, `animations/rive/`, or `animations/lottie/`)
3. ✅ Update `TTAssets` if adding predefined constants
4. ✅ For images: provide @2x and @3x variants
5. ✅ Run `flutter pub get` after updating `pubspec.yaml`
6. ✅ Test on multiple screen densities and dark/light themes

## Testing

After adding actual images, run `flutter pub get` and test the app with `flutter run` to ensure all assets load correctly on different platforms.