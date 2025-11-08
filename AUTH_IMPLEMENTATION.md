# Authentication Implementation

This document describes the comprehensive authentication system implemented in TeenTalk app.

## Overview

The authentication system supports multiple authentication methods:
- Email/Password authentication
- Google Sign-In
- Phone Number OTP (One-Time Password)
- Anonymous authentication
- Credential linking (combining multiple auth methods)

## Architecture

### Service Layer
- **FirebaseAuthService** (`lib/src/features/auth/data/services/firebase_auth_service.dart`)
  - Handles all Firebase Auth operations
  - Manages user credentials and authentication state
  - Supports phone verification, credential linking, and consent recording

### State Management
- **AuthProvider** (`lib/src/features/auth/presentation/providers/auth_provider.dart`)
  - Riverpod provider managing global auth state
  - Handles auth state changes and user updates
  - Tracks onboarding and parental consent requirements

### Models
- **AuthUser**: Represents authenticated user with auth methods and consent flags
- **UserProfile**: User profile data (name, DOB, etc.)
- **AuthState**: Global authentication state
- **Consent**: Consent tracking for GDPR, terms, and parental consent

## Features

### 1. Email/Password Authentication
Users can sign up or sign in with email and password.

```dart
// Sign up
await authNotifier.signUpWithEmail(
  email: 'user@example.com',
  password: 'SecurePassword123',
  displayName: 'John Doe',
);

// Sign in
await authNotifier.signInWithEmail(
  email: 'user@example.com',
  password: 'SecurePassword123',
);
```

**Validation:**
- Email format: Must be valid email address
- Password: Minimum 8 characters
- Unique email: Cannot use email already registered

### 2. Phone Number OTP Authentication
Users can authenticate using their phone number with OTP verification.

```dart
// Request OTP
await authNotifier.verifyPhoneNumber(
  phoneNumber: '+1234567890',
  onCodeSent: (verificationId) { },
  onError: (error) { },
);

// Sign in with OTP
await authNotifier.signInWithPhoneOTP(
  verificationId: verificationId,
  otp: '123456',
);
```

**Features:**
- Phone number format validation
- 6-digit OTP entry
- 60-second verification timeout
- Resend OTP capability

### 3. Google Sign-In
Seamless Google authentication with profile data population.

```dart
await authNotifier.signInWithGoogle();
```

**Data captured:**
- Email
- Display name
- Profile photo
- Email verification status

### 4. Anonymous Authentication
Users can browse without authentication.

```dart
await authNotifier.signInAnonymously();
```

### 5. Credential Linking
Users can link multiple authentication methods to the same account.

```dart
// Link Google to existing email account
await authNotifier.linkWithGoogle();

// Link email to existing phone account
await authNotifier.linkWithEmail(
  email: 'user@example.com',
  password: 'SecurePassword123',
);
```

**Duplicate Account Prevention:**
- System detects when email/phone already exists
- Offers user choice to link or create new account
- Prevents creating duplicate accounts

### 6. Consent Management

#### GDPR Consent
- Required for account creation
- Privacy Policy agreement
- Data processing acknowledgment

#### Terms of Service
- Required for account creation
- User acknowledgment stored

#### Parental Consent
- Required for users under 18
- Parent/Guardian verification flow
- Stored in user profile

**Age Detection:**
- Calculated from Date of Birth
- Automatic parental consent requirement for minors
- Warning message displayed

### 7. Email Verification
Users receive email verification link for email-based accounts.

```dart
// Send verification email
await authNotifier.sendEmailVerification();

// User clicks link in email
// Email automatically verified
```

### 8. Password Reset
Secure password reset via email.

```dart
await authNotifier.sendPasswordResetEmail('user@example.com');
```

## User Flow

### New User Registration

1. **Authentication Selection**
   - Email/Password
   - Phone OTP
   - Google
   - Anonymous

2. **Account Creation**
   - Validate credentials
   - Create Firebase Auth user
   - Save to Firestore

3. **Consent Screen**
   - GDPR consent checkbox
   - Terms of Service checkbox
   - Parental consent (if under 18)
   - Accept or decline

4. **Onboarding**
   - Complete profile (name, DOB)
   - Upload profile picture
   - Age verification
   - Parental consent notification (if minor)

5. **App Access**
   - Redirect to main app
   - User can start using app

### Existing User Login

1. **Select Auth Method**
   - Email/Password, Phone OTP, or Google

2. **Authenticate**
   - Verify credentials
   - Fetch user data from Firestore

3. **App Access**
   - Check onboarding status
   - Check consent status
   - Redirect to app or onboarding

## File Structure

