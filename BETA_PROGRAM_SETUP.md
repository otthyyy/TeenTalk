# TeenTalk Beta Program Setup Summary

This document summarizes the beta program implementation for TeenTalk, including in-app features, Firebase App Distribution integration, documentation, and CI/CD automation.

## ✅ Implemented Features

### 1. In-App Beta Program Management

**User Profile Integration:**
- Added `isBetaTester`, `betaConsentGiven`, and `betaConsentTimestamp` fields to `UserProfile` model
- Beta program card visible on Profile page with toggle to join/leave
- In-app consent dialog captures user agreement before joining
- Guardian approval explicitly mentioned for minor users (under 18)

**Beta Feedback System:**
- New feature module: `lib/src/features/beta_feedback/`
- **Models:** `BetaFeedback` with fields for type (bug/feature/improvement/other), priority, title, description, device info, app version
- **Service:** `BetaFeedbackService` handles submission and retrieval from Firestore `betaFeedback` collection
- **UI:** `BetaFeedbackFormPage` provides intuitive form for submitting feedback with type/priority dropdowns
- **Route:** `/beta-feedback` accessible from Profile page for beta testers
- **Firestore rules:** Secure access so users can only read their own feedback; moderators can read/update all feedback

**Tester Guide Integration:**
- In-app bottom sheet displays key onboarding steps, feedback instructions, and consent management
- Links to full documentation in `docs/beta/tester-guide.md`
- Accessible via "View Tester Guide" button on beta program card

### 2. Firebase Configuration

**Firestore Security Rules:**
```firestore
match /betaFeedback/{feedbackId} {
  allow read: if isAuthenticated() &&
    (resource.data.userId == request.auth.uid || isModerator());
  allow create: if isAuthenticated() &&
    request.auth.uid == request.resource.data.userId &&
    request.resource.data.createdAt is timestamp;
  allow update: if isModerator();
  allow delete: if isAdmin();
}
```

**Data Structure:**
- `betaFeedback` collection stores all feedback submissions
- Fields: id, userId, userNickname, type, priority, title, description, deviceInfo, appVersion, createdAt, status, adminResponse, respondedAt

### 3. Documentation (`docs/beta/`)

**Created files:**
- **`README.md`**: Overview of beta program structure, groups (internal, school ambassadors), feedback loop, consent requirements
- **`distribution.md`**: Operational guide for preparing and distributing beta builds (manual CLI and CI/CD automation)
- **`tester-guide.md`**: Comprehensive handbook for beta testers covering setup, installation (Android/iOS), feedback submission, dry-run checklist, privacy, FAQ
- **`privacy-consent.md`**: Printable consent form for testers and guardians, including signature fields and admin tracking section
- **`dry-run-log.md`**: Template for recording smoke test results before each beta release to wider groups
- **`templates/github-actions-beta.yml`**: GitHub Actions workflow template for automated build and distribution to Firebase App Distribution

### 4. CI/CD Integration Template

**GitHub Actions Workflow** (`docs/beta/templates/github-actions-beta.yml`):
- Triggers: push to `beta` branch, manual dispatch, or beta version tags (e.g. `v1.0.0-beta.1`)
- Builds Android APK and iOS IPA in parallel jobs
- Authenticates with Firebase CLI using `FIREBASE_TOKEN` secret
- Distributes to `internal` and `school-ambassadors` groups via Firebase App Distribution
- Uploads build artefacts to GitHub Actions for archival
- Includes release notes from manual input or commit metadata

**Setup required:**
1. Add `FIREBASE_TOKEN` to repository secrets (Firebase service account)
2. Update `YOUR_ANDROID_APP_ID` and `YOUR_IOS_APP_ID` placeholders with actual Firebase app IDs
3. Configure iOS signing certificates and provisioning profiles
4. Move template to `.github/workflows/beta-distribution.yml`

## 🚀 Beta Program Workflow

### For Developers:

1. **Prepare build:**
   - Ensure all features pass internal smoke tests (see `docs/beta/dry-run-log.md`)
   - Update version number with beta suffix (e.g. `1.0.0+2-beta.3`)

2. **Distribute:**
   - **Manual:** Use Firebase CLI commands documented in `docs/beta/distribution.md`
   - **Automated:** Push commit to `beta` branch or create beta tag to trigger GitHub Actions

