# TeenTalk Asset Setup Summary

## ✅ Branding Assets Updated
- Added a dedicated `assets/branding/` directory containing production-ready TeenTalk visuals:
  - `app_icon.png` – 1024×1024 gradient launcher icon source
  - `splash_logo.png` – transparent 512×512 logo for center-aligned splash artwork
  - `splash_background_light.png` – light mode gradient splash background
  - `splash_background_dark.png` – dark mode gradient splash background
- Updated `.gitignore` to exclude local Python virtual environments used for asset generation helpers.

## ⚙️ Automated Asset Tooling
- Added `flutter_launcher_icons` (^0.13.1) and `flutter_native_splash` (^2.3.10) to `dev_dependencies`.
- Configured both tools directly in `pubspec.yaml` so assets can be regenerated from source PNGs at any time.

### Regenerating Launcher Icons
```sh
flutter pub run flutter_launcher_icons
```
Generates updated launcher/app icons for Android (adaptive + legacy), iOS, web (including favicon/PWA icons with theme color), macOS, Windows, and Linux.

### Regenerating Native Splash Screens
```sh
flutter pub run flutter_native_splash:create
```
Creates branded splash screens for Android, Android 12+, iOS, and web using:
- Gradient light & dark backgrounds
- Centered TeenTalk chat badge logo
- Dark mode overrides for high-contrast experiences

## 🔍 QA Checklist
- Launch the app on Android, iOS, and web to confirm the new gradient splash appears instantly and respects light/dark themes.
- Inspect launcher icons on high-DPI devices and pinned web apps for crisp edges and correct safe-zone spacing.
- Re-run the generation commands above whenever branding updates occur; no manual editing of platform folders is required.

## 📁 Updated Asset Structure
```
assets/
├── README.md
├── branding/
│   ├── app_icon.png
│   ├── splash_background_dark.png
│   ├── splash_background_light.png
│   └── splash_logo.png
├── icons/
│   ├── chat.png.placeholder
│   ├── google.svg
│   ├── home.png.placeholder
│   ├── incognito.svg
│   ├── profile.png.placeholder
│   └── settings.png.placeholder
└── images/
    ├── logo.png.placeholder
    ├── logo@2x.png.placeholder
    ├── logo@3x.png.placeholder
    ├── splash.png.placeholder
    ├── splash@2x.png.placeholder
    └── splash@3x.png.placeholder
```

TeenTalk branding assets are now automated and ready for production releases across all supported platforms.
