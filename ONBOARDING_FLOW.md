# TeenTalk Onboarding Flow Documentation

## Overview
The onboarding flow is a multi-step wizard that collects user information after authentication and before accessing the main app features. This ensures compliance with GDPR and provides a personalized experience.

## Flow Steps

### 1. Authentication (AuthPage)
- Simple anonymous authentication
- User is redirected to onboarding if no profile exists

### 2. Onboarding Wizard (OnboardingPage)

#### Step 1: Nickname Selection
- **Purpose**: Establish unique user identity
- **Features**:
  - Real-time nickname availability checking
  - Debounced validation (500ms delay)
  - Requirements:
    - 3-20 characters
    - Only letters, numbers, and underscores
    - Must be unique
  - Visual feedback:
    - Loading indicator during check
    - Green checkmark for available nickname
    - Red error icon for taken nickname
  - Auto-stored in Firestore with lowercase version for case-insensitive uniqueness

#### Step 2: Personal Information
- **Purpose**: Collect optional demographic data
- **Fields**:
  - Gender (optional dropdown):
    - Male
    - Female
    - Non-binary
    - Prefer not to say
  - School (optional dropdown):
    - List of Brescia schools
    - "Altro" (Other) option
- Both fields are entirely optional and can be skipped

#### Step 3: Consent & Privacy
- **Purpose**: Ensure GDPR compliance and parental consent for minors
- **Features**:
  - Age confirmation (Under 18 / 18+)
  - For minors:
    - Guardian email collection
    - Parental consent checkbox
    - Validation ensures both are provided
  - Privacy consent (required):
    - Link to Privacy Policy
    - Link to Terms of Service
    - GDPR rights information display
  - Consent timestamps recorded for compliance

#### Step 4: Privacy Preferences
- **Purpose**: Allow users to control their visibility
- **Settings**:
  - Allow Anonymous Posts (default: enabled)
    - When disabled, all posts show user's nickname
  - Profile Visible (default: enabled)
    - When disabled, profile is hidden from other users
- Users can change these settings later from their profile

## Data Model

### UserProfile Schema
```dart
{
  uid: String (required) - Firebase Auth UID
  nickname: String (required) - User's display name
  nicknameVerified: bool (required) - Verification status
  nicknameLowercase: String (auto-generated) - For uniqueness check
  gender: String? (optional) - User's gender
  school: String? (optional) - User's school
  anonymousPostsCount: int (default: 0) - Counter for anonymous posts
  createdAt: Timestamp (required) - Account creation time
  lastNicknameChangeAt: Timestamp? - Last nickname change (for rate limiting)
  privacyConsentGiven: bool (required) - Privacy policy acceptance
  privacyConsentTimestamp: Timestamp (required) - When consent was given
  isMinor: bool? - Whether user is under 18
  guardianContact: String? - Parent/guardian email (for minors)
  parentalConsentGiven: bool? - Parental consent status (for minors)
  parentalConsentTimestamp: Timestamp? - When parental consent was given
  allowAnonymousPosts: bool (default: true) - Anonymous posting preference
  profileVisible: bool (default: true) - Profile visibility preference
  updatedAt: Timestamp - Last update time
}
```

## Nickname Uniqueness Implementation

### Real-time Validation
- Uses Firestore query on `nicknameLowercase` field
- Debounced to avoid excessive queries
- Transaction-based creation to prevent race conditions

### Change Guardrails
- Users can change nickname once every 30 days
- Last change timestamp stored in `lastNicknameChangeAt`
- Profile edit page shows countdown if restriction applies
- Prevents nickname hoarding and abuse

## GDPR Compliance Features

### Consent Management
- Explicit consent required for data processing
- Consent timestamp recorded
- Privacy Policy and Terms of Service accessible during onboarding
- Users can view consent history in profile

### Data Minimization
- Only essential data is required (nickname, consent)
- Optional fields clearly marked
- No data collected without user knowledge

### Minor Protection
- Age verification step
- Parental consent requirement for under-18 users
- Guardian contact information stored
- Separate consent tracking for minors

### User Rights Display
In the consent step, users are informed of their GDPR rights:
- Right to access their data
- Right to correct data
- Right to delete data
- Right to withdraw consent
- Right to data portability

## Router Integration

### Authentication Flow
```
User not authenticated → /auth (AuthPage)
Authenticated without profile → /onboarding (OnboardingPage)
Authenticated with profile → /feed (Main app)
```

### Route Guards
The router uses Riverpod providers to watch:
- `authStateProvider` - Firebase Auth state
- `userProfileProvider` - Firestore user profile

Redirects are automatic based on these states.

## Profile Editing

### ProfileEditPage Features
- Edit all optional fields (gender, school)
- Change nickname (with 30-day restriction)
- Update privacy preferences
- Real-time validation for nickname changes
- Visual indication of nickname change restriction
- Shows days remaining until next change allowed

### Nickname Change Process
1. Check if 30 days have passed since last change
2. Validate new nickname format
3. Check nickname availability
4. Update Firestore with transaction
5. Update `lastNicknameChangeAt` timestamp

## Security Considerations

### Nickname Validation
- Server-side validation via Firestore rules (recommended)
- Client-side validation for UX
- Case-insensitive uniqueness check
- Prevents SQL injection (NoSQL database)
- Rate limiting via 30-day restriction

### Data Privacy
- Firestore security rules should restrict access to own user document
- Guardian contact email encrypted at rest by Firebase
- No sensitive data exposed in client-side code
- Consent records tamper-proof with timestamps

## Future Enhancements

### Potential Improvements
1. Email verification for guardian contact
2. Cloud Function for server-side nickname validation
3. Admin dashboard for consent audit trail
4. Automated GDPR data export functionality
5. Account deletion with cascade to remove all user data
6. Multi-language support for consent forms
7. Enhanced nickname validation (profanity filter)
8. Push notification for consent reminders (for minors)

## Testing Recommendations

### Unit Tests
- Nickname validation logic
- Consent requirement checks
- 30-day restriction calculation
- Firestore data transformations

### Integration Tests
- Complete onboarding flow
- Profile editing flow
- Nickname uniqueness enforcement
- Router redirect logic

### E2E Tests
- Full user journey from auth to onboarded
- Minor vs. adult flow differences
- Nickname change restriction
- Privacy settings persistence

## Firestore Indexes Required

Create composite indexes for:
- `users` collection: `nicknameLowercase` (ascending)
- Optional: `users` collection: `school` (ascending) + `createdAt` (descending) for school-based queries

## Firestore Security Rules

Recommended rules for the `users` collection:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      // Allow read for authenticated users to see profiles
      allow read: if request.auth != null && 
                     (resource.data.profileVisible == true || 
                      request.auth.uid == userId);
      
      // Allow create only for own user document
      allow create: if request.auth != null && 
                       request.auth.uid == userId &&
                       request.resource.data.nickname.size() >= 3 &&
                       request.resource.data.nickname.size() <= 20 &&
                       request.resource.data.privacyConsentGiven == true;
      
      // Allow update only for own user document
      allow update: if request.auth != null && 
                       request.auth.uid == userId &&
                       request.resource.data.nickname.size() >= 3 &&
                       request.resource.data.nickname.size() <= 20;
    }
  }
}
```

## Conclusion

The onboarding flow provides a comprehensive, GDPR-compliant user registration process with:
- Unique identity verification
- Optional personalization
- Legal compliance for minors
- Privacy-first design
- User-friendly experience

All data is stored securely in Firestore with appropriate access controls and validation.
