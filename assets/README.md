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

## Testing

After adding actual images, run `flutter pub get` and test the app with `flutter run` to ensure all assets load correctly on different platforms.