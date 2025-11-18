# Post Section, Analytics, and Comments Index Fixes

## Summary

This document describes the fixes applied to address three issues:
1. Posts being published to the wrong section
2. Firebase Analytics parameter type errors
3. Missing Firestore indexes for comments queries

## 1. Post Section Mapping Fix

### Problem
Posts created via the UI were sometimes being saved to the wrong section (e.g., a "general" post appearing in "spotted" section).

### Root Cause
The `section` parameter in `PostsRepository.createPost()` had a default value of `'spotted'`, making it optional. This was a design flaw that allowed the section to be omitted or defaulted unexpectedly.

### Solution
- Made the `section` parameter **required** in `PostsRepository.createPost()`
- Added validation to ensure the section is not empty
- Updated all call sites to explicitly pass the section parameter
- Added unit tests to verify section validation and correct storage

### Files Modified
- `lib/src/features/comments/data/repositories/posts_repository.dart`
  - Changed `String section = 'spotted'` to `required String section`
  - Added validation: throws `PostValidationException` if section is empty
- `test/src/features/comments/data/repositories/posts_repository_test.dart`
  - Added test: `throws PostValidationException when section is empty`
  - Added test: `creates post with correct section field`
  - Updated all existing tests to pass explicit `section` parameter
- `test/src/features/feed/presentation/pages/post_composer_page_test.dart`
  - Updated `_MockPostsRepository` to match new signature

### Verification
To verify the fix:
1. Create a post in the "general" section via the UI
2. Verify the post document in Firestore has `section: 'general'`
3. Verify the post appears only in the "general" feed
4. Run `flutter test` to confirm all tests pass

## 2. Firebase Analytics Parameter Type Coercion

### Problem
Firebase Analytics was throwing errors:
```
'string' OR 'number' must be set as the value of the parameter: is_anonymous. false found instead
```

This occurred because Firebase Analytics only accepts `String` and `num` (int/double) values for event parameters, but the code was passing `bool` values directly.

### Solution
- Added a `_coerceParameters()` helper method in `AnalyticsService`
- Converts boolean values to integers: `true → 1`, `false → 0`
- Preserves string and number values as-is
- Converts null and other types to strings
- All analytics events now automatically coerce parameters

### Files Modified
- `lib/src/core/analytics/analytics_service.dart`
  - Updated `logEvent()` to call `_coerceParameters()` before logging
  - Added `_coerceParameters()` method with comprehensive type coercion

### Test Coverage
- Created `test/src/core/analytics/analytics_service_test.dart`
  - Tests boolean → int conversion (true → 1, false → 0)
  - Tests preservation of strings and numbers
  - Tests null conversion to string
  - Tests mixed parameter types
  - Tests `logContentSubmission()` with boolean parameter
  - Tests `logOnboardingCompleted()` with boolean parameter

### Verification
To verify the fix:
1. Create a post with `isAnonymous: true`
2. Check logs for analytics event with `is_anonymous: 1`
3. Complete onboarding flow
4. Verify `is_minor` parameter is logged as 0 or 1
5. Run `flutter test test/src/core/analytics/analytics_service_test.dart`

## 3. Firestore Composite Indexes for Comments

### Problem
When loading or creating comments, Firestore was throwing errors:
```
FAILED_PRECONDITION: The query requires an index
```

### Root Cause
Comments queries use multiple filters and ordering:
- `postId == <id>`, `isModerated == false`, ordered by `createdAt`
- `replyToCommentId == <id>`, `isModerated == false`, ordered by `createdAt`

Firestore requires composite indexes for such queries.

### Solution

#### Index Configuration
Added two composite indexes to `firestore.indexes.json`:

1. **Comments by post**:
   - `postId` (Ascending)
   - `isModerated` (Ascending)
   - `createdAt` (Ascending)

2. **Replies to comment**:
   - `replyToCommentId` (Ascending)
   - `isModerated` (Ascending)
   - `createdAt` (Ascending)

#### Debug Logging
Enhanced `CommentsRepository` with `_logMissingIndexHint()` method:
- Detects `failed-precondition` errors about indexes
- Extracts and prints the index creation URL from error message
- Provides clear console output for developers

### Files Modified
- `firestore.indexes.json`
  - Added two composite indexes for comments collection
- `lib/src/features/comments/data/repositories/comments_repository.dart`
  - Added `_logMissingIndexHint()` method
  - Updated `getCommentsByPostId()` to catch FirebaseException and log index hint
  - Updated `getRepliesForComment()` to catch FirebaseException and log index hint

### Index Deployment
To deploy the indexes:
```bash
firebase deploy --only firestore:indexes
```

### Verification
1. Navigate to a post with comments
2. Verify comments load without errors
3. Reply to a comment
4. Verify replies load without errors
5. Check Firebase Console → Firestore → Indexes to see the deployed indexes

### Future Index Errors
If a new query causes an index error, the console will show:
```
⚠️ Firestore index missing for <query description>
➡️ Create index: https://console.firebase.google.com/...
```

Click the URL or add the index manually to `firestore.indexes.json`.

## Testing Checklist

- [x] Post section validation test passes
- [x] Post section field is correctly stored in Firestore
- [x] Analytics parameter coercion tests pass
- [x] Boolean analytics params are converted to 0/1
- [x] Comments load without index errors
- [x] Comment replies load without index errors
- [x] All existing unit tests pass
- [ ] Manual testing: create post in general section
- [ ] Manual testing: create post in spotted section
- [ ] Manual testing: create anonymous and non-anonymous posts
- [ ] Manual testing: load comments on various posts
- [ ] Manual testing: reply to comments

## Migration Notes

### For Developers
- When calling `PostsRepository.createPost()`, always explicitly pass the `section` parameter
- Analytics events automatically handle boolean parameters - no code changes needed
- If adding new Firestore queries with multiple filters/ordering, expect to add indexes

### For Deployment
1. Deploy Firestore indexes first:
   ```bash
   firebase deploy --only firestore:indexes
   ```
2. Wait for indexes to finish building (check Firebase Console)
3. Deploy the app:
   ```bash
   flutter build web  # or other platform
   # Deploy to hosting
   ```

## References
- Firebase Analytics: https://firebase.google.com/docs/analytics/parameters
- Firestore Indexes: https://firebase.google.com/docs/firestore/query-data/indexing
- Composite Indexes: https://firebase.google.com/docs/firestore/query-data/index-overview
