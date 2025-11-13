# 🔒 SECURITY NOTICE - LEAKED CREDENTIALS

## ⚠️ IMMEDIATE ACTION REQUIRED

### What Happened?
During development, Firebase credentials were exposed in the console output during a `flutter run` session. This includes:
- Firebase service account private key
- Firebase Web API key
- Service account email and credentials

**Note:** The specific credentials have been redacted from this document to prevent further exposure.

### What You Must Do Immediately

#### 1. Rotate Firebase API Keys
```bash
# Go to Firebase Console
# Project Settings > General > Web API Key
# Click "Regenerate Key" or restrict the existing key
```

Visit: https://console.firebase.google.com/project/teentalk-31e45/settings/general/

#### 2. Delete and Recreate Service Account
```bash
# Go to Google Cloud Console
# IAM & Admin > Service Accounts
# Delete the exposed service account credentials
# Create a new service account with minimal permissions
```

Visit: https://console.cloud.google.com/iam-admin/serviceaccounts?project=teentalk-31e45

#### 3. Update Security Rules
Immediately review and tighten your Firebase Security Rules:
- Firestore rules in `firestore.rules`
- Storage rules in `storage.rules`
- Ensure no public write access exists

#### 4. Audit Recent Activity
Check Firebase Console and Google Cloud Console for:
- Unauthorized API calls
- Unusual Firestore read/write patterns
- Unexpected Storage access
- New user registrations

#### 5. Update Local Configuration
After rotating keys, update:
```bash
# Regenerate firebase_options.dart
flutterfire configure

# Update .env file (if used)
cp .env.example .env
# Fill in NEW credentials
```

### Prevention Measures

#### What's Protected
✅ The following files are either tracked as placeholders or already in `.gitignore`:
- `lib/firebase_options.dart` – Placeholder tracked in source control. Do **not** replace with real credentials.
- `android/google-services.json` – gitignored (Android Firebase config)
- `ios/Runner/GoogleService-Info.plist` – gitignored (iOS Firebase config)
- `web/firebase-config.js` – gitignored (Web Firebase config)
- `.env` – gitignored (environment variables)
- Service account JSON files (`*.pem`, `*.json` in root) – gitignored

#### Never Commit These
❌ **NEVER** commit files containing:
- API keys
- Service account credentials
- Private keys
- Firebase configuration files
- `.env` files with real credentials

#### Best Practices
1. **Use environment-specific projects:**
   - Development: Use a separate Firebase project with test data
   - Production: Use the production project with restricted access

2. **Restrict API keys:**
   - In Firebase Console, restrict API keys to specific domains
   - Enable only necessary Firebase services per key
   - Set usage quotas

3. **Service Account Security:**
   - Create service accounts with minimal required permissions
   - Rotate service account keys regularly (every 90 days)
   - Store keys securely (use secret management tools)
   - Never log or print service account credentials

4. **CI/CD Security:**
   - Use GitHub Secrets or similar for credentials in CI/CD
   - Never expose credentials in build logs
   - Use short-lived tokens when possible

5. **Code Review:**
   - Review all changes to security rules before deployment
   - Check that no credentials are hardcoded
   - Ensure logging doesn't output sensitive data

### How to Run Locally (Securely)

1. **Get Firebase Configuration:**
   ```bash
   # Install FlutterFire CLI
   dart pub global activate flutterfire_cli
   
   # Configure (you'll need Firebase access)
   flutterfire configure
   ```

2. **This creates:**
   - `lib/firebase_options.dart` (replace the placeholder version with real credentials locally)
   - Platform-specific config files (already gitignored)
   
   **Important:** After running `flutterfire configure`, the file will contain your real credentials.
   Do NOT commit this file with real credentials. Keep it local only.

3. **For Web Development:**
   ```bash
   # Copy the example
   cp web/firebase-config.js.example web/firebase-config.js
   
   # Edit with your credentials (file is gitignored)
   nano web/firebase-config.js
   ```

### Monitoring

Set up monitoring for your Firebase project:
1. Enable Firebase App Check for additional security
2. Set up billing alerts for unusual usage
3. Enable audit logs in Google Cloud Console
4. Review security rules regularly

### Contact

If you discover additional security issues:
1. **DO NOT** commit fixes that expose credentials
2. **DO NOT** post credentials in GitHub issues
3. Contact the project maintainer directly
4. Follow responsible disclosure practices

---

## Status Checklist

After credential rotation, check off these items:

- [ ] Firebase Web API key regenerated
- [ ] Service account deleted and recreated
- [ ] New credentials distributed to authorized team members
- [ ] `.gitignore` verified (already done)
- [ ] Firebase Security Rules reviewed and updated
- [ ] Firebase audit logs checked for suspicious activity
- [ ] Google Cloud Console audit logs reviewed
- [ ] API key restrictions configured
- [ ] New service account has minimal permissions
- [ ] Team members informed about credential rotation
- [ ] CI/CD secrets updated (GitHub Actions, etc.)
- [ ] Documentation updated with security best practices
- [ ] Monitoring and alerting configured

---

## Additional Resources

- [Firebase Security Best Practices](https://firebase.google.com/docs/rules/insecure-rules)
- [Google Cloud Security Best Practices](https://cloud.google.com/security/best-practices)
- [OWASP API Security Top 10](https://owasp.org/www-project-api-security/)
- [GitHub Secret Scanning](https://docs.github.com/en/code-security/secret-scanning)

---

**Last Updated:** 2024-01-XX  
**Incident Status:** ACTIVE - Requires immediate action
