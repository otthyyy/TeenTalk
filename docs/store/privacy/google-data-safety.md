# Google Play Data Safety Form

This document provides the responses for the **Data safety** section in Google Play Console for TeenTalk.

Refer to: [Google Play Data Safety Guidelines](https://support.google.com/googleplay/android-developer/answer/10787469)

---

## Data Collection & Sharing

### 1. Data Collection
- **Does your app collect or share any of the required user data types?**
  - ✅ **Yes, collects data**
  - ❌ **No, does not share data with third parties** (outside of service providers like Firebase)

### 2. Data Encryption in Transit
- ✅ All user data is encrypted in transit (HTTPS/TLS)

### 3. Data Deletion
- ✅ Users can request deletion of their data (Settings > Delete Account or email support@teentalk.app)

---

## Data Types Collected

| Data Type | Collected | Shared | Purpose | Required for Use? | Data Handling |
|-----------|----------|--------|---------|-------------------|---------------|
| **Name** (first name, optional) | Yes | No | App functionality (profile display) | No | Users can edit/delete
| **Email address** | Yes | No | Account creation, login, support | Yes | Deleted upon account removal
| **Phone number** (optional) | Yes | No | Phone authentication | No | Deleted upon account removal
| **User IDs** (Firebase UID) | Yes | No | Account identification | Yes | Deleted upon account removal
| **Device or other IDs** | Yes | No | Analytics, crash diagnostics | No | Automatically collected
| **User-generated content** (posts, comments, messages) | Yes | No | Core app functionality | Yes | Deleted upon account removal
| **Photos** (profile picture, post images) | Yes | No | User profile, post content | No | Deleted upon account removal
| **Crash logs** | Yes | No | Diagnostics, app stability (Crashlytics) | No | Opt-out available
| **App interactions** (feature usage) | Yes | No | Analytics, improve experience | No | Aggregated, anonymized
| **In-app search history** | No | No | N/A | N/A | N/A
| **Location** | No | No | N/A | N/A | N/A
| **Financial info** | No | No | N/A | N/A | N/A
| **Health info** | No | No | N/A | N/A | N/A
| **Contacts** | No | No | N/A | N/A | N/A
| **Calendar** | No | No | N/A | N/A | N/A
| **Call logs** | No | No | N/A | N/A | N/A
| **Files and docs** | No | No | N/A | N/A | N/A
| **Audio** | No | No | N/A | N/A | N/A
| **SMS or MMS** | No | No | N/A | N/A | N/A

---

## Purposes of Data Collection

| Purpose | Data Types |
|---------|------------|
| **App functionality** | Name, email, user ID, user-generated content, photos |
| **Analytics** | User ID (anonymized), device IDs, app interactions, crash logs |
| **Account management** | Email, phone number, user ID |
| **Personalization** | Trust badges, profile information |
| **Developer communications** | Email address |
| **Fraud prevention/security** | User ID, device ID |

---

## Data Handling Details

### User Control
- Users can edit or delete profile information within the app.
- Users can request data deletion by deleting their account (Settings > Delete Account) or emailing support@teentalk.app.
- Users can opt out of crash reporting (Profile > Privacy Settings > Crash Reporting).

### Data Retention
- User data is retained for as long as the account is active.
- Upon account deletion, data removal is triggered within 30 days.
- Crash data retained for 90 days (per Firebase Crashlytics policy).

### Data Sharing
- TeenTalk does not sell user data.
- Data is shared only with infrastructure service providers (Firebase) under data processing agreements.

### Security Practices
- All communication uses HTTPS.
- Firebase security rules restrict data access to authenticated users.
- Role-based access for internal staff.

---

## Additional Disclosures

### Target Audience
- Teens aged 13–18 (COPPA compliance with parental consent)

### Data Safety Description (Play Console)
Use the following wording for the Play Store listing:

> TeenTalk collects limited information to operate your account, enable community features, and keep the app safe. We ask for your email (and optionally phone number) to sign in, and store the content you choose to share, like posts, comments, and messages. We may also collect anonymous app diagnostics to improve performance. You can control your privacy settings, opt out of crash reporting, or delete your account at any time. Your data is never sold or used for advertising.

---

## Testing Notes for Reviewers

1. Launch the app and sign in with reviewer account (provided separately).
2. Navigate to **Profile → Privacy Settings** to view crash reporting opt-out.
3. Go to **Profile → Settings → Delete Account** to see data deletion flow.
4. Verify privacy policy link: https://teentalk.app/privacy

---

## Contact
- **Privacy Contact:** privacy@teentalk.app
- **Support:** support@teentalk.app
- **Address:** TeenTalk HQ, 1234 Campus Drive, San Francisco, CA 94107

---

## Last Updated
December 2024

## Version
1.0.0 (initial release)
