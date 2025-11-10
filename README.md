# TeenTalk Flutter App

A modern Flutter application for teen social communication, built with clean architecture and best practices.

## 🏗️ Project Structure

The app follows a clean architecture pattern with the following structure:

```
lib/
├── main.dart                 # App entry point
├── gen/                      # Generated files (Flutter Gen)
└── src/
    ├── core/                 # Core utilities and configurations
    │   ├── theme/
    │   │   ├── app_theme.dart      # App theming (light/dark modes)
    │   │   └── theme_provider.dart # Riverpod theme state management
    │   ├── router/
    │   │   └── app_router.dart     # GoRouter configuration
    │   └── utils/
    │       └── app_utils.dart      # Common utilities and constants
    ├── features/             # Feature modules
    │   ├── feed/             # Feed feature
    │   │   └── presentation/pages/feed_page.dart
    │   ├── messages/         # Messages feature
    │   │   └── presentation/pages/messages_page.dart
    │   ├── profile/          # Profile feature
    │   │   └── presentation/pages/profile_page.dart
    │   └── admin/            # Admin panel feature
    │       └── presentation/pages/admin_page.dart
    ├── common/              # Shared components
    │   └── widgets/
    │       ├── loading_widget.dart  # Loading indicator
    │       └── error_widget.dart    # Error display widget
    └── services/            # Business logic and external services
        └── base_service.dart        # Service base classes
```

## 🛠️ Tech Stack

- **Framework**: Flutter 3.19.6
- **State Management**: Riverpod 2.4.9
- **Routing**: GoRouter 12.1.3
- **Code Generation**: 
  - Freezed for immutable models
  - JSON Serializable for API serialization
  - Flutter Gen for asset management
- **Architecture**: Clean Architecture with feature-first approach
- **Theming**: Material 3 with custom TeenTalk branding

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.3.4)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- For mobile: Android SDK and/or Xcode for iOS

### Setup Instructions

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd teen_talk_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run code generation** (if needed)
   ```bash
   flutter packages pub run build_runner build
   ```

4. **Run the app**
   ```bash
   # For development
   flutter run
   
   # Specific platform
   flutter run -d chrome     # Web
   flutter run -d android     # Android (requires emulator/device)
   flutter run -d ios         # iOS (requires simulator/device)
   ```

5. **Build for production**
   ```bash
   # Android APK
   flutter build apk --release
   
   # Android App Bundle
   flutter build appbundle --release
   
   # iOS
   flutter build ios --release
   
   # Web
   flutter build web --release
   ```

## 🎨 Theming

The app includes a comprehensive theming system with:

- **Light/Dark Mode Support**: Automatic system theme detection with manual override
- **TeenTalk Brand Colors**: Purple primary, pink secondary, emerald accent
- **Typography**: Consistent text styles following Material 3 guidelines
- **Custom Components**: Themed buttons, cards, and navigation elements

### Theme Customization

Colors and styles are defined in `lib/src/core/theme/app_theme.dart`. 
Theme state is managed through Riverpod in `theme_provider.dart`.

## 🧪 Testing

Run the test suite:

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart

# Run accessibility tests
flutter test test/a11y/

