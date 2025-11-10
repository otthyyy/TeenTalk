# Manual Symbol Upload Instructions for Crashlytics

This guide provides instructions for manually uploading debug symbols to Firebase Crashlytics if automatic upload fails during CI/CD builds.

## Prerequisites

- Firebase CLI installed: `npm install -g firebase-tools`
- Logged in to Firebase: `firebase login`
- Your Firebase project ID (from `.firebaserc`)

## Android: ProGuard/R8 Mapping Files

### When to Upload Manually

Upload mapping files manually if:
- CI build doesn't automatically upload symbols
- You're testing crash reporting before CI is configured
- Automatic upload fails

### Locate Mapping Files

After building a release APK/AAB, find the mapping file at:
```
android/app/build/outputs/mapping/release/mapping.txt
```

### Upload Command

```bash
# Navigate to project root
cd /path/to/teen_talk_app

# Upload mapping file
firebase crashlytics:symbols:upload \
  --app=YOUR_ANDROID_APP_ID \
  android/app/build/outputs/mapping/release/mapping.txt
```

### Finding Your Android App ID

1. Open Firebase Console → Project Settings
2. Scroll to "Your apps"
3. Find Android app, copy the App ID (format: `1:123456789:android:abcdef...`)

### Verify Upload

```bash
# List uploaded symbols
firebase crashlytics:symbols --app=YOUR_ANDROID_APP_ID
```

## iOS: dSYM Files

### When to Upload Manually

Upload dSYMs manually if:
- The run script fails during Xcode builds
- You're distributing via App Store (with Bitcode)
- Testing crash reporting before automation

### Locate dSYM Files

#### For Local Builds

```bash
# Find dSYMs in build output
find ~/Library/Developer/Xcode/DerivedData -name "*.dSYM"
```

#### For App Store Builds (with Bitcode)

1. Go to App Store Connect
2. Select your app → Activity → All Builds
3. Click on the build number
4. Click "Download dSYM" button
5. Extract the downloaded ZIP file

### Upload Command

```bash
# Using Firebase CLI
firebase crashlytics:symbols:upload \
  --app=YOUR_IOS_APP_ID \
  /path/to/Runner.app.dSYM
```

### Alternative: Upload Script (CocoaPods)

If you have CocoaPods installed:

```bash
# Find the upload script
"${PODS_ROOT}/FirebaseCrashlytics/upload-symbols" \
  -gsp ios/Runner/GoogleService-Info.plist \
  -p ios \
  /path/to/Runner.app.dSYM
```

### Finding Your iOS App ID

1. Open Firebase Console → Project Settings
2. Scroll to "Your apps"
3. Find iOS app, copy the App ID (format: `1:123456789:ios:abcdef...`)

### Verify Upload

Check Firebase Console → Crashlytics → Issues:
- Stack traces should show file names and line numbers (not just memory addresses)
- This confirms symbols were uploaded correctly

## Batch Upload

### Multiple Android Mappings

```bash
# Upload all mapping files from a directory
for file in android/app/build/outputs/mapping/*/mapping.txt; do
  firebase crashlytics:symbols:upload --app=YOUR_ANDROID_APP_ID "$file"
done
```

### Multiple iOS dSYMs

```bash
# Upload all dSYMs from a directory
for dsym in *.dSYM; do
  firebase crashlytics:symbols:upload --app=YOUR_IOS_APP_ID "$dsym"
done
```

## Troubleshooting

### "No symbols found"

**Android**: Ensure ProGuard/R8 is enabled in release builds:
```gradle
buildTypes {
    release {
        minifyEnabled true
        proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
    }
}
```

**iOS**: Ensure debug information is set to "DWARF with dSYM File":
- Xcode → Build Settings → Debug Information Format → Release: DWARF with dSYM File

### "Invalid App ID"

Double-check your App ID in Firebase Console. It should match the ID in:
- Android: `google-services.json` → `mobilesdk_app_id`
- iOS: `GoogleService-Info.plist` → `GOOGLE_APP_ID`

### Upload Timeout

For large symbol files, increase timeout:
```bash
FIREBASE_CRASHLYTICS_UPLOAD_TIMEOUT=600 firebase crashlytics:symbols:upload ...
```

### Permission Denied

Ensure you're logged in with the correct Firebase account:
```bash
firebase logout
firebase login
firebase projects:list  # Verify you can see your project
```

## CI/CD Integration

### GitHub Actions

```yaml
- name: Upload Crashlytics Symbols
  env:
    FIREBASE_TOKEN: ${{ secrets.FIREBASE_TOKEN }}
  run: |
    npm install -g firebase-tools
    # Android
    firebase crashlytics:symbols:upload \
      --app=${{ secrets.ANDROID_APP_ID }} \
      --token=$FIREBASE_TOKEN \
      android/app/build/outputs/mapping/release/mapping.txt
```

### GitLab CI

```yaml
upload_symbols:
  script:
    - npm install -g firebase-tools
    - firebase crashlytics:symbols:upload 
        --app=$ANDROID_APP_ID 
        --token=$FIREBASE_TOKEN 
        android/app/build/outputs/mapping/release/mapping.txt
```

## Automatic Upload (Recommended)

For production, configure automatic symbol upload:

### Android

Already configured in `android/app/build.gradle`:
```gradle
plugins {
    id "com.google.firebase.crashlytics"
}

firebaseCrashlytics {
    nativeSymbolUploadEnabled true
}
```

### iOS

Already configured in Xcode build phases (Crashlytics run script).

## Verification Checklist

After uploading symbols:

- [ ] Build and run app in release mode
- [ ] Trigger a test crash (dev environment only)
- [ ] Wait 5-10 minutes
- [ ] Check Firebase Console → Crashlytics
- [ ] Verify crash report shows:
  - [ ] File names (not memory addresses)
  - [ ] Line numbers
  - [ ] Method names
  - [ ] Custom keys (userId, school, etc.)

## Support

If manual upload continues to fail:

1. Check Firebase Console → Crashlytics → Settings for status messages
2. Review build logs for Crashlytics plugin errors
3. Consult [Firebase Crashlytics Documentation](https://firebase.google.com/docs/crashlytics)
4. Contact Firebase Support with:
   - App ID
   - Upload command used
   - Error messages
   - Build logs

## Additional Resources

- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Crashlytics Symbolication](https://firebase.google.com/docs/crashlytics/get-deobfuscated-reports)
- [Android ProGuard/R8](https://developer.android.com/studio/build/shrink-code)
- [iOS dSYMs](https://developer.apple.com/documentation/xcode/building-your-app-to-include-debugging-information)
