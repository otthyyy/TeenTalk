# Firebase Security & Setup Guide

## 🚨 Security Notice

Firebase credentials contain sensitive API keys and should **NEVER** be committed to version control. This guide explains how to properly configure Firebase for your local development environment and CI/CD pipelines.

## 📋 Required Configuration Files

The following files contain Firebase credentials and must be created locally:

1. `lib/firebase_options.dart` - Flutter/Dart Firebase configuration
2. `android/google-services.json` - Android Firebase configuration  
3. `ios/Runner/GoogleService-Info.plist` - iOS Firebase configuration

**These files are in `.gitignore` and will not be committed to the repository.**

## 🛠️ Setup Instructions

### Method 1: Using FlutterFire CLI (Recommended)

The FlutterFire CLI automatically generates the required configuration files from your Firebase project.

1. **Install FlutterFire CLI**
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Login to Firebase**
   ```bash
   firebase login
   ```

3. **Configure Firebase for your project**
   ```bash
   flutterfire configure
   ```

4. **Follow the prompts**
   - Select your Firebase project (or create a new one)
   - Select the platforms you want to configure (iOS, Android, Web)
   - The CLI will automatically generate all required configuration files

5. **Verify the files were created**
   ```bash
   ls lib/firebase_options.dart
   ls android/google-services.json
   ls ios/Runner/GoogleService-Info.plist
   ```

### Method 2: Manual Configuration

If you prefer to manually configure Firebase or need more control:

#### Step 1: Get Android Configuration

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project (teentalk-31e45 or your own project)
3. Click the gear icon → Project settings
4. Scroll to "Your apps" section
5. Select or add your Android app
6. Download `google-services.json`
7. Place it in `android/google-services.json`

#### Step 2: Get iOS Configuration

1. In the same Firebase Console → Project settings
2. Select or add your iOS app
3. Download `GoogleService-Info.plist`
4. Place it in `ios/Runner/GoogleService-Info.plist`

#### Step 3: Create firebase_options.dart

1. Copy the template file:
   ```bash
   cp lib/firebase_options.dart.example lib/firebase_options.dart
   ```

2. Open `lib/firebase_options.dart` and replace the placeholder values:
   - `YOUR_WEB_API_KEY` - Found in Firebase Console → Project settings → Web apps
   - `YOUR_WEB_APP_ID` - Found in the same location
   - `YOUR_MESSAGING_SENDER_ID` - Found in Cloud Messaging tab
   - `YOUR_PROJECT_ID` - Your Firebase project ID
   - `YOUR_MEASUREMENT_ID` - Found in Google Analytics settings

3. If you need Android/iOS configurations, add them following the same pattern

## 🔒 Security Best Practices

### API Key Security

1. **Never commit credentials**: Always keep Firebase config files in `.gitignore`
2. **Rotate keys immediately if exposed**: If credentials are accidentally committed, revoke them immediately in Firebase Console
3. **Use Firebase App Check**: Add an extra layer of security to prevent abuse
4. **Set up Security Rules**: Configure Firestore and Storage security rules to protect your data
5. **Monitor usage**: Regularly check Firebase Console for unusual activity

### Firebase Security Rules

Ensure your Firestore and Storage have proper security rules configured:

