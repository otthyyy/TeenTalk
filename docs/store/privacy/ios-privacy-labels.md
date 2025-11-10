# iOS App Privacy Details (Privacy Labels)

This document provides the information required to complete the **App Privacy** questionnaire in App Store Connect for TeenTalk.

## Overview

Apple requires apps to disclose their data collection and usage practices in a standardized privacy "nutrition label" format. This appears on the App Store product page before download.

Refer to: [Apple App Privacy Documentation](https://developer.apple.com/app-store/app-privacy-details/)

---

## App Privacy Questionnaire Responses

### Section 1: Data Collection

**Q: Does this app collect data from this app?**
✅ **Yes**

---

### Section 2: Data Types Collected

#### Contact Info

**Email Address**
- ✅ Collected
- **Linked to User:** Yes
- **Used for Tracking:** No
- **Purposes:**
  - App Functionality (authentication, account management)
  - Developer Communications (support, product updates)

**Phone Number** (optional sign-in method)
- ✅ Collected
- **Linked to User:** Yes
- **Used for Tracking:** No
- **Purposes:**
  - App Functionality (authentication via phone OTP)

**Name** (first name only, optional)
- ✅ Collected
- **Linked to User:** Yes
- **Used for Tracking:** No
- **Purposes:**
  - App Functionality (profile display)

---

#### User Content

**User-Generated Content** (posts, comments, messages)
- ✅ Collected
- **Linked to User:** Yes
- **Used for Tracking:** No
- **Purposes:**
  - App Functionality (social features)

**Photos or Videos** (profile picture, post attachments – optional)
- ✅ Collected
- **Linked to User:** Yes
- **Used for Tracking:** No
- **Purposes:**
  - App Functionality (user profile and content sharing)

---

#### Identifiers

**User ID** (Firebase UID)
- ✅ Collected
- **Linked to User:** Yes
- **Used for Tracking:** No
- **Purposes:**
  - App Functionality (authentication, user account management)
  - Analytics (crash reporting, aggregated usage insights)

**Device ID** (automatically collected by Firebase)
- ✅ Collected
- **Linked to User:** No
- **Used for Tracking:** No
- **Purposes:**
  - Analytics (crash reporting, session data)

---

#### Usage Data

**Product Interaction** (features used, screens visited)
- ✅ Collected
- **Linked to User:** No
- **Used for Tracking:** No
- **Purposes:**
  - Analytics (understand feature usage, improve app)

**Crash Data** (stack traces, device info)
- ✅ Collected
- **Linked to User:** No (anonymized User ID only)
- **Used for Tracking:** No
- **Purposes:**
  - App Functionality (bug fixes, stability improvements)
- **Opt-out:** Yes (see Profile > Privacy Settings)

---

#### Diagnostics

**Crash Data**
- ✅ Collected
- **Linked to User:** No
- **Used for Tracking:** No
- **Purposes:**
  - App Functionality (debugging, crash analysis)
- **Opt-out:** Yes

**Performance Data** (app launch time, network errors)
- ✅ Collected
- **Linked to User:** No
- **Used for Tracking:** No
- **Purposes:**
  - App Functionality (performance monitoring)

---

### Section 3: Tracking

**Q: Does this app use data for tracking purposes?**
❌ **No**

**Definition of Tracking (per Apple):** Data collected from this app and linked with data collected from other companies' apps, websites, or offline properties for targeted advertising or advertising measurement purposes.

**TeenTalk does not:**
- Share user data with third-party advertisers
- Use data for targeted advertising
- Track users across other apps or websites
- Sell user data

---

### Section 4: Data Linked to User

The following data is **linked** to the user's identity:

- Email address
- Phone number (if provided)
- First name (if provided)
- User-generated content (posts, comments, messages)
- Profile photos
- User ID (Firebase UID)

---

### Section 5: Data Not Linked to User

The following data is **not linked** to the user's identity:

- Device ID (used for crash reporting)
- Crash logs and diagnostics
- Aggregated usage statistics
- Performance metrics

---

### Section 6: Third-Party SDKs

**Firebase (Google)**
- **Services Used:** Authentication, Firestore, Storage, Crashlytics, Analytics
- **Purpose:** Backend infrastructure, crash reporting, usage insights
- **Privacy Policy:** https://firebase.google.com/support/privacy
- **Data Collected:** User ID, crash data, device info, usage events

---

## Privacy Policy Link

**URL:** https://teentalk.app/privacy

Ensure this link:
- Is publicly accessible (no login required)
- Explains data collection practices in detail
- Describes user rights (access, deletion, opt-out)
- References COPPA, GDPR, CCPA compliance

---

## Parental Consent (COPPA)

Since TeenTalk targets users under 18, the following applies:

- **Parental Consent Required:** Yes, for users under 18 (prompted during onboarding)
- **Data Minimization:** Only collect data necessary for app functionality
- **Parental Controls:** Parents can request account deletion by contacting support@teentalk.app

---

## User Rights

Users can:
- **Access data:** View profile info in-app
- **Delete account:** Profile > Settings > Delete Account
- **Opt out of crash reporting:** Profile > Privacy Settings > Crash Reporting
- **Request data export:** Email support@teentalk.app

---

## Compliance Notes

**COPPA (Children's Online Privacy Protection Act)**
- Parental consent obtained before collecting data from users under 18
- Clear privacy policy describing data practices
- No ads or third-party tracking

**GDPR (General Data Protection Regulation)**
- Users in EU have data access, portability, and deletion rights
- Consent is freely given and can be withdrawn
- Privacy by design principles followed

**CCPA (California Consumer Privacy Act)**
- California users can request data deletion or opt out of data "sales" (TeenTalk does not sell data)

---

## Review Notes for Apple

**Test Account:**
- Email: reviewer@teentalk.test
- Password: TeenTalk2024Review!
- Note: Account is pre-configured with sample data for review

**Privacy Features to Test:**
1. Navigate to Profile > Privacy Settings
2. Toggle "Crash Reporting" to OFF
3. Verify opt-out confirmation
4. Test account deletion flow (Profile > Settings > Delete Account)

**Questions:**
Contact privacy@teentalk.app for any clarifications.

---

## Last Updated
December 2024

## Version
1.0.0
