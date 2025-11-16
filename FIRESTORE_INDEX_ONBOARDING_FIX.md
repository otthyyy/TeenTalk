# Firestore Index & Onboarding Nickname Uniqueness Fix

## Summary

This fix addresses three critical issues related to Firestore indexes, onboarding flow, and nickname uniqueness:

1. **Firestore Index Requirement**: Feed queries failing due to missing composite indexes
2. **Onboarding Re-appearing**: Users seeing onboarding screen after login even when already completed
3. **Nickname "Already Taken" Error**: Users unable to complete onboarding because their own nickname is flagged as taken

## Root Causes

### 1. Firestore Index Missing
The feed queries combine multiple filters (`isModerated`, `section`, `school`) with ordering (`createdAt`, `likeCount`, `engagementScore`), which requires composite indexes. While the `firestore.indexes.json` file exists with all necessary definitions, the indexes need to be deployed to Firebase.

### 2. Onboarding Loop & Nickname Collision
The `isNicknameAvailable` function queried for existing nicknames but didn't exclude the current user's UID. This caused several issues:

- **During re-onboarding**: If a user already had a profile, checking their own nickname would find their existing entry and report it as "taken"
- **Race condition**: Multiple checks could happen simultaneously without atomic reservation
- **No atomic nickname reservation**: Separate check + write operations allowed potential collisions

## Changes Made

### 1. Atomic Nickname Reservation System

Created a new `usernames` collection to atomically reserve nicknames:

**File: `lib/src/features/profile/data/repositories/user_repository.dart`**

#### Updated `isNicknameAvailable` Method
```dart
Future<bool> isNicknameAvailable(String nickname, {String? excludeUid})
```
- Added optional `excludeUid` parameter to exclude current user from availability check
- Checks `usernames` collection first (atomic reservation system)
- Falls back to `users` collection for backwards compatibility
- Returns `true` if nickname is reserved by the current user

#### Updated `createUserProfile` Method
```dart
Future<void> createUserProfile(UserProfile profile)
```
- Uses Firestore transaction to atomically:
  1. Check if nickname is available
  2. Reserve nickname in `usernames/{lowercaseNickname}` collection
  3. Create/update user profile in `users/{uid}` collection
- Allows same user to update their profile (idempotent operation)
- Prevents race conditions by using transaction

#### Updated `updateUserProfile` Method
```dart
Future<bool> updateUserProfile(String uid, Map<String, dynamic> updates)
```
- When nickname is changed, uses transaction to:
  1. Reserve new nickname in `usernames` collection
  2. Release old nickname reservation
  3. Update user document with new nickname
- Maintains atomicity during nickname changes

### 2. Updated Nickname Availability Checks

**File: `lib/src/features/onboarding/presentation/widgets/nickname_step.dart`**
```dart
final currentUid = ref.read(firebaseAuthServiceProvider).currentUser?.uid;

final isAvailable = await ref.read(userRepositoryProvider).isNicknameAvailable(
  nickname,
  excludeUid: currentUid,
);
```
- Passes current user's UID when checking nickname availability during onboarding
- Allows users to keep their existing nickname if re-onboarding

**File: `lib/src/features/profile/presentation/pages/profile_edit_page.dart`**
```dart
final currentUid = profileAsync.value?.uid;

final isAvailable = await ref.read(userRepositoryProvider).isNicknameAvailable(
  nickname,
  excludeUid: currentUid,
);
```
- Passes current user's UID when checking nickname availability during profile edit
- Allows users to keep their current nickname unchanged

## Firestore Data Structure

### New Collection: `usernames`

Document ID: normalized nickname (lowercase, trimmed)

```json
{
  "uid": "user_uid_here",
  "createdAt": "Timestamp",
  "updatedAt": "Timestamp"
}
```

**Purpose**: Atomic nickname reservation to prevent race conditions and duplicates.

### Updated Collection: `users`