# Update golden test files
flutter test --update-goldens test/a11y/
```

### Accessibility Testing

The app includes comprehensive accessibility tests to ensure features remain accessible:

- **Semantic Label Tests**: Verify screen reader labels are present
- **Golden Tests**: Check UI rendering at 1.3x and 2.0x text scales
- **Overflow Tests**: Ensure no text overflow at increased scales
- **Color Contrast Tests**: Validate WCAG AA contrast requirements

See [docs/ACCESSIBILITY_TESTING.md](docs/ACCESSIBILITY_TESTING.md) for detailed information.

## 📱 Features

### Current Implementation

- ✅ **Navigation Shell**: Bottom tab navigation with Feed, Messages, Profile, Admin
- ✅ **Theming System**: Light/dark mode with TeenTalk branding
- ✅ **Responsive Layout**: Adaptive design for different screen sizes
- ✅ **Code Structure**: Clean architecture with proper separation of concerns
- ✅ **State Management**: Riverpod integration for reactive state
- ✅ **Code Generation**: Setup for models, JSON serialization, and assets

### Placeholder Pages

Each feature currently has a placeholder page with basic structure:
- **Feed**: Social feed placeholder
- **Messages**: Chat interface placeholder  
- **Profile**: User profile placeholder
- **Admin**: Administrative panel placeholder

## 🔧 Development Guidelines

### Code Style

- Follow Flutter/Dart conventions with `flutter_lints`
- Use `prefer_single_quotes` for strings
- Apply `prefer_const_constructors` where possible
- Order constructors before other class members

### Adding New Features

1. Create feature directory under `lib/src/features/`
2. Follow the pattern: `presentation/pages/`, `domain/`, `data/`
3. Add routes to `app_router.dart`
4. Update navigation if needed
5. Add appropriate tests

### Asset Management

- Place images in `assets/images/`
- Place icons in `assets/icons/`
- Run `flutter packages pub run build_runner build` to generate asset references
- Access generated assets via `Assets.images.<filename>`

## 📦 Dependency Management

Dependencies are managed in `pubspec.yaml`:

- **Dependencies**: Runtime packages
- **Dev Dependencies**: Development tools (code generation, testing, linting)

To update dependencies:
```bash
# Get latest compatible versions
flutter pub upgrade

# Check for outdated packages
flutter pub outdated
```

## 🐛 Bug Fixes

See [docs/BUG_FIXES.md](docs/BUG_FIXES.md) for detailed information about critical bug fixes including:

1. **Like/Unlike Error Handling**: Fixed unhandled exceptions when liking posts
2. **ref.listen Assertion**: Fixed Riverpod ref.listen usage in widgets
3. **Image Upload Crashes**: Added web support and comprehensive error handling
4. **UI Overlap**: Fixed bottom navigation covering content on various devices

## 📱 Permissions

### Android
The app requires the following permissions (already configured in `AndroidManifest.xml`):
- `CAMERA` - For taking photos
- `READ_EXTERNAL_STORAGE` - For selecting images from gallery
- `WRITE_EXTERNAL_STORAGE` - For saving images
- `INTERNET` - For network operations

### iOS
The following permissions are configured in `Info.plist`:
- `NSCameraUsageDescription` - Camera access for photos
- `NSPhotoLibraryUsageDescription` - Photo library access for image selection
- `NSPhotoLibraryAddUsageDescription` - Photo library write access

## 🔍 Code Analysis

Run static analysis to ensure code quality:

```bash
# Analyze entire project
flutter analyze

# Fix formatting issues
dart format .

# Run with specific options
flutter analyze --fatal-infos
```

## 🚀 Deployment

### Android

1. Configure signing keys in `android/app/build.gradle`
2. Update version in `pubspec.yaml`
3. Build release APK/AAB
4. Upload to Google Play Console

### iOS

1. Configure app in Xcode
2. Update version and build numbers
3. Archive and upload to App Store Connect

### Web

1. Build web release
2. Deploy to hosting service (Firebase Hosting, Vercel, etc.)

## 🤝 Contributing

1. Follow the existing code style and architecture
2. Add tests for new features
3. Update documentation as needed
4. Ensure all tests pass before submitting

## 📄 License

This project is proprietary to TeenTalk.

## 🆘 Troubleshooting

### Common Issues

1. **Build fails on Android**: Ensure Android SDK is properly configured
2. **Code generation errors**: Run `flutter clean && flutter pub get && flutter packages pub run build_runner clean && flutter packages pub run build_runner build`
3. **Import errors**: Ensure all files follow the correct package naming convention
4. **Theme not applying**: Check Riverpod provider scope and widget tree structure

### Getting Help

- Check Flutter official documentation
- Review the analysis output for specific error messages
- Ensure all dependencies are compatible with your Flutter version
