# Onboarding Loop Bug Fix

## Problem Description

Users completing onboarding would successfully save their data to Firestore, but the router would repeatedly show the onboarding screen every time they navigated within the app. This created a frustrating loop where users couldn't use the app after completing onboarding.

## Root Cause

The issue was caused by unnecessary rebuilds of the `authStateProvider` triggering cascading rebuilds of `userProfileProvider`, which in turn caused the router to re-evaluate navigation logic during profile stream re-subscription.

### Detailed Explanation

1. **Firebase Auth State Changes**: Firebase Auth emits `authStateChanges` events not only for login/logout but also for:
   - Token refreshes (happens automatically every hour)
   - Network reconnections
   - Browser tab focus changes (in web)
   - App lifecycle changes

2. **Unnecessary State Updates**: The `AuthStateNotifier` was creating a new `AuthState` object via `state.copyWith()` every time an auth state change event fired, even when the user data was identical. Since object references changed, Riverpod considered this a "state change" and notified all watchers.

3. **Cascading Rebuilds**: 
   - `authStateProvider` changes → notifies `userProfileProvider`
   - `userProfileProvider` watches `authStateProvider` → rebuilds entire provider
   - Provider rebuild → creates NEW Firestore snapshot stream subscription
   - During stream changeover → brief moment where profile is null or loading
   - Router checks profile → sees null/loading → redirects to onboarding

4. **The Loop**: This could happen repeatedly during navigation, token refreshes, or any Firebase Auth event, causing the onboarding screen to appear seemingly randomly.

## The Fix

### 1. Prevent Unnecessary Auth State Updates

**File**: `lib/src/features/auth/presentation/providers/auth_provider.dart`

Added `_authUsersEqual()` method that compares all fields of the current and new `AuthUser` objects. If they're identical, we skip the state update entirely, preventing unnecessary rebuilds.

```dart
bool _authUsersEqual(AuthUser? current, AuthUser next) {
  if (current == null) return false;
  
  return current.uid == next.uid &&
      current.email == next.email &&
      current.phoneNumber == next.phoneNumber &&
      // ... all other fields
}
```

In `_init()`, we now check before updating:

```dart
if (_authUsersEqual(state.user, authUser)) {
  debugPrint('⚠️ Auth user unchanged. Skipping state update to prevent rebuild loops.');
  if (!state.isAuthenticated || state.isLoading) {
    // Only update if state flags are incorrect
    state = state.copyWith(isAuthenticated: true, isLoading: false);
  }
  return;  // Skip the update
}
```

### 2. Selective Provider Watching

**File**: `lib/src/features/profile/presentation/providers/user_profile_provider.dart`

Changed from watching the entire `authStateProvider` to only watching the specific field we need (the UID):

**Before**:
```dart
final authState = ref.watch(authStateProvider);
if (authState.user == null) return Stream.value(null);
return userRepository.watchUserProfile(authState.user!.uid);
```

**After**:
```dart
final uid = ref.watch(authStateProvider.select((state) => state.user?.uid));
if (uid == null) return Stream.value(null);
return userRepository.watchUserProfile(uid);
```

This uses Riverpod's `select()` to only rebuild when the UID changes, not when any other part of `AuthState` changes.

### 3. Enhanced Logging

Added comprehensive `debugPrint` logging throughout the auth, profile, and router layers to make debugging easier:

- Auth state changes and whether they trigger updates
- Profile stream subscriptions and data emissions
- Router redirect decisions with full context
- Repository operations (saves and stream events)

All `print()` statements replaced with `debugPrint()` which is automatically stripped in release builds for better performance.

## Testing the Fix

To verify the fix works:

1. **Complete Onboarding**: User should complete onboarding successfully
2. **Navigate Multiple Times**: 
   - Go to Feed → Profile → Messages → Feed → Profile
   - Each navigation should work smoothly without showing onboarding
3. **Wait for Token Refresh**: Leave app open for 5-10 minutes
   - App should continue working normally
   - Check logs to see auth state changes being ignored
4. **Reload App**: Close and reopen the app
   - Should start in Feed, not onboarding
5. **Check Firestore**: Verify `onboardingComplete: true` is saved

## Technical Benefits

1. **Performance**: Fewer unnecessary rebuilds across the entire app
2. **Reliability**: Navigation is stable and predictable
3. **Maintainability**: Better logging makes future debugging easier
4. **User Experience**: No more frustrating onboarding loops

## Related Files Changed

- `lib/src/features/auth/presentation/providers/auth_provider.dart`
- `lib/src/features/profile/presentation/providers/user_profile_provider.dart`
- `lib/src/core/router/app_router.dart`
- `lib/src/features/profile/data/repositories/user_repository.dart`
- `lib/src/features/onboarding/presentation/pages/onboarding_page.dart`

## Logs to Watch

When running the app with the fix, you should see:

```
🔐 AUTH PROVIDER: authStateChanges event received. user=abc123
   uid: abc123
   email: user@example.com
   authMethods: [google.com]
   ⚠️ Auth user unchanged. Skipping state update to prevent rebuild loops.
```

This indicates the fix is working - auth state changes are detected but don't trigger unnecessary rebuilds.

If you see:
```
   ➡️ Updating auth state with new user data
```

This means the user data actually changed (e.g., email verified, new auth method linked), which is a legitimate rebuild.
