# Firebase Setup Guide

This document provides comprehensive instructions for setting up Firebase with this Flutter application, including environment configuration, Firebase project linking, and secrets handling.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Firebase Project Setup](#firebase-project-setup)
3. [Environment Configuration](#environment-configuration)
4. [FlutterFire Configuration](#flutterfire-configuration)
5. [Platform-Specific Setup](#platform-specific-setup)
6. [Running the Application](#running-the-application)
7. [Testing Firebase Services](#testing-firebase-services)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

- Flutter SDK (>=3.13.0)
- Dart SDK (>=3.1.0)
- Firebase account
- Google Cloud Console access
- Android Studio / Xcode for platform-specific setup

## Firebase Project Setup

### 1. Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name (e.g., `my-firebase-app`)
4. Enable Google Analytics (optional but recommended)
5. Click "Create project"

### 2. Enable Firebase Services

In your Firebase project, enable the following services:

- **Authentication**: Go to Authentication → Sign-in method → Enable Email/Password and Anonymous
- **Firestore Database**: Go to Firestore Database → Create database → Start in test mode
- **Storage**: Go to Storage → Get started → Start in test mode
- **Cloud Functions**: Go to Functions → Get started (optional for testing)
- **Analytics**: Usually enabled by default
- **Cloud Messaging**: Go to Cloud Messaging → Get started

### 3. Download Configuration Files

#### Android Setup

1. In Firebase Console, go to Project Settings
2. Add Android app with package name `com.example.firebase_app`
3. Download `google-services.json`
4. Place it in `android/app/`

#### iOS Setup

1. In Firebase Console, add iOS app with bundle ID `com.example.firebaseApp`
2. Download `GoogleService-Info.plist`
3. Place it in `ios/Runner/`

## Environment Configuration

### Environment Variables

The application uses `.env` files for configuration management:

1. Copy the example file:
   ```bash
   cp .env.example .env
   ```

2. Update `.env` with your actual Firebase configuration:

```env
# Firebase Configuration - Development Environment
FIREBASE_API_KEY=your_actual_api_key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=123456789012
FIREBASE_APP_ID=1:123456789012:web:abcdef123456

# Environment
FLUTTER_ENV=dev
```

### Environment Flavors

The application supports multiple environments:

- **Development**: Uses development Firebase project
- **Production**: Uses production Firebase project (to be configured)

To switch environments, modify the `FLUTTER_ENV` variable in your `.env` file.

## FlutterFire Configuration

### Install Dependencies

Run the following command to install all required Firebase packages:

```bash
flutter pub get
```

### Run FlutterFire Configure

If you have the Flutter CLI installed, you can run:

```bash
flutterfire configure
```

This will automatically generate platform-specific configurations. However, this project uses manual configuration for better control over flavors.

## Platform-Specific Setup

### Android Setup

1. Update `android/build.gradle` with Google Services plugin
2. Update `android/app/build.gradle` with Firebase dependencies
3. Ensure `google-services.json` is in `android/app/`
4. Add internet permissions in `AndroidManifest.xml`

### iOS Setup

1. Add Firebase SDK to `ios/Podfile`
2. Install pods:
   ```bash
   cd ios
   pod install
   cd ..
   ```
3. Ensure `GoogleService-Info.plist` is in `ios/Runner/`
4. Update `ios/Runner/Info.plist` with necessary permissions

## Running the Application

### Development Mode

```bash
flutter run
```

### Production Mode (when configured)

```bash
flutter run --release --dart-define=FLUTTER_ENV=prod
```

### Using dart-define Alternative

Instead of `.env` files, you can use dart-define:

```bash
flutter run --dart-define=FIREBASE_API_KEY=your_key --dart-define=FLUTTER_ENV=dev
```

## Testing Firebase Services

The application includes a comprehensive test screen to verify Firebase services:

1. Launch the app
2. Navigate to the "Firebase Test" tab
3. Click "Run Firebase Tests"
4. Monitor the test logs for each service

### Test Coverage

- **Authentication**: Verifies user authentication status
- **Firestore**: Tests document create, read, and delete operations
- **Storage**: Tests file upload, URL retrieval, and deletion
- **Cloud Functions**: Tests function calls (may fail if no functions deployed)
- **FCM**: Tests Firebase Cloud Messaging token retrieval

## Architecture Overview

### Service Layer

The application implements a clean architecture with service abstractions:

- **AuthService**: Handles user authentication with error handling
- **FirestoreService**: Provides database operations with type safety
- **StorageService**: Manages file uploads/downloads with progress tracking
- **FunctionsService**: Handles Cloud Functions calls with timeout support

### Error Handling

Comprehensive error handling is implemented throughout:

- Firebase-specific error messages
- User-friendly error display
- Detailed logging for debugging

### Bootstrap Layer

Firebase initialization is handled in `FirebaseBootstrap`:

- Validates configuration
- Initializes all Firebase services
- Provides connectivity verification
- Handles environment-specific settings

## Troubleshooting

### Common Issues

#### 1. Firebase Initialization Failed

**Symptoms**: App crashes on startup with Firebase errors

**Solutions**:
- Verify `.env` file contains correct configuration
- Ensure `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) are present
- Check Firebase project settings and enabled services

#### 2. Authentication Errors

**Symptoms**: Login/signup fails with error messages

**Solutions**:
- Enable Authentication in Firebase Console
- Configure sign-in methods (Email/Password, Anonymous)
- Check network connectivity

#### 3. Firestore Permission Denied

**Symptoms**: Firestore operations fail with permission errors

**Solutions**:
- Update Firestore security rules in Firebase Console
- For development, use test mode rules:
  ```
  rules_version = '2';
  service cloud.firestore {
    match /databases/{database}/documents {
      match /{document=**} {
        allow read, write: if request.time < timestamp.date(2024, 12, 31);
      }
    }
  }
  ```

#### 4. Storage Access Denied

**Symptoms**: File upload/download fails

**Solutions**:
- Update Storage security rules in Firebase Console
- For development, use test mode rules:
  ```
  rules_version = '2';
  service firebase.storage {
    match /b/{bucket}/o {
      match /{allPaths=**} {
        allow read, write: if request.time < timestamp.date(2024, 12, 31);
      }
    }
  }
  ```

#### 5. Build Errors

**Symptoms**: Compilation fails with Firebase-related errors

**Solutions**:
- Run `flutter clean` and `flutter pub get`
- For iOS: `cd ios && pod install && cd ..`
- Check Flutter and Dart version compatibility

### Debug Mode Considerations

In debug mode, the application:
- Uses Firebase emulators for Functions (localhost:5001)
- Disables Analytics collection
- Provides detailed logging

### Production Deployment

For production deployment:

1. Create separate Firebase project for production
2. Update `.env` with production configuration
3. Set `FLUTTER_ENV=prod`
4. Update security rules for production security
5. Test thoroughly in production environment

## Security Best Practices

1. **Never commit `.env` files** to version control
2. **Use different Firebase projects** for development and production
3. **Implement proper security rules** before production deployment
4. **Use Firebase Authentication** for user management
5. **Validate data on both client and server side**

## Additional Resources

- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/docs/overview)
- [Flutter Environment Configuration](https://docs.flutter.dev/cookbook/environment-configuration)

## Support

For issues related to this Firebase integration:

1. Check the test logs in the Firebase Test screen
2. Review console output for detailed error messages
3. Verify Firebase project configuration
4. Consult Firebase and FlutterFire documentation