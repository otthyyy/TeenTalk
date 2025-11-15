# Onboarding Repeating Bug - Fix Summary

## Problem
After completing onboarding, the onboarding screen reappeared **every time** the user navigated (to messages, profile, feed, etc.). This created a loop preventing users from using the app.

## Root Cause Analysis

### The Race Condition
The issue was a **race condition** between Firestore writes and stream updates:

1. User completes onboarding
2. `createUserProfile()` writes to Firestore with `onboardingComplete: true`
3. The write operation completes successfully
4. App immediately navigates to `/feed` using `context.go('/feed')`
5. **Router's redirect logic runs** and checks `userProfileProvider`
6. The `userProfileProvider` is a `StreamProvider` watching the Firestore document
7. **The stream hasn't emitted the updated profile yet** (Firestore snapshots have a small delay)
8. Router sees `onboardingComplete: false` (or `profile == null`)
9. Router redirects back to `/onboarding`
10. This repeats on every navigation

### Why It Happened on Every Navigation
- The `userProfileProvider` is a `StreamProvider` watching `users/{uid}` in Firestore
- Even though the data is written, the snapshot stream can have a delay
- Each navigation triggers the router's redirect logic
- If the stream hasn't caught up, the router sees stale data

## The Fix

### 1. Profile Provider Invalidation + Await (Primary Fix)
**File:** `lib/src/features/onboarding/presentation/pages/onboarding_page.dart`

After writing the profile to Firestore, we now:
```dart
// Invalidate the provider to force a fresh read
ref.invalidate(userProfileProvider);

// Wait for the stream to emit the updated profile
final refreshedProfile = await ref.read(userProfileProvider.future).timeout(
  const Duration(seconds: 5),
);

// Verify onboardingComplete is true before navigating
if (refreshedProfile != null && refreshedProfile.onboardingComplete) {
  // Safe to navigate - router will see the correct state
  context.go('/feed');
}
```

This ensures the router sees the updated profile with `onboardingComplete: true`.

### 2. Use SetOptions(merge: true)
**File:** `lib/src/features/profile/data/repositories/user_repository.dart`

Changed from:
```dart
batch.set(userRef, data);
```

To:
```dart
batch.set(userRef, data, SetOptions(merge: true));
```

This preserves auth-related fields that were written by `FirebaseAuthService` when the user signed up, preventing potential data loss.

### 3. Comprehensive Logging
Added detailed logging throughout the flow to debug and verify the fix:

- **Router:** Logs every redirect decision with auth/profile state
- **Profile Provider:** Logs stream emissions and profile data
- **Auth Provider:** Logs auth state changes
- **Onboarding:** Logs the complete flow from data creation to navigation
- **Repository:** Logs Firestore writes with full payload

## Files Modified

1. `lib/src/core/router/app_router.dart` - Added redirect logging
2. `lib/src/features/profile/presentation/providers/user_profile_provider.dart` - Added stream logging
3. `lib/src/features/profile/data/repositories/user_repository.dart` - Added merge option and logging
4. `lib/src/features/onboarding/presentation/pages/onboarding_page.dart` - Main fix + logging
5. `lib/src/features/auth/presentation/providers/auth_provider.dart` - Added auth state logging

## Testing Instructions

### Manual Test Flow
1. ✅ Sign up with a new account
2. ✅ Complete onboarding (all steps: nickname, personal info, interests, consent, privacy)
3. ✅ Verify you land on the feed page
4. ✅ Navigate to messages
5. ✅ Navigate back to feed
6. ✅ Navigate to profile
7. ✅ Navigate back to feed
8. ✅ Click on a post
9. ✅ Navigate back
10. ✅ Reload the app completely (F5 or restart)

**Expected Result:** Onboarding should NOT appear at any step. The app should stay on the navigated page.

### Console Logs to Verify
Look for these log sequences in the Flutter console:

**On Onboarding Completion:**
```
✅ ONBOARDING: Creating profile with data:
   - onboardingComplete: true
📄 USER REPOSITORY: Profile saved successfully with merge:true
✅ ONBOARDING: Invalidating user profile provider to force refresh
👤 USER PROFILE PROVIDER: Stream emitted profile:
   - onboardingComplete: true
✅ ONBOARDING: Profile confirmed with onboardingComplete=true
✅ ONBOARDING: Navigating to /feed
```

**On Navigation:**
```
🔀 ROUTER REDIRECT DEBUG:
   Profile Data: onboardingComplete=true
   ✅ No redirect needed
```

## Verification
- The logging will show exactly what state the router sees
- If onboarding repeats, the logs will show `onboardingComplete=false` or `hasProfile=false`
- The fix ensures this doesn't happen by waiting for the updated profile

## Additional Notes
- The 5-second timeout on profile refresh is a safety net
- If the timeout occurs, we still proceed (logged as warning)
- The StreamProvider already has a 10-second timeout for initial load
- Using `merge: true` is important to preserve auth fields from FirebaseAuthService