```javascript
// Example Firestore rules
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Only authenticated users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

See [SECURITY_RULES_SUMMARY.md](SECURITY_RULES_SUMMARY.md) for detailed security rules configuration.

### API Key Restrictions

In Google Cloud Console, restrict your API keys:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to APIs & Services → Credentials
3. Click on your API key
4. Add Application restrictions:
   - **Android**: Add your app's package name and SHA-1 fingerprint
   - **iOS**: Add your app's bundle ID
   - **Web**: Add authorized domains

5. Add API restrictions:
   - Only enable APIs your app actually uses
   - Recommended: Cloud Firestore, Firebase Auth, Cloud Storage, FCM

## 🚀 CI/CD Configuration

### GitHub Actions Secrets

For CI/CD pipelines, store Firebase credentials as GitHub Secrets:

1. Go to your repository → Settings → Secrets and variables → Actions
2. Add the following secrets:
   - `FIREBASE_OPTIONS_DART` - Base64 encoded content of `firebase_options.dart`
   - `GOOGLE_SERVICES_JSON` - Base64 encoded content of `google-services.json`
   - `GOOGLE_SERVICE_INFO_PLIST` - Base64 encoded content of `GoogleService-Info.plist`

3. Encode your files:
   ```bash
   # On Linux/Mac
   base64 -w 0 lib/firebase_options.dart
   base64 -w 0 android/google-services.json
   base64 -w 0 ios/Runner/GoogleService-Info.plist
   ```

4. Update your CI workflow to decode and place files:
   ```yaml
   - name: Setup Firebase credentials
     run: |
       echo "${{ secrets.FIREBASE_OPTIONS_DART }}" | base64 -d > lib/firebase_options.dart
       echo "${{ secrets.GOOGLE_SERVICES_JSON }}" | base64 -d > android/google-services.json
       echo "${{ secrets.GOOGLE_SERVICE_INFO_PLIST }}" | base64 -d > ios/Runner/GoogleService-Info.plist
   ```

## 🧪 Testing with Firebase Emulator

For local development and testing, use the Firebase Emulator Suite to avoid using production credentials:

1. **Install Firebase CLI**
   ```bash
   npm install -g firebase-tools
   ```

2. **Initialize Firebase Emulators**
   ```bash
   firebase init emulators
   ```

3. **Start emulators**
   ```bash
   ./scripts/start_emulator.sh
   ```

4. **Run tests**
   ```bash
   flutter test integration_test/
   ```

See [EMULATOR_TESTING_GUIDE.md](EMULATOR_TESTING_GUIDE.md) for comprehensive emulator setup.

## 📱 Platform-Specific Notes

### Android

- The `google-services.json` file is automatically processed by the Google Services Gradle plugin
- Make sure your `android/build.gradle` includes:
  ```gradle
  classpath 'com.google.gms:google-services:4.3.15'
  ```
- And `android/app/build.gradle` applies the plugin:
  ```gradle
  apply plugin: 'com.google.gms.google-services'
  ```

### iOS

- The `GoogleService-Info.plist` must be added to your Xcode project
- Open `ios/Runner.xcworkspace` in Xcode
- Drag `GoogleService-Info.plist` into the Runner target
- Ensure "Copy items if needed" is checked

### Web

- Web configuration is included in `firebase_options.dart`
- The API key for web can be less restricted since it's always exposed
- Rely on Firebase Security Rules and App Check for web security

## 🔍 Verification

After setting up your Firebase configuration:

1. **Check files exist**
   ```bash
   ls -la lib/firebase_options.dart
   ls -la android/google-services.json
   ls -la ios/Runner/GoogleService-Info.plist
   ```

2. **Verify .gitignore is working**
   ```bash
   git status
   # The above files should NOT appear in the output
   ```

3. **Test Firebase connection**
   ```bash
   flutter run
   # Check logs for "Firebase initialized successfully"
   ```

4. **Run integration tests**
   ```bash
   ./scripts/run_integration_tests.sh
   ```

## 🆘 Troubleshooting

### "Firebase not initialized" error

**Solution**: Ensure all three configuration files are present and contain valid credentials.

### "Permission denied" in Firestore

**Solution**: Check your Firebase Security Rules. During development, you may need to temporarily relax rules (but never deploy to production with open rules).

### Build fails on Android

**Solution**: 
1. Check that `google-services.json` is in the correct location
2. Verify the package name matches your app's package name
3. Run `flutter clean && flutter pub get`

### Build fails on iOS

**Solution**:
1. Open Xcode and verify `GoogleService-Info.plist` is in the project
2. Check that the bundle ID matches your app's bundle ID
3. Clean build folder in Xcode (Cmd+Shift+K)

## 📚 Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)
- [Firebase App Check](https://firebase.google.com/docs/app-check)
- [Google Cloud Security Best Practices](https://cloud.google.com/security/best-practices)

## 🔗 Related Documentation

- [FIREBASE_SETUP.md](FIREBASE_SETUP.md) - Original Firebase setup guide
- [SECURITY_RULES_SUMMARY.md](SECURITY_RULES_SUMMARY.md) - Firebase security rules
- [EMULATOR_TESTING_GUIDE.md](EMULATOR_TESTING_GUIDE.md) - Local testing with emulators
- [DEPLOYMENT_NOTES.md](DEPLOYMENT_NOTES.md) - Deployment procedures

## ⚠️ Emergency Response

### If Credentials Are Exposed

If you accidentally commit Firebase credentials to a public repository:

1. **Immediately revoke the exposed API key**:
   - Go to Google Cloud Console → APIs & Services → Credentials
   - Delete the compromised API key
   - Create a new API key with proper restrictions

2. **Remove from git history**:
   ```bash
   # Use BFG Repo-Cleaner (recommended)
   java -jar bfg.jar --delete-files firebase_options.dart
   java -jar bfg.jar --delete-files google-services.json
   java -jar bfg.jar --delete-files GoogleService-Info.plist
   git reflog expire --expire=now --all
   git gc --prune=now --aggressive
   
   # Force push (coordinate with team)
   git push --force --all
   ```

3. **Verify removal**:
   - Check GitHub/GitLab security alerts
   - Search public GitHub for your old API key
   - Monitor Firebase Console for unusual activity

4. **Update all environments**:
   - Regenerate credentials for all team members
   - Update CI/CD secrets
   - Notify your team of the security incident

5. **Review access logs**:
   - Check Firebase Console → Usage and billing
   - Look for unauthorized access or unusual patterns
   - Consider enabling additional monitoring and alerting
