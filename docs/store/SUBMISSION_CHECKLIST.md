# Store Submission Checklist

Use this checklist to ensure all required materials are ready before submitting TeenTalk to the App Store and Google Play Store.

## 1. Pre-Submission Preparation

- [ ] Confirm app version number updated in `pubspec.yaml`
- [ ] Confirm build numbers incremented for iOS (`Info.plist`) and Android (`build.gradle`)
- [ ] Run full QA regression (functional, accessibility, localization)
- [ ] Verify crash reporting opt-in/out flows (privacy requirements)
- [ ] Confirm all third-party licenses are up to date
- [ ] Update change log / release notes for both stores

## 2. Store Listing Assets

### Screenshots
- [ ] iPhone 6.7" English set (5 images)
- [ ] iPhone 6.7" Italian set (5 images)
- [ ] iPad 12.9" English set (5 images)
- [ ] iPad 12.9" Italian set (5 images)
- [ ] Android phone English set (8 images)
- [ ] Android phone Italian set (8 images)
- [ ] Android tablet English set (3 images)
- [ ] Android tablet Italian set (3 images)

### Feature Graphics & Icons
- [ ] iOS app icon (1024x1024, PNG)
- [ ] Android app icon (512x512, PNG)
- [ ] Google Play feature graphic (1024x500, PNG)
- [ ] Promotional images/videos (if available)

## 3. Store Copy & Localization

- [ ] App name, subtitle (iOS) localized to English & Italian
- [ ] Short description (Google Play) localized
- [ ] Full description (both stores) localized and proofread
- [ ] Keyword list (iOS) finalized and within 100 characters
- [ ] Promotional text (iOS) updated if needed
- [ ] What's New text localized for release notes
- [ ] Privacy policy URL verified and accessible

## 4. Privacy & Compliance

- [ ] iOS App Privacy questionnaire completed:
  - [ ] Data types collected identified
  - [ ] Data usage purposes declared (Analytics, App Functionality, etc.)
  - [ ] Data linked to user vs. not linked clarified
  - [ ] Data tracking disclosures confirmed (TeenTalk does not track across apps)
- [ ] Google Play Data Safety form updated:
  - [ ] Data collected list complete and accurate
  - [ ] Data purpose (analytics, app functionality, communication) documented
  - [ ] Data sharing settings correct
  - [ ] User deletion procedures described
- [ ] COPPA/GDPR compliance statement included
- [ ] Crashlytics privacy statement linked

## 5. Technical Requirements

- [ ] iOS build archived in Xcode (Product > Archive)
- [ ] Upload to App Store Connect via Transporter or Xcode
- [ ] Android App Bundle `aab` generated (`flutter build appbundle --release`)
- [ ] Play Console pre-launch report (automated) reviewed
- [ ] Firebase App Distribution testers notified (beta done)
- [ ] Release notes added to release tracks (internal, beta, production)

## 6. Review Notes & Test Accounts

- [ ] Provide reviewer credentials (email and password) for App Store
- [ ] Provide reviewer credentials for Google Play (if requested)
- [ ] Include sign-in instructions (email login, sample account steps)
- [ ] Detail any special hardware requirements (none)
- [ ] Add contact info for review questions (product@teentalk.app)

## 7. Final Verification

- [ ] Cross-check asset file names against requirements
- [ ] Confirm translations reviewed by native Italian speaker
- [ ] Review store page preview (App Store Connect & Play Console)
- [ ] Double-check release country list (US, Italy initially)
- [ ] Ensure parental guidance rating (App Store: 12+, Google Play: Teen)
- [ ] Validate age gate/onboarding flows from reviewer devices

## 8. Post-Submission Monitoring

- [ ] Monitor App Store review status daily
- [ ] Monitor Play Store review status (dashboard & email notifications)
- [ ] Prepare social media / press kit for go-live (if required)
- [ ] Coordinate support coverage for launch window
- [ ] Publish release notes on company blog/community

---

**Notes:**
- Keep screenshots, copy, and privacy documentation synchronized between updates.
- For urgent fixes, create an expedited release request only if necessary (App Store).
- Maintain a shared document with reviewer feedback for future iterations.

**Responsible Teams:**
- Product: owns checklist completion
- Design: owns assets and screenshots
- Marketing: owns store copy and keywords
- Legal/Privacy: owns compliance sections
- Engineering: owns build pipeline and technical notes
