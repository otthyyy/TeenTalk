# Security Rules and Cloud Functions Deployment Guide

This document provides comprehensive instructions for deploying Firestore security rules, Firebase Storage rules, and Cloud Functions for the TeenTalk application.

## Table of Contents

1. [Setup and Prerequisites](#setup-and-prerequisites)
2. [Local Development with Emulator](#local-development-with-emulator)
3. [Security Rules Overview](#security-rules-overview)
4. [Cloud Functions Overview](#cloud-functions-overview)
5. [Testing](#testing)
6. [Deployment](#deployment)
7. [Monitoring and Maintenance](#monitoring-and-maintenance)
8. [Troubleshooting](#troubleshooting)

## Setup and Prerequisites

### Required Tools

- Firebase CLI (v11.0.0 or higher)
- Node.js (v18 or higher)
- Java JDK (for Firestore emulator)
- Dart/Flutter SDK (for Flutter app testing)
- npm or yarn (for Cloud Functions dependencies)

### Installation

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Authenticate with Firebase
firebase login

# Verify installation
firebase --version
```

### Project Configuration

```bash
# Navigate to project root
cd /path/to/project

# Set your Firebase project
firebase use --add
# Select your project from the list

# Verify firebase.json exists
cat firebase.json
```

## Local Development with Emulator

### Starting the Emulator Suite

```bash
# Start all emulators (recommended for development)
firebase emulators:start

# Or start specific emulators
firebase emulators:start --only firestore,storage,functions,auth

# With UI enabled
firebase emulators:start --import=./emulator-data --export-on-exit
```

### Emulator Ports

- **Firestore**: localhost:8080
- **Storage**: localhost:9199
- **Functions**: localhost:5001
- **Auth**: localhost:9099
- **Pub/Sub**: localhost:8085
- **Emulator UI**: localhost:4000
- **Logging**: localhost:4500

### Connecting App to Emulator

#### For Flutter App

```dart
// In your Firebase initialization code
await Firebase.initializeApp();

// Connect to emulators
FirebaseFirestore.instance.settings = const Settings(
  host: 'localhost:8080',
  sslEnabled: false,
  persistenceEnabled: false,
);

FirebaseStorage.instance.bucket;  // Storage will auto-connect on Android

FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
```

#### For Android

```bash
# In Android emulator, Firebase will auto-detect emulator URLs for:
# - Firestore: 10.0.2.2:8080
# - Storage: 10.0.2.2:9199
# - Functions: 10.0.2.2:5001
```

## Security Rules Overview

### Firestore Security Rules (`firestore.rules`)

#### Users Collection (`/users/{userId}`)

**Read Rules:**
- Authenticated users can read visible profiles
- Users can always read their own profile regardless of visibility setting

**Create Rules:**
- Only own user document allowed
- Validates nickname format (3-20 chars, alphanumeric + underscore)
- Requires privacy consent timestamp
- Sets initial counts and flags

**Update Rules:**
- Only own profile updates allowed
- Nickname can change once every 30 days
- Immutable fields (uid, createdAt, privacyConsentTimestamp) cannot be modified
- Admin and suspension flags cannot be self-modified

**Delete Rules:**
- Users can delete their own account

**Subcollections:**
- `preferences`: Private, user-only access
- `notifications`: Private, user-only access

#### Posts Collection (`/posts/{postId}`)

**Read Rules:**
- Authenticated users only
- Cannot read posts from users who have blocked the reader
- Cannot read flagged posts

**Create Rules:**
- Author must match current user
- Content must be 1-5000 characters
- Initial counts must be zero
- Requires timestamp

**Update Rules:**
- Only author can update
- Cannot modify counts (maintained by Cloud Functions)
- Cannot modify createdAt

**Delete Rules:**
- Author or admin can delete

**Subcollections:**
- `comments/{commentId}`: Post comments with like tracking
- `likes/{userId}`: Post likes

#### Comments Collection

**Behavior:**
- Stored in two places:
  1. `posts/{postId}/comments/{commentId}` (primary)
  2. `comments/{commentId}` (aggregation copy, maintained by Cloud Function)

**Rules:**
- Similar to posts but smaller size limit (1000 chars)
- Like counts tracked and maintained

#### DirectMessages Collection

**Structure:**
- `directMessages/{conversationId}`
  - `messages/{messageId}`

**Rules:**
- Only participants can read/write
- Cannot message blocked users
- Message size limit: 5000 characters

#### ReportedPosts Collection

**Structure:**
- Report creation requires valid reason
- Valid reasons: `inappropriate_content`, `spam`, `harassment`, `violence`, `other`
- Only reporters and admins can read
- Admin-only updates and deletions

### Firebase Storage Rules (`storage.rules`)

#### User Profile Photos

- Location: `users/{userId}/profile/photo`
- Max size: 5MB
- Allowed types: JPEG, PNG, WebP
- Only owner can write

#### Post Media

- Location: `posts/{postId}/media/{fileName}`
- Max size: 10MB
- Allowed types: Images (JPEG, PNG, WebP) and Videos (MP4, MOV)
- Only owner can write
- All authenticated users can read

#### Comment Attachments

- Location: `comments/{commentId}/attachments/{fileName}`
- Max size: 3MB
- Allowed types: JPEG, PNG, WebP only
- Only creator can write

#### Temporary Uploads

- Location: `temp/{userId}/uploads/{fileName}`
- Private storage for draft content
- Only owner access
- Auto-cleanup by Cloud Function

## Cloud Functions Overview

### Function Locations

Cloud Functions source code: `functions/src/functions/`

### Function Types and Deployment

#### 1. Nickname Validation

**Function: `validateNicknameUniqueness`**
- **Type**: HTTPS Callable
- **Trigger**: On-demand via client
- **Purpose**: Check nickname availability before user creation
- **Parameters**: `{nickname: string}`
- **Returns**: `{unique: boolean, message: string}`

**Function: `onUserCreated`**
- **Type**: Firestore trigger
- **Trigger**: On user document creation
- **Purpose**: Ensure no duplicate nicknames exist (safety check)

#### 2. Post Counters

**Function: `onCommentCreated`**
- Increments post `commentCount` when comment added
- Syncs to top-level `comments` collection

**Function: `onCommentDeleted`**
- Decrements post `commentCount` when comment removed

**Function: `onPostLikeAdded`**
- Increments post `likeCount` when user likes

**Function: `onPostLikeRemoved`**
- Decrements post `likeCount` when user unlikes

**Function: `syncPostCounts`**
- HTTPS Callable for manual count synchronization
- Recounts subcollections and updates post

#### 3. Comment Counters

**Function: `onCommentLikeAdded`**
- Increments comment `likeCount`
- Updates both subcollection and top-level comment

**Function: `onCommentLikeRemoved`**
- Decrements comment `likeCount`

**Function: `syncCommentCounts`**
- HTTPS Callable for manual comment count sync

#### 4. Moderation Queue

**Function: `onReportCreated`**
- Adds report to moderation queue
- Calculates priority based on reason
- Increments post report count

**Function: `processModerationAction`**
- HTTPS Callable (admin-only in production)
- Actions: approve (delete post), reject (dismiss), delete (remove all)
- Updates report status and post flags

**Function: `getPendingModerations`**
- HTTPS Callable (admin-only)
- Returns paginated list of pending reports
- Sorted by priority then creation time

**Function: `calculatePriority`**
- Helper function
- Priority: violence=5, harassment=4, inappropriate=3, spam=2, other=1

#### 5. Push Notifications

**Function: `onCommentNotification`**
- Sends notification when post receives comment
- Stores notification in user's notifications subcollection

**Function: `onPostLikeNotification`**
- Sends notification when post is liked

**Function: `onDirectMessageNotification`**
- Sends notification for direct messages

**Function: `registerFCMToken`**
- HTTPS Callable
- Registers device token for push notifications
- Prevents duplicates

**Function: `unregisterFCMToken`**
- HTTPS Callable
- Removes FCM token

#### 6. Data Cleanup

**Function: `cleanupOldNotifications`**
- **Schedule**: Daily at 2 AM UTC
- **Action**: Deletes notifications older than 30 days

**Function: `cleanupOldModerationItems`**
- **Schedule**: Daily at 3 AM UTC
- **Action**: Deletes resolved moderation items older than 90 days

**Function: `cleanupTemporaryUploads`**
- **Schedule**: Every 6 hours
- **Action**: Deletes temporary upload records older than 1 day

**Function: `onUserDeleted`**
- **Trigger**: Firebase Auth user deletion
- **Action**: Cleans up all user data

**Function: `generateUsageStatistics`**
- **Schedule**: Weekly, Sundays at 4 AM UTC
- **Action**: Generates usage statistics for admin dashboard

## Testing

### Running Emulator Tests

#### Flutter/Dart Tests

```bash
# Ensure emulator is running
firebase emulators:start --only firestore,storage,functions &

# Run all tests
flutter test test/firebase_emulator_test.dart

# Run specific test group
flutter test test/firebase_emulator_test.dart -n "Users Collection"

# Run with coverage
flutter test --coverage test/firebase_emulator_test.dart
```

#### Cloud Functions Tests

```bash
# Install functions dependencies
cd functions
npm install

# Run tests
npm test

# Run with coverage
npm run test -- --coverage

# Watch mode for development
npm run test -- --watch
```

### Test Categories

#### Firestore Security Rules Tests

1. **Users Collection**
   - Read visible/own profiles
   - Create new user with validation
   - Update with immutable field protection
   - Delete account

2. **Posts Collection**
   - Create with content validation
   - Update with count protection
   - Delete as author/admin
   - Like/unlike posts

3. **Comments Collection**
   - Create comments with size validation
   - Track comment likes
   - Delete as author/admin

4. **DirectMessages Collection**
   - Read only for participants
   - Prevent messages to blocked users
   - Message content limits

5. **ReportedPosts Collection**
   - Create reports with valid reasons
   - Admin-only moderation

#### Cloud Functions Tests

1. **Nickname Validation**
   - Uniqueness checking
   - Duplicate detection
   - Case-insensitive matching

2. **Counter Maintenance**
   - Increment/decrement operations
   - Consistency across collections
   - Batch sync operations

3. **Moderation**
   - Queue creation and priority calculation
   - Action processing
   - Report retrieval

4. **Notifications**
   - FCM token management
   - Event-based notifications
   - Notification storage

### Manual Testing Checklist

- [ ] User registration with nickname validation
- [ ] Post creation and deletion
- [ ] Comment creation and deletion
- [ ] Like/unlike functionality
- [ ] Comment counter accuracy
- [ ] Like counter accuracy
- [ ] Direct message functionality
- [ ] Report submission and moderation
- [ ] Push notifications
- [ ] User blocking
- [ ] Profile visibility controls

## Deployment

### Pre-Deployment Checklist

```bash
# 1. Update dependencies
cd functions && npm audit fix && npm update && cd ..

# 2. Run all tests
npm test

# 3. Check lint
cd functions && npm run lint && cd ..

# 4. Verify configuration
firebase projects:list
firebase target:list

# 5. Test rules syntax
firebase emulators:start --only firestore

# 6. Check for uncommitted changes
git status
```

### Deployment Steps

#### 1. Deploy Security Rules Only

```bash
# Firestore rules
firebase deploy --only firestore:rules

# Storage rules
firebase deploy --only storage

# Both
firebase deploy --only firestore:rules,storage
```

#### 2. Deploy Firestore Indexes

```bash
firebase deploy --only firestore:indexes
```

#### 3. Deploy Cloud Functions

```bash
# Deploy all functions
firebase deploy --only functions

# Deploy specific function
firebase deploy --only functions:validateNicknameUniqueness

# Deploy with verbose output
firebase deploy --only functions -v
```

#### 4. Deploy Everything

```bash
firebase deploy
```

#### 5. Staged Deployment (Recommended for Production)

```bash
# Stage 1: Deploy rules (non-breaking)
firebase deploy --only firestore:rules,storage

# Wait for verification (1 hour)

# Stage 2: Deploy indexes
firebase deploy --only firestore:indexes

# Wait for index build (can take hours for large databases)

# Stage 3: Deploy functions
firebase deploy --only functions
```

### Rollback Procedure

```bash
# View deployment history
firebase functions:list
firebase deploy:describe

# Rollback to previous rules version
git checkout HEAD~1 firestore.rules storage.rules
firebase deploy --only firestore:rules,storage

# Rollback functions
firebase functions:delete [FUNCTION_NAME]

# Or redeploy previous version
git checkout HEAD~1 functions/
firebase deploy --only functions
```

## Monitoring and Maintenance

### Firestore Usage Monitoring

```bash
# View rules compilation results
firebase deploy --only firestore:rules -v

# Check for rule violations in logs
gcloud logging read "resource.type=cloud_firestore_database" --limit 50 --format json

# Monitor database operations
gcloud monitoring dashboards list
```

### Cloud Functions Monitoring

```bash
# View function logs
firebase functions:log

# View specific function logs
firebase functions:log --only validateNicknameUniqueness

# Real-time logs
firebase functions:log -f

# View function metrics
gcloud functions describe [FUNCTION_NAME] --gen2
```

### Performance Monitoring

```bash
# Check Firestore read/write stats
gcloud firestore databases describe

# Function execution times
gcloud logging read "resource.type=cloud_function" --format json
```

### Common Monitoring Queries

#### High rejection rate

```bash
# Log permission denied errors
gcloud logging read 'protoPayload.status.code=7' --limit 100
```

#### Function execution failures

```bash
# Log function errors
gcloud logging read "resource.type=cloud_function AND severity=ERROR" --limit 50
```

#### Slow queries

```bash
# Log slow firestore operations
gcloud logging read "resource.type=cloud_firestore_database AND latency_ms>1000" --limit 20
```

### Maintenance Tasks

#### Weekly

- [ ] Review function error logs
- [ ] Check database size growth
- [ ] Verify backup status
- [ ] Review security rule violations

#### Monthly

- [ ] Analyze usage patterns
- [ ] Update rules if needed
- [ ] Review cost optimization opportunities
- [ ] Audit admin accounts
- [ ] Review moderation queue

#### Quarterly

- [ ] Security audit of rules
- [ ] Performance optimization review
- [ ] Dependency updates
- [ ] Disaster recovery drill

## Troubleshooting

### Common Issues

#### Permission Denied Errors

**Symptom**: Client receives "PERMISSION_DENIED" when accessing collection

**Solution**:
1. Check user is authenticated
2. Verify rule conditions match expectations
3. Review user role/admin status
4. Check for blocking relationships
5. Test with emulator first

```bash
# Debug mode
firebase deploy --only firestore:rules -v
```

#### Functions Not Triggering

**Symptom**: Firestore triggers not firing

**Solution**:
1. Check function is deployed: `firebase functions:list`
2. Verify event matches trigger path
3. Check function logs: `firebase functions:log -f`
4. Ensure document write matches rule path
5. Verify Cloud Functions API is enabled

#### Emulator Connection Issues

**Symptom**: App cannot connect to emulator

**Solution**:
1. Verify emulator is running: `firebase emulators:start`
2. Check correct host/port in app code
3. For Android emulator use `10.0.2.2` instead of `localhost`
4. Clear app cache and rebuild
5. Check firewall settings

#### Performance Issues

**Symptom**: Slow queries or function execution

**Solution**:
1. Check if indexes are missing: `firebase deploy --only firestore:indexes -v`
2. Review query patterns in logs
3. Optimize rule conditions (order matters)
4. Use collection groups instead of cross-collection queries
5. Consider query pagination

### Debug Commands

```bash
# Check rules compilation
firebase validate

# Emulator debug info
firebase emulators:start --debug

# Function deployment details
firebase deploy --only functions -v

# List all deployed functions
firebase functions:list

# Delete a function
firebase functions:delete [FUNCTION_NAME]

# Remote function invocation
gcloud functions call [FUNCTION_NAME] --region=us-central1 --data='{"test": "data"}'
```

### Getting Help

1. **Firebase Documentation**: https://firebase.google.com/docs
2. **Firebase Community**: https://firebase.google.com/community
3. **Stack Overflow**: Tag with `firebase` and specific service
4. **Firebase GitHub Issues**: https://github.com/firebase/firebase-js-sdk

## Appendix: Common Rule Patterns

### Ownership Pattern

```javascript
allow read, write: if request.auth.uid == resource.data.userId;
```

### Admin Pattern

```javascript
allow write: if get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
```

### Timestamp Validation

```javascript
allow create: if request.resource.data.createdAt is timestamp &&
              request.time == request.resource.data.createdAt;
```

### Size Limits

```javascript
allow write: if request.resource.size <= 1000;
```

### Enumeration

```javascript
allow write: if request.resource.data.status in ['pending', 'approved', 'rejected'];
```

### Cross-Document Reference

```javascript
allow read: if get(/databases/$(database)/documents/posts/$(resource.data.postId)).data.public == true;
```

---

**Last Updated**: 2024
**Version**: 1.0
**Maintained By**: TeenTalk Development Team
