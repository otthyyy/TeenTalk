# Verification Checklist for Onboarding & Firestore Index Fix

## Pre-Deployment

### 1. Code Review
- [ ] Review all changes in `firestore.indexes.json`
- [ ] Verify JSON syntax is valid: `python3 -m json.tool firestore.indexes.json`
- [ ] Review error handling in `feed_provider.dart`
- [ ] Review error handling in `posts_repository.dart`
- [ ] Check that documentation is complete and accurate

### 2. Deploy Firestore Indexes

```bash
# Login to Firebase (if needed)
firebase login

# Deploy indexes
firebase deploy --only firestore:indexes
```

- [ ] Indexes deployed successfully
- [ ] No deployment errors in console output
- [ ] Note timestamp of deployment: ______________

### 3. Monitor Index Build

- [ ] Open [Firebase Console](https://console.firebase.google.com/)
- [ ] Navigate to Firestore Database → Indexes
- [ ] Verify the following indexes show "Building" or "Enabled":
  - [ ] `posts`: `isModerated (ASC)` + `createdAt (DESC)`
  - [ ] `posts`: `isModerated (ASC)` + `section (ASC)` + `createdAt (DESC)`
  - [ ] `posts`: `isModerated (ASC)` + `section (ASC)` + `school (ASC)` + `createdAt (DESC)`
  - [ ] `posts`: `isModerated (ASC)` + `section (ASC)` + `likeCount (DESC)` + `createdAt (DESC)`
  - [ ] `posts`: `isModerated (ASC)` + `section (ASC)` + `school (ASC)` + `likeCount (DESC)` + `createdAt (DESC)`
  - [ ] `posts`: `isModerated (ASC)` + `section (ASC)` + `engagementScore (DESC)` + `createdAt (DESC)`
  - [ ] `posts`: `isModerated (ASC)` + `section (ASC)` + `school (ASC)` + `engagementScore (DESC)` + `createdAt (DESC)`
- [ ] All indexes show "Enabled" (green checkmark)
- [ ] Note time to build: ______________ (expected: 5-30 minutes)

## Testing

### 4. Feed Loading Tests

#### Test with Newest Sort
- [ ] Sign in to the app
- [ ] Navigate to feed page
- [ ] Select "Newest" sort option
- [ ] Verify posts load without errors
- [ ] Scroll to load more posts
- [ ] Verify no "requires an index" errors

#### Test with Most Liked Sort
- [ ] Select "Most Liked" sort option
- [ ] Verify posts load without errors
- [ ] Verify posts are sorted by like count
- [ ] Scroll to load more posts
- [ ] Verify no "requires an index" errors

#### Test with Trending Sort
- [ ] Select "Trending" sort option
- [ ] Verify posts load without errors
- [ ] Verify posts are sorted by engagement score
- [ ] Scroll to load more posts
- [ ] Verify no "requires an index" errors

#### Test with School Filter
- [ ] Apply school filter (if available)
- [ ] Test "Newest" sort with school filter
- [ ] Test "Most Liked" sort with school filter
- [ ] Test "Trending" sort with school filter
- [ ] Verify all combinations work without errors

### 5. Onboarding Flow Tests

#### New User Onboarding
- [ ] Create a new test account (email or Google)
- [ ] Complete onboarding steps:
  - [ ] Nickname selection
  - [ ] Personal info (gender, school)
  - [ ] Interests & school year selection
  - [ ] Consent forms
  - [ ] Privacy preferences
- [ ] Verify successful completion
- [ ] Verify navigation to feed page

#### Verify Firestore Data
- [ ] Open Firebase Console → Firestore Database
- [ ] Navigate to `users/{test-user-uid}`
- [ ] Verify document fields:
  - [ ] `onboardingComplete: true`
  - [ ] `nickname` is populated
  - [ ] `school` is populated (if entered)
  - [ ] `interests` array is not empty
  - [ ] `privacyConsentGiven: true`
  - [ ] `createdAt` timestamp exists

#### Test Onboarding Persistence
- [ ] Sign out from the test account
- [ ] Sign back in with the same credentials
- [ ] ✅ **EXPECTED**: Navigate directly to feed (not onboarding)
- [ ] Verify profile data is loaded correctly
- [ ] Verify no timeout or loading screen hang

### 6. Error Handling Tests

#### Missing Index Error (Simulated)
- [ ] Temporarily delete one index from Firebase Console
- [ ] Try to load feed with the affected sort option
- [ ] Verify user-friendly error message is shown
- [ ] Verify console logs show detailed error information
- [ ] Verify app doesn't crash or hang
- [ ] Re-create the index and verify feed works again

#### Offline Mode
- [ ] Enable airplane mode on test device
- [ ] Open the app
- [ ] Verify cached posts are shown (if available)
- [ ] Verify offline indicator is displayed
- [ ] Disable airplane mode
- [ ] Verify app reconnects and loads fresh data

### 7. Post Interaction Tests

#### Create Post
- [ ] Click "Create Post" button
- [ ] Enter post content
- [ ] (Optional) Add an image
- [ ] Submit post
- [ ] Verify post appears in feed without errors
- [ ] Verify no index errors during creation

#### Like/Unlike Post
- [ ] Like a post in the feed
- [ ] Verify like count increments
- [ ] Verify no index errors
- [ ] Unlike the same post
- [ ] Verify like count decrements
- [ ] Verify no errors

### 8. Logging & Monitoring

#### Check Console Logs
- [ ] Review console output for any errors
- [ ] Verify debug logs show query parameters when errors occur
- [ ] Verify error codes (e.g., `failed-precondition`) are logged
- [ ] Verify user-friendly messages are shown (not raw exceptions)

#### Firebase Console
- [ ] Check Firestore usage metrics
- [ ] Verify read/write operations are normal
- [ ] Check for any error spikes
- [ ] Review Crashlytics (if enabled) for new crash reports

## Post-Deployment

### 9. Production Verification

- [ ] Deploy app to production (after indexes are fully built)
- [ ] Monitor first 24 hours for:
  - [ ] Crash rate (should not increase)
  - [ ] Error logs (check for new Firestore errors)
  - [ ] User complaints about onboarding loop
  - [ ] Feed loading performance
- [ ] Check analytics for:
  - [ ] Successful feed loads
  - [ ] Onboarding completion rate
  - [ ] Time spent on loading screen

### 10. Rollback Plan (If Needed)

If issues are detected:

1. **Revert Code Changes:**
   ```bash
   git revert HEAD
   git push origin ai/fix/onboarding-firestore-index
   ```

2. **Keep Indexes:**
   - DO NOT delete indexes (they don't harm anything)
   - They can be used by future fixes

3. **Notify Team:**
   - Document the issue
   - Share error logs
   - Plan next steps

## Notes & Observations

### Index Build Times
- Start time: ______________
- End time: ______________
- Total duration: ______________

### Issues Encountered
- [ ] No issues
- [ ] Minor issues (describe below)
- [ ] Major issues (describe below)

**Issue Details:**
```
[Write any issues encountered here]
```

### User Feedback
```
[Record any user feedback received after deployment]
```

## Sign-Off

- [ ] All tests passed
- [ ] Documentation reviewed and updated
- [ ] Team notified of deployment
- [ ] PR merged to main branch

**Tested by:** ______________
**Date:** ______________
**Environment:** [ ] Development [ ] Staging [ ] Production

**Approved by:** ______________
**Date:** ______________
