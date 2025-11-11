# Scripts Directory

## Backfill Search Keywords

Script to populate search keywords for existing posts and users.

### Usage

```bash
# Run against Firebase emulator (localhost:8080)
dart scripts/backfill_search_keywords.dart dev

# Run against production Firestore (requires confirmation)
dart scripts/backfill_search_keywords.dart prod
```

### What it does

1. Connects to Firestore (emulator or production)
2. Fetches all posts without `searchKeywords` field
3. Generates keywords from content, author, section, school
4. Batch updates Firestore (500 documents per batch)
5. Repeats for users collection
6. Logs progress and errors

### Requirements

- Firebase initialized in the project
- Proper Firestore security rules deployed
- For production: Admin/service account credentials

### Safety

- Skips documents that already have keywords
- Batch writes to avoid quota issues
- Requires explicit confirmation for production
- Logs all operations for audit trail

### Example Output

```
=== Search Keywords Backfill Script ===

🔧 Connecting to Firebase emulator...
✓ Connected to Firestore

📝 Backfilling posts...
   Found 150 posts to process
   Processed 150/150 posts (123 updated)
   ✓ Posts backfill complete: 123 updated, 0 errors

👥 Backfilling users...
   Found 45 users to process
   Processed 45/45 users (38 updated)
   ✓ Users backfill complete: 38 updated, 0 errors

✅ Backfill complete!
```

## Other Scripts

### setup_firebase.sh
Sets up Firebase project configuration

### validate_*.sh
Various validation scripts for features and assets
