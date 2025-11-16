# Firestore Index Configuration Guide

## Overview

This document explains the Firestore composite indexes required for TeenTalk to function properly and how to deploy them.

## The "Requires an Index" Error

If you encounter a Firestore error like:

```
The query requires an index. You can create it here: https://console.firebase.google.com/...
```

This means Firestore needs a composite index to execute a query that filters or orders by multiple fields.

## Required Indexes

The `firestore.indexes.json` file in the project root contains all required index definitions. Key indexes include:

### Posts Feed Queries

The feed queries filter by `isModerated`, optionally by `section` and `school`, and order by various fields:

1. **Newest posts** (all sections):
   - `isModerated` (ASC) + `createdAt` (DESC)
   
2. **Newest posts by section**:
   - `isModerated` (ASC) + `section` (ASC) + `createdAt` (DESC)
   
3. **Newest posts by section and school**:
   - `isModerated` (ASC) + `section` (ASC) + `school` (ASC) + `createdAt` (DESC)
   
4. **Most liked posts by section**:
   - `isModerated` (ASC) + `section` (ASC) + `likeCount` (DESC) + `createdAt` (DESC)
   
5. **Most liked posts by section and school**:
   - `isModerated` (ASC) + `section` (ASC) + `school` (ASC) + `likeCount` (DESC) + `createdAt` (DESC)
   
6. **Trending posts by section**:
   - `isModerated` (ASC) + `section` (ASC) + `engagementScore` (DESC) + `createdAt` (DESC)
   
7. **Trending posts by section and school**:
   - `isModerated` (ASC) + `section` (ASC) + `school` (ASC) + `engagementScore` (DESC) + `createdAt` (DESC)

### User Search Queries

Multiple indexes for user search with various filter combinations (interests, school year, trust level, etc.).

## Deploying Indexes

### Option 1: Firebase CLI (Recommended)

1. Install Firebase CLI if not already installed:
   ```bash
   npm install -g firebase-tools
   ```

2. Login to Firebase:
   ```bash
   firebase login
   ```

3. Deploy the indexes from the project root:
   ```bash
   firebase deploy --only firestore:indexes
   ```

4. Wait for index creation (can take several minutes for large datasets).

### Option 2: Firebase Console (Manual)

1. When you encounter the error, Firestore will provide a direct link in the error message.
2. Click the link to open Firebase Console.
3. Review the index configuration and click "Create Index".
4. Add the index definition to `firestore.indexes.json` to keep it in source control.

## Verifying Indexes

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Firestore Database** → **Indexes**
4. Verify that all indexes are in the "Enabled" state (green checkmark)

## Index Build Time

- Small databases: seconds to minutes
- Medium databases: 10-30 minutes
- Large databases: can take hours

You can monitor the build progress in the Firebase Console.

## Error Handling in the App

The app includes defensive error handling for missing indexes:

- **Feed Provider**: Catches `failed-precondition` errors and shows a user-friendly message
- **Posts Repository**: Logs detailed query information when index errors occur
- **Cache Fallback**: Falls back to cached data when Firestore queries fail

## Common Issues

### Index Already Exists
If you try to deploy an index that already exists, Firebase CLI will skip it.

### Index Build Failed
Check Firebase Console for build status. Common causes:
- Database security rules blocking the index creation
- Insufficient permissions
- Corrupted data in the collection

### Query Still Fails After Creating Index
- Wait for index to finish building (check Firebase Console)
- Clear app cache and restart
- Verify the index field names and directions match exactly

## Maintenance

When adding new query patterns:

1. Add the required index to `firestore.indexes.json`
2. Deploy via `firebase deploy --only firestore:indexes`
3. Update this documentation with the new query pattern
4. Test the query in development before deploying to production

## Resources

- [Firestore Index Documentation](https://firebase.google.com/docs/firestore/query-data/indexing)
- [Firebase CLI Reference](https://firebase.google.com/docs/cli)
- [Composite Index Limits](https://firebase.google.com/docs/firestore/quotas#indexes)