```
lib/src/features/auth/
├── data/
│   ├── models/
│   │   └── auth_user.dart          # Data models
│   └── services/
│       └── firebase_auth_service.dart  # Firebase integration
├── presentation/
│   ├── models/
│   │   └── auth_form_state.dart    # UI state models
│   ├── pages/
│   │   ├── auth_page.dart          # Main auth screen
│   │   ├── consent_page.dart       # Consent screen
│   │   └── onboarding_page.dart    # Onboarding screen
│   ├── providers/
│   │   └── auth_provider.dart      # Riverpod providers
│   └── widgets/
│       ├── email_auth_form.dart    # Email/Password form
│       ├── phone_auth_form.dart    # Phone OTP form
│       └── social_auth_buttons.dart # Google & Anonymous buttons
```

## Localization

Strings are localized in English and Spanish:
- `lib/src/core/localization/app_localizations.dart` - Base class
- `lib/src/core/localization/app_localizations_en.dart` - English
- `lib/src/core/localization/app_localizations_es.dart` - Spanish

Usage:
```dart
final localizations = AppLocalizations.of(context);
Text(localizations?.authSignIn ?? 'Sign In');
```

## Error Handling

Error messages are user-friendly and localized:
- Invalid email format
- Password too weak
- Email already in use
- Too many login attempts
- Network errors
- Invalid OTP
- Phone number already linked

## Testing

### Unit Tests
Located in `test/features/auth/auth_flows_test.dart`:
- Email/password validation
- Phone OTP validation
- Google auth flow
- Credential linking
- Consent management
- Age detection
- Error scenarios

### Integration Tests
Future: Full user flow testing with Firebase emulator

### Golden Tests
Future: UI screen comparison testing

## Security Considerations

1. **Password Security**
   - Minimum 8 characters
   - Should contain mix of uppercase, lowercase, numbers
   - Never logged or stored in plain text

2. **OTP Security**
   - 6-digit codes
   - 60-second expiration
   - Single-use tokens
   - Rate limiting on resend

3. **Credential Linking**
   - Prevents account takeover
   - Requires re-authentication
   - Tracks linked methods

4. **Consent Tracking**
   - Timestamps for audit trail
   - Version control for terms
   - Parental consent verification

5. **Session Management**
   - Automatic token refresh
   - Session expiration handling
   - Sign out on sensitive operations

## Firebase Firestore Schema

### /users/{uid}
```json
{
  "uid": "user-id",
  "email": "user@example.com",
  "phoneNumber": "+1234567890",
  "displayName": "John Doe",
  "photoURL": "https://...",
  "emailVerified": true,
  "isAnonymous": false,
  "createdAt": "2024-01-01T00:00:00Z",
  "authMethods": ["password", "phone"],
  "isMinor": false,
  "parentalConsentProvided": false,
  "gdprConsentProvided": true,
  "termsAccepted": true,
  "consentDate": "2024-01-01T00:00:00Z"
}
```

### /userProfiles/{uid}
```json
{
  "uid": "user-id",
  "firstName": "John",
  "lastName": "Doe",
  "dateOfBirth": "2000-01-01T00:00:00Z",
  "photoURL": "https://...",
  "bio": "User bio",
  "createdAt": "2024-01-01T00:00:00Z",
  "updatedAt": "2024-01-01T00:00:00Z",
  "profileComplete": true
}
```

## Configuration

### Firebase Setup
1. Create Firebase project
2. Enable Authentication methods:
   - Email/Password
   - Phone
   - Google
   - Anonymous
3. Configure Firestore
4. Download credentials

### Environment Variables (.env)
```
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_API_KEY=your-api-key
FIREBASE_AUTH_DOMAIN=your-project.firebaseapp.com
FIREBASE_STORAGE_BUCKET=your-project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your-sender-id
FIREBASE_APP_ID=your-app-id
```

## Future Enhancements

1. **Social Authentication**
   - Apple Sign-In
   - Facebook Login
   - GitHub Sign-In

2. **Biometric Authentication**
   - Face ID / Touch ID
   - Fingerprint

3. **Email Verification**
   - Automatic re-send
   - Resend countdown
   - Email change workflow

4. **Account Recovery**
   - Two-factor authentication
   - Recovery codes
   - Account deletion

5. **Advanced Analytics**
   - Auth event tracking
   - Conversion funnel analysis
   - User journey mapping

## Troubleshooting

### Phone OTP Not Received
- Verify phone number format (+CC with country code)
- Check SMS permissions on device
- Verify Firebase Phone auth is enabled
- Check Firebase SMS quota

### Google Sign-In Fails
- Verify Google OAuth config
- Check SHA-1 fingerprint matches Firebase
- Ensure Google Cloud Console permissions

### Email Already Exists
- Use email recovery/reset
- Or link to existing account
- Create new account with different email

### Account Locked (Too Many Attempts)
- Wait 15 minutes before retrying
- Use password reset
- Contact support

## References

- [Firebase Auth Documentation](https://firebase.google.com/docs/auth)
- [Flutter Firebase Auth Plugin](https://pub.dev/packages/firebase_auth)
- [Google Sign-In Flutter](https://pub.dev/packages/google_sign_in)
- [GDPR Compliance](https://gdpr-info.eu/)
