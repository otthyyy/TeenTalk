# Beta Distribution Guide

This guide covers the operational steps for releasing TeenTalk beta builds through Firebase App Distribution.

## Overview

**Goal:** Ship stable, testable builds to beta users (internal team and school ambassadors) for fast iteration feedback.  
**Tools:** Firebase App Distribution, integrated with CI/CD (GitHub Actions) or manual CLI flow.

---

## Prerequisites

1. **Firebase project:**  
   Ensure `teentalk-31e45` (or your production project) is set up with App Distribution enabled.
2. **Tester groups:**  
   Create two groups in the Firebase console:
   - `internal` – core dev/product team
   - `school-ambassadors` – pilot students at Brescia schools
3. **Firebase CLI:**  
   ```bash
   firebase --version
   # Install if needed: npm install -g firebase-tools
   ```
4. **Build artefacts:**  
   APK (Android) and IPA (iOS) ready for distribution.

---

## Manual distribution (CLI)

### 1. Build the app

**Android:**
```bash
flutter build apk --release --flavor beta --dart-define=ENV=beta
```

**iOS:**
```bash
flutter build ipa --release --flavor beta --dart-define=ENV=beta --export-options-plist=ios/ExportOptions.plist
```

### 2. Upload to Firebase

```bash
# Android
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-beta-release.apk \
  --app YOUR_ANDROID_APP_ID \
  --release-notes "Beta release $(date +%F): [feature notes]" \
  --groups "internal,school-ambassadors"

# iOS
firebase appdistribution:distribute build/ios/ipa/teentalk.ipa \
  --app YOUR_IOS_APP_ID \
  --release-notes "Beta release $(date +%F): [feature notes]" \
  --groups "internal,school-ambassadors"
```

### 3. Notify testers

Firebase sends automated emails to each group. Double-check your tester roster and update the groups if necessary.

---

## Automated distribution (CI/CD)

A GitHub Actions template is included in [`templates/github-actions-beta.yml`](templates/github-actions-beta.yml). Copy it into your repository’s `.github/workflows/` directory once credentials are ready.

### Workflow highlights

- Triggers: push to `beta` branch, manual dispatch, or version tags like `v1.0.0-beta.1`
- Steps:
  1. Checkout code
  2. Set up Flutter and dependencies
  3. Build APK/IPA
  4. Distribute via `firebase appdistribution:distribute` (using service account credentials)
  5. Post build artefacts and release notes

### Setup

1. **Store credentials:**  
   Add `FIREBASE_SERVICE_ACCOUNT` (base64-encoded JSON) to GitHub repository secrets.
2. **Verify Firebase App IDs:**  
   Update placeholders in the template with your actual app IDs.
3. **Install workflow:**  
   Move the template to `.github/workflows/beta-distribution.yml`.
4. **Trigger:**  
   Push a commit or tag. Watch GitHub Actions logs for build status.

---

## Tester management

**Adding testers:**
1. Go to **Firebase Console → App Distribution → Testers & Groups**.
2. Select either `internal` or `school-ambassadors`.
3. Add tester emails (must match profile emails in the app for best UX).

**Removing testers:**
Remove emails from the group. They won't receive future invites.

**Beta consent tracking:**
- Tracked via the `isBetaTester` and `betaConsentGiven` fields in user profiles.
- Users who haven't consented remain in the distribution group but are prompted in-app.

---

## Troubleshooting

**Testers didn't receive invite:**
- Check email address matches Firebase group and user profile email.
- Verify group was included in distribution command.
- Check spam folder or Firebase App Tester app notifications.

**Build fails on iOS:**
- Confirm signing certificates and provisioning profiles are correctly configured for beta flavour.
- Check `ExportOptions.plist` contains correct `method: app-store` or `method: ad-hoc`.

**Android tester sees "App not installed":**
- Ensure APK is built for `release` mode, not debug.
- Verify proper signing key and build configuration in `build.gradle`.

---

## Best practices

1. **Always dry-run internally** before rolling out to school ambassadors. Log findings in `dry-run-log.md`.
2. **Capture release notes** with each build (feature highlights, known issues, fixes).
3. **Monitor feedback:** Review `betaFeedback` Firestore collection weekly. Respond to critical issues within 48 hours.
4. **Version naming:** Use semantic versioning with beta suffix (e.g. `1.0.0+1-beta.5`).
5. **Automation > manual:** Once CI is validated, always distribute via automated pipeline to ensure consistency.

---

## Further reading

- [Firebase App Distribution docs](https://firebase.google.com/docs/app-distribution)
- [`tester-guide.md`](tester-guide.md) – Instructions for beta users
- [`privacy-consent.md`](privacy-consent.md) – Consent form details
