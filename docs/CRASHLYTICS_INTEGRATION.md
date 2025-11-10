# Firebase Crashlytics Integration

## Overview

Firebase Crashlytics has been integrated into TeenTalk to provide real-time crash reporting and analytics. This enables the team to identify and fix issues quickly before they affect a large number of users.

## Features

- **Automatic crash reporting**: All uncaught exceptions and errors are automatically logged
- **Custom keys**: User metadata (userId, school, onboarding status) is attached to crash reports
- **Privacy-first**: Crashlytics is disabled in debug mode
- **Manual error reporting**: Developers can manually log non-fatal errors
- **Breadcrumb logging**: Custom logs can be added to track user actions leading to crashes

## Implementation Details

### Initialization

Crashlytics is initialized in `main.dart` immediately after Firebase Core initialization:

```dart
final crashlyticsService = CrashlyticsService();
await crashlyticsService.initialize();
```

### Error Handling

Three levels of error handling are implemented:

1. **Flutter errors** (`FlutterError.onError`): Catches errors in the Flutter framework
2. **Dart errors** (`runZonedGuarded`): Catches uncaught Dart exceptions
3. **Platform errors** (`PlatformDispatcher.onError`): Catches native platform errors

### Custom Metadata

The following custom keys are automatically set for all crash reports:

- `userId`: The authenticated user's UID (respects privacy)
- `school`: User's school (if provided)
- `is_minor`: Whether the user is a minor
- `onboarding_complete`: Whether the user has completed onboarding

### Privacy Considerations

- **Debug mode**: Crashlytics is automatically disabled in debug mode
- **User consent**: Users can opt out of crash reporting through privacy settings
- **Anonymization**: No personally identifiable information (PII) is sent to Crashlytics
- **User IDs**: Only Firebase UIDs (not names or emails) are included in reports

## Monitoring Crashes

### Firebase Console

1. Open the [Firebase Console](https://console.firebase.google.com)
2. Select your TeenTalk project
3. Navigate to **Crashlytics** in the left sidebar
4. View crashes, velocity, and trends

### Key Metrics to Monitor

- **Crash-free users percentage**: Target > 99.5%
- **Crash velocity**: Sudden spikes indicate new issues
- **Most impacted versions**: Identify problematic releases
- **Most common crashes**: Prioritize fixes based on impact

### Crash Analysis

For each crash, you can view:
- Stack trace
- Device information (OS version, device model)
- Custom keys (userId, school, etc.)
- Logs leading up to the crash
- Number of users affected
- First and last occurrence

## Testing

### Test Crash (Development)

To test Crashlytics integration in development:

```dart
// This will trigger a test crash
ref.read(crashlyticsServiceProvider).testCrash();
```

**Note**: Test crashes only work in release builds. Run with:

```bash
flutter run --release
```

### Manual Error Reporting

To manually log errors:

```dart
final crashlytics = ref.read(crashlyticsServiceProvider);

try {
  // Some risky operation
} catch (e, stackTrace) {
  await crashlytics.recordError(e, stackTrace, reason: 'Custom error context');
}
```

### Custom Logging

To add breadcrumb logs:

```dart
final crashlytics = ref.read(crashlyticsServiceProvider);
await crashlytics.log('User navigated to profile page');
```

## Android Configuration

### Gradle Setup

The following plugins are configured in `android/settings.gradle`:
- `com.google.gms.google-services` (version 4.4.0)
- `com.google.firebase.crashlytics` (version 2.9.9)

Applied in `android/app/build.gradle`:
```gradle
plugins {
    id "com.google.gms.google-services"
    id "com.google.firebase.crashlytics"
}
```

### Symbol Upload

Native symbols are automatically uploaded for release builds:
```gradle
firebaseCrashlytics {
    nativeSymbolUploadEnabled true
    unstrippedNativeLibsDir "build/intermediates/merged_native_libs/release/out/lib"
}
```

### ProGuard/R8 Mapping

Mapping files are automatically uploaded by the Crashlytics Gradle plugin during release builds.

## iOS Configuration

### dSYM Upload

A run script has been added to the Xcode project to automatically upload dSYMs:

```bash
"${PODS_ROOT}/FirebaseCrashlytics/run"
```

**Location**: Build Phases → Crashlytics (after "Thin Binary" phase)

### Manual dSYM Upload

If automatic upload fails, you can manually upload dSYMs:

```bash
# Find dSYM files
find ~/Library/Developer/Xcode/DerivedData -name "*.dSYM" | xargs -I \{\} $PODS_ROOT/FirebaseCrashlytics/upload-symbols -gsp GoogleService-Info.plist -p ios \{\}
```

### Bitcode (if enabled)

If you're using Bitcode, download dSYMs from App Store Connect after each release:

1. Go to App Store Connect
2. Select your app → Activity → All Builds
3. Click on the build → Download dSYM
4. Upload using Firebase CLI:
   ```bash
   firebase crashlytics:symbols:upload --app=YOUR_IOS_APP_ID path/to/dSYMs
   ```

## CI/CD Integration

### Symbol Upload in CI

For automated builds, ensure symbols are uploaded:

**Android**:
```bash
./gradlew assembleProdRelease
# Symbols are automatically uploaded by the plugin
```

**iOS**:
```bash
flutter build ios --release
# dSYMs are automatically uploaded by the run script
```

### Required Environment Variables

No additional environment variables are needed. The Firebase configuration is read from:
- Android: `android/app/google-services.json`
- iOS: `ios/Runner/GoogleService-Info.plist`

## Troubleshooting

### Crashes Not Appearing

1. **Wait 5-10 minutes**: Crashes may take time to appear in the console
2. **Check initialization**: Ensure Firebase Core is initialized before Crashlytics
3. **Verify build type**: Ensure you're running a release build (not debug)
4. **Check console logs**: Look for Crashlytics initialization messages

### Symbol Upload Failures (Android)

- Ensure you have the latest Gradle plugin versions
- Check build logs for "Unable to upload symbols"
- Verify `google-services.json` is present and valid

### Symbol Upload Failures (iOS)

- Ensure `GoogleService-Info.plist` exists in the project
- Check that the run script is in the correct build phase
- Verify Pods are properly installed: `cd ios && pod install`

### Missing Stack Traces

- **Android**: Ensure ProGuard mappings are uploaded (automatic with plugin)
- **iOS**: Ensure dSYMs are generated and uploaded
- Check "Build Settings" → "Debug Information Format" → "DWARF with dSYM File"

## Best Practices

1. **Monitor regularly**: Check Crashlytics dashboard daily
2. **Set up alerts**: Configure email alerts for new crashes
3. **Triage by impact**: Fix crashes affecting the most users first
4. **Version releases**: Always test crash reporting in staging before production
5. **Log context**: Add custom logs before risky operations
6. **Respect privacy**: Never log PII in custom keys or logs

## User Opt-Out

Users who wish to opt out of crash reporting can do so through:

1. Profile → Privacy Settings → Crash Reporting
2. This will disable Crashlytics data collection for that user

## Support

For issues with Crashlytics:
- [Firebase Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
- [Firebase Support](https://firebase.google.com/support)
- Check project logs and error messages

## Version History

- **v1.0.0** (Current): Initial Crashlytics integration
  - Automatic crash reporting
  - Custom keys for userId, school
  - Privacy-compliant implementation
  - CI/CD symbol upload configuration