3. **Monitor feedback:**
   - Review `betaFeedback` Firestore collection weekly
   - Respond to critical issues within 48 hours
   - Update feedback status and add admin responses in Firestore

### For Testers:

1. **Receive invitation:**
   - Email from Firebase App Distribution arrives with invitation link
   - Must use same email as TeenTalk profile for seamless UX

2. **Install tester app:**
   - **Android:** Firebase App Tester from Play Store
   - **iOS:** TestFlight app via App Store

3. **Join beta program:**
   - Open TeenTalk app, go to Profile → Beta Program
   - Toggle "Join TeenTalk Beta" to ON
   - Accept consent prompt (guardian approval required for minors)

4. **Submit feedback:**
   - Tap "Send Feedback" button on beta card
   - Fill out form with bug/feature details, priority, reproduction steps
   - Feedback stored in Firestore and triaged by product team

5. **Opt out:**
   - Toggle "Join TeenTalk Beta" to OFF at any time
   - Stops future beta build invitations

## 🔐 Privacy & Consent

**Consent Collection:**
- In-app dialog captures explicit consent before enabling beta tester status
- Consent timestamp and status stored in `betaConsentGiven` and `betaConsentTimestamp` fields
- Guardian approval explicitly mentioned for minors (printed form available in `docs/beta/privacy-consent.md`)

**Data Collected:**
- User ID and nickname (for attribution)
- Device info (OS, version, model) auto-captured on feedback submission
- App version
- Feedback content (title, description, type, priority)

**Data Usage:**
- Feedback stored securely in Firestore with restricted access (users read own, moderators read/update all)
- Used solely to improve TeenTalk during beta testing
- Not shared externally or used for marketing

## 📋 Beta Tester Groups

### Internal
- Core development and product team
- First recipients of new builds
- Execute dry-run smoke tests before wider distribution

### School Ambassadors
- Pilot students at Brescia schools
- Receive builds after internal dry-run passes
- Provide real-world usage feedback from target demographic

**Adding testers:**
1. Go to Firebase Console → App Distribution → Testers & Groups
2. Select `internal` or `school-ambassadors`
3. Add email addresses (must match TeenTalk profile emails for best UX)
4. New builds are automatically sent to all group members

## 🔧 Troubleshooting

**Build fails on iOS:**
- Verify signing certificates and provisioning profiles are configured correctly
- Check `ExportOptions.plist` specifies correct export method

**Testers don't receive invitations:**
- Confirm email matches both Firebase group and TeenTalk profile
- Check spam folder
- Verify tester group was included in distribution command

**Feedback not appearing in Firestore:**
- Check Firestore rules allow write access
- Verify `betaFeedbackServiceProvider` is properly configured
- Test with Firebase Emulator Suite locally

## 📖 Next Steps

1. **Set up Firebase App Distribution:**
   - Create `internal` and `school-ambassadors` groups in Firebase Console
   - Add initial tester emails

2. **Configure CI/CD:**
   - Store Firebase service account credentials in GitHub secrets
   - Update app IDs in workflow template
   - Test automated distribution with a beta tag

3. **Execute dry-run:**
   - Build first beta version
   - Have 2+ internal testers complete smoke checklist
   - Log results in `docs/beta/dry-run-log.md`

4. **Launch to school ambassadors:**
   - Once dry-run passes, distribute to wider group
   - Monitor feedback collection
   - Iterate based on tester input

5. **Document feedback responses:**
   - Update Firestore feedback documents with status and admin responses
   - Track issues in backlog and communicate resolutions to testers

---

## 📚 Reference Documentation

- [Firebase App Distribution Docs](https://firebase.google.com/docs/app-distribution)
- [`docs/beta/distribution.md`](docs/beta/distribution.md) – Distribution operational guide
- [`docs/beta/tester-guide.md`](docs/beta/tester-guide.md) – Tester onboarding handbook
- [`docs/beta/privacy-consent.md`](docs/beta/privacy-consent.md) – Consent form template
- [`docs/beta/dry-run-log.md`](docs/beta/dry-run-log.md) – Smoke test log template

---

**Developed by the TeenTalk Team**  
Version 1.0 | Last Updated: 2024-11-10
