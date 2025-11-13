# Security Incident Response: Google API Key Leak

## 📋 Incident Summary

**Date**: [Current Date]  
**Severity**: HIGH  
**Issue**: Google API Key and Firebase credentials leaked on GitHub  
**Affected Key**: `[REVOKED_API_KEY]`  
**Project**: teentalk-31e45

## ✅ Immediate Actions Taken (Code Repository)

The following actions have been completed to secure the codebase:

### 1. Removed Sensitive Files from Working Directory
- ✅ Deleted `lib/firebase_options.dart`
- ✅ Deleted `android/google-services.json`
- ✅ Deleted `ios/Runner/GoogleService-Info.plist`

### 2. Updated .gitignore
- ✅ Added `lib/firebase_options.dart` to .gitignore
- ✅ Added `android/google-services.json` to .gitignore
- ✅ Added `ios/Runner/GoogleService-Info.plist` to .gitignore
- ✅ Added clear comment: "Firebase credentials - DO NOT COMMIT"

### 3. Created Template Files
- ✅ Created `lib/firebase_options.dart.example` - Template for Flutter Firebase config
- ✅ Created `android/google-services.json.example` - Template for Android config
- ✅ Created `ios/Runner/GoogleService-Info.plist.example` - Template for iOS config

### 4. Updated Documentation
- ✅ Created `FIREBASE_SECURITY.md` - Comprehensive Firebase security guide
- ✅ Updated `README.md` - Added Firebase setup instructions
- ✅ Updated `.env.example` - Removed leaked credentials, added placeholders

### 5. Security Documentation
- ✅ Created this incident response document
- ✅ Documented secure setup procedures
- ✅ Documented CI/CD best practices

## ⚠️ CRITICAL ACTIONS REQUIRED (Manual Steps)

The following actions **MUST** be completed immediately by someone with access to Google Cloud Console and Firebase:

### 1. REVOKE COMPROMISED API KEY (URGENT)

**Steps to revoke the leaked key:**

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your Firebase project
3. Navigate to: **APIs & Services** → **Credentials**
4. Find the compromised API key (check git history for the exact key)
5. Click on the key and select **Delete** or **Regenerate**
6. Confirm deletion

**DO NOT PROCEED until this key is revoked!**

### 2. CREATE NEW API KEYS

After revoking the old key, create new restricted API keys:

1. In Google Cloud Console → Credentials
2. Click **+ CREATE CREDENTIALS** → **API key**
3. Immediately click **RESTRICT KEY**
4. Configure restrictions:
   - **Application restrictions**: Set based on platform (Android/iOS/Web)
   - **API restrictions**: Only enable required APIs:
     - Cloud Firestore API
     - Firebase Authentication API
     - Cloud Storage for Firebase API
     - Firebase Cloud Messaging API
     - Identity Toolkit API
5. Save the new key securely
6. Repeat for each platform as needed

### 3. UPDATE FIREBASE CONSOLE

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `teentalk-31e45`
3. Go to **Project settings** → **General**
4. Under "Your apps":
   - Update Web app configuration with new API key
   - Download new `google-services.json` for Android
   - Download new `GoogleService-Info.plist` for iOS

### 4. REMOVE FROM GIT HISTORY

⚠️ **WARNING**: This step rewrites git history and requires coordination with all developers.

**Option A: Using BFG Repo-Cleaner (Recommended)**

```bash
# Download BFG Repo-Cleaner
wget https://repo1.maven.org/maven2/com/madgag/bfg/1.14.0/bfg-1.14.0.jar

# Clone a fresh copy of the repo
git clone --mirror git@github.com:YOUR_ORG/YOUR_REPO.git

# Remove sensitive files from all commits
java -jar bfg-1.14.0.jar --delete-files firebase_options.dart YOUR_REPO.git
java -jar bfg-1.14.0.jar --delete-files google-services.json YOUR_REPO.git
java -jar bfg-1.14.0.jar --delete-files GoogleService-Info.plist YOUR_REPO.git

# Clean up and push
cd YOUR_REPO.git
git reflog expire --expire=now --all
git gc --prune=now --aggressive
git push --force
```

**Option B: Using git-filter-repo**

```bash
# Install git-filter-repo
pip3 install git-filter-repo

# Clone a fresh copy
git clone git@github.com:YOUR_ORG/YOUR_REPO.git
cd YOUR_REPO

# Remove sensitive files
git filter-repo --path lib/firebase_options.dart --invert-paths
git filter-repo --path android/google-services.json --invert-paths
git filter-repo --path ios/Runner/GoogleService-Info.plist --invert-paths

# Force push
git remote add origin git@github.com:YOUR_ORG/YOUR_REPO.git
git push --force --all
git push --force --tags
```

**After rewriting history:**
- Notify all team members
- Everyone must re-clone the repository or force-pull
- All open pull requests will need to be recreated

### 5. UPDATE CI/CD SECRETS

Update GitHub Actions secrets (or your CI/CD platform):

1. Go to repository → **Settings** → **Secrets and variables** → **Actions**
2. Delete old secrets (if they exist)
3. Create new secrets with base64-encoded credentials:

```bash
# Encode new files
base64 -w 0 lib/firebase_options.dart > firebase_options_encoded.txt
base64 -w 0 android/google-services.json > google_services_encoded.txt
base64 -w 0 ios/Runner/GoogleService-Info.plist > google_service_info_encoded.txt
```