Added/maintained fields:
```json
{
  "nickname": "UserNickname",
  "nicknameLowercase": "usernickname",
  "nicknameVerified": true,
  "lastNicknameChangeAt": "Timestamp",
  "onboardingComplete": true,
  ...
}
```

## Deploying Firestore Indexes

The required indexes are already defined in `firestore.indexes.json`. To deploy them:

### Option 1: Firebase CLI (Recommended)

```bash
# Ensure you're logged in to Firebase
firebase login

# Deploy the indexes
firebase deploy --only firestore:indexes
```

Index creation can take several minutes to complete. Monitor progress in Firebase Console:
1. Go to Firebase Console → Firestore Database → Indexes
2. Wait for all indexes to show "Enabled" status (green checkmark)

### Option 2: Firebase Console (Manual)

If you encounter the "index required" error:
1. The error message includes a direct link to create the index
2. Click the link to open Firebase Console
3. Review the index configuration and click "Create Index"

## Security Rules Update (Required)

Add security rules for the new `usernames` collection:

```javascript
// In firestore.rules
match /usernames/{nickname} {
  // Allow users to read any username document (for availability checking)
  allow read: if request.auth != null;
  
  // Only allow creating/updating if the UID matches the authenticated user
  allow create, update: if request.auth != null 
    && request.resource.data.uid == request.auth.uid;
  
  // Allow users to delete their own nickname reservation
  allow delete: if request.auth != null 
    && resource.data.uid == request.auth.uid;
}
```

Deploy updated security rules:
```bash
firebase deploy --only firestore:rules
```

## Testing the Fix

### 1. Test Nickname Availability
1. Create a new user and complete onboarding with a nickname
2. Sign out and sign in again
3. If onboarding appears, the same nickname should be available (not "already taken")

### 2. Test Nickname Change
1. Go to Profile → Edit Profile
2. Change nickname to a new unique value
3. Verify the old nickname becomes available for other users
4. Verify you can change it back within 30 days limit

### 3. Test Race Conditions
1. Create two new users simultaneously
2. Both attempt to register with the same nickname
3. One should succeed, the other should get "already taken" error

### 4. Test Feed Loading
1. Navigate to the feed
2. Verify posts load without "index required" error
3. Test all filter combinations (section, school, sort order)

## Backward Compatibility

The fix maintains backward compatibility:
- Existing users without `usernames` documents will work normally
- The `isNicknameAvailable` method falls back to checking `users` collection
- First nickname check/update will create the `usernames` document

## Migration Notes

For existing production data, consider running a migration script to populate the `usernames` collection:

```typescript
// Cloud Function or Admin SDK script
async function migrateNicknames() {
  const usersSnapshot = await admin.firestore().collection('users').get();
  const batch = admin.firestore().batch();
  
  usersSnapshot.forEach((doc) => {
    const data = doc.data();
    const nicknameLowercase = data.nicknameLowercase;
    
    if (nicknameLowercase) {
      const usernameRef = admin.firestore()
        .collection('usernames')
        .doc(nicknameLowercase);
      
      batch.set(usernameRef, {
        uid: doc.id,
        createdAt: data.createdAt || admin.firestore.FieldValue.serverTimestamp(),
        updatedAt: admin.firestore.FieldValue.serverTimestamp(),
      }, { merge: true });
    }
  });
  
  await batch.commit();
}
```

## Related Files Changed

- `lib/src/features/profile/data/repositories/user_repository.dart`
- `lib/src/features/onboarding/presentation/widgets/nickname_step.dart`
- `lib/src/features/profile/presentation/pages/profile_edit_page.dart`

## Documentation References

- [FIRESTORE_INDEX_GUIDE.md](./FIRESTORE_INDEX_GUIDE.md) - Comprehensive index deployment guide
- `firestore.indexes.json` - Index definitions
- Firestore Security Rules - Add rules for `usernames` collection
