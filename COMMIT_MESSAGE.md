Fix: Prevent onboarding loop by stopping unnecessary auth state rebuilds

## Problem
Users completing onboarding would successfully save data to Firestore, but the router
kept showing the onboarding screen repeatedly on every navigation. This was caused by
Firebase Auth state changes (token refreshes, network reconnections) triggering
unnecessary rebuilds throughout the provider hierarchy.

## Root Cause
1. Firebase Auth emits authStateChanges events for token refreshes (every ~1 hour),
   network reconnections, and other non-user-initiated events
2. AuthStateNotifier was creating new AuthState objects via copyWith() even when 
   user data was identical
3. Since object references changed, Riverpod treated this as a state change
4. userProfileProvider watched authStateProvider, so it rebuilt and re-subscribed
   to the Firestore stream
5. During stream re-subscription, the profile briefly appeared as null/loading
6. Router saw null/loading profile and redirected to onboarding

## Solution

### 1. Prevent Unnecessary Auth State Updates
- Added _authUsersEqual() method to compare all AuthUser fields
- Only update state if user data actually changed
- Skip updates when auth state fires for the same user (token refresh, etc.)

### 2. Use Selective Provider Watching  
- Changed userProfileProvider to watch only authStateProvider.select((state) => state.user?.uid)
- Provider now only rebuilds when UID changes, not on every AuthState change
- Prevents cascading rebuilds and stream re-subscriptions

### 3. Enhanced Logging
- Replaced all print() with debugPrint() for better performance
- Added detailed logging at every critical point:
  - Auth state changes and whether they trigger updates
  - Profile stream subscriptions and emissions
  - Router redirect decisions with full context
  - Repository operations

## Technical Benefits
- Prevents unnecessary rebuilds across the entire app
- Stable navigation without onboarding loops
- Better performance (fewer provider rebuilds and stream re-subscriptions)
- Improved debugging with comprehensive logging

## Files Changed
- lib/src/features/auth/presentation/providers/auth_provider.dart
  - Added _authUsersEqual() comparison method
  - Skip state updates when user data is identical
  - Added debugPrint logging

- lib/src/features/profile/presentation/providers/user_profile_provider.dart
  - Use authStateProvider.select() for selective watching
  - Convert print() to debugPrint()

- lib/src/core/router/app_router.dart
  - Convert print() to debugPrint()
  - Add more detailed logging for router decisions

- lib/src/features/profile/data/repositories/user_repository.dart
  - Add detailed logging for Firestore operations
  - Convert print() to debugPrint()

- lib/src/features/onboarding/presentation/pages/onboarding_page.dart
  - Convert print() to debugPrint()

## Testing
The fix ensures:
1. Onboarding completes successfully and saves to Firestore
2. User navigates to home feed after completion
3. Navigation between pages works without showing onboarding again
4. Auth token refreshes don't trigger onboarding loop
5. App reload starts in feed, not onboarding