4. Add as secrets:
   - `FIREBASE_OPTIONS_DART` - Content of firebase_options_encoded.txt
   - `GOOGLE_SERVICES_JSON` - Content of google_services_encoded.txt
   - `GOOGLE_SERVICE_INFO_PLIST` - Content of google_service_info_encoded.txt

5. Update CI workflow to decode these files before build

### 6. NOTIFY STAKEHOLDERS

- [ ] Notify development team of the incident
- [ ] Inform security team/officers
- [ ] Document incident in security log
- [ ] Update incident response procedures if needed

### 7. MONITOR FOR ABUSE

After revoking the key, monitor for any unauthorized usage:

1. Check Firebase Console → **Usage and billing**
2. Check Google Cloud Console → **Billing** → **Reports**
3. Review Firestore, Auth, and Storage logs for unusual activity
4. Check for unexpected costs or quota usage
5. Set up billing alerts if not already configured

### 8. VERIFY CLEANUP

After all steps are complete:

```bash
# Verify files are not in git
git log --all --full-history -- "**/firebase_options.dart"
git log --all --full-history -- "**/google-services.json"
git log --all --full-history -- "**/GoogleService-Info.plist"

# Search GitHub for the old key (may take time to update)
# Visit: https://github.com/search?q=<REVOKED_API_KEY>&type=code

# Verify .gitignore
cat .gitignore | grep firebase_options.dart
cat .gitignore | grep google-services.json
cat .gitignore | grep GoogleService-Info.plist
```

## 🔄 Team Notification Template

Send this message to all developers:

```
Subject: URGENT: Security Incident - Firebase Credentials Leak

Team,

We have identified and addressed a security incident involving leaked Firebase credentials in our repository.

ACTIONS REQUIRED FROM YOU:

1. DELETE your local copy of the repository
2. RE-CLONE the repository after [SPECIFY DATE/TIME]
3. Follow the Firebase setup instructions in FIREBASE_SECURITY.md to create local config files
4. DO NOT use the old Firebase credentials
5. Verify your .gitignore excludes Firebase credentials before committing

The compromised API key has been revoked and new credentials have been generated.

If you have any questions or concerns, please reach out immediately.

Documentation:
- Setup Guide: FIREBASE_SECURITY.md
- README: Updated with Firebase configuration steps
- Incident Details: SECURITY_INCIDENT_RESPONSE.md
```

## 📊 Post-Incident Review

### Lessons Learned

1. **Prevention**: Firebase credentials should never be committed
2. **Detection**: Need automated scanning for secrets in commits
3. **Response**: Clear procedures for credential rotation
4. **Recovery**: Git history rewriting is complex and disruptive

### Improvements to Implement

- [ ] Set up pre-commit hooks to prevent credential commits
- [ ] Implement automated secret scanning (e.g., GitHub Advanced Security)
- [ ] Add CI checks that fail if credential files are present
- [ ] Regular security audits of repository
- [ ] Team training on secure credential management
- [ ] Document and test incident response procedures

### Recommended Tools

1. **git-secrets** - Prevents committing secrets
2. **truffleHog** - Scans git history for secrets
3. **detect-secrets** - Pre-commit hook for secrets
4. **GitHub Advanced Security** - Automated secret scanning
5. **Firebase App Check** - Additional layer of security

## 📋 Checklist

Use this checklist to track completion of all required actions:

### Immediate Actions (Code)
- [x] Remove sensitive files from working directory
- [x] Update .gitignore
- [x] Create template files
- [x] Update documentation
- [x] Remove leaked credentials from .env.example

### Critical Actions (Infrastructure)
- [ ] Revoke compromised API key in Google Cloud Console
- [ ] Create new restricted API keys
- [ ] Update Firebase project configuration
- [ ] Download new configuration files
- [ ] Remove sensitive files from git history
- [ ] Force-push cleaned repository

### Team Coordination
- [ ] Notify all team members
- [ ] Provide new credentials securely
- [ ] Verify all team members have re-cloned
- [ ] Update CI/CD secrets

### Verification
- [ ] Verify old key no longer works
- [ ] Verify new credentials work in all environments
- [ ] Search GitHub for leaked key (should return no results)
- [ ] Monitor Firebase for unusual activity
- [ ] Verify .gitignore working correctly

### Long-term Improvements
- [ ] Implement pre-commit hooks
- [ ] Set up automated secret scanning
- [ ] Add security training for team
- [ ] Document incident in security log
- [ ] Schedule follow-up security review

## 📞 Contacts

- **Security Team**: [Contact Information]
- **DevOps Lead**: [Contact Information]
- **Project Manager**: [Contact Information]
- **Google Cloud Admin**: [Contact Information]

## 📚 References

- [FIREBASE_SECURITY.md](FIREBASE_SECURITY.md) - Security setup guide
- [README.md](README.md) - Updated setup instructions
- [Google Cloud Security Best Practices](https://cloud.google.com/security/best-practices)
- [Firebase Security Documentation](https://firebase.google.com/docs/rules)
- [OWASP API Security](https://owasp.org/www-project-api-security/)

---

**Document Status**: ACTIVE  
**Last Updated**: [Date]  
**Next Review**: After incident resolution
