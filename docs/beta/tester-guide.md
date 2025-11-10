# TeenTalk Beta Tester Guide

Thank you for volunteering to test TeenTalk! This guide walks you through setup, installation, and how to share feedback that improves the experience for everyone.

---

## What is beta testing?

As a beta tester, you'll receive pre-release builds of TeenTalk before they hit the app stores. These builds may have new features, bug fixes, or changes that require your feedback. Your input shapes the final product.

**Key responsibilities:**
- Install beta builds promptly (usually released weekly or bi-weekly).
- Use the app as you normally would and report bugs, crashes, or confusing workflows.
- Respect the pre-release nature of the software (avoid sharing screenshots publicly unless approved).
- Provide constructive, detailed feedback through the in-app form.

---

## Getting started

### Step 1: Accept the invitation

You'll receive an email from **Firebase App Distribution** inviting you to test TeenTalk. The email will look something like this:

> **Subject:** You've been invited to test TeenTalk  
> **From:** noreply@firebase.com

1. Open the email.
2. Click the **Accept Invitation** button or link.
3. Sign in using the same email address registered in your TeenTalk profile.
4. You'll be directed to install the Firebase App Tester (Android) or added to TestFlight (iOS).

**Important:** If the invitation email doesn't show up within 24 hours of being added, check your spam folder or contact the product team.

---

### Step 2: Install the tester app

#### Android

1. Download **Firebase App Tester** from the Google Play Store.
2. Open the app and sign in with your Firebase invitation email.
3. You'll see TeenTalk listed. Tap **Download** to install the latest build.
4. Once installed, open TeenTalk and sign in with your usual credentials.

#### iOS

1. Open the invitation link on your iPhone or iPad. It will redirect to **TestFlight**.
2. If you don't have TestFlight, you'll be prompted to download it from the App Store.
3. Once TestFlight is installed, tap **Accept** on the TeenTalk invitation.
4. Install the app from TestFlight. A blue dot will appear on the icon indicating it's a beta build.
5. Launch TeenTalk and sign in.

**Pro tip:** TestFlight builds expire after 90 days. You'll receive notifications when new builds are available.

---

### Step 3: Join the beta program in-app

1. Open TeenTalk and navigate to **Profile**.
2. Scroll to the **Beta Program** card.
3. Toggle **Join TeenTalk Beta** to ON.
4. Review and accept the consent prompt. If you're under 18, confirm your guardian is aware and approves your participation.

Once you've joined, you can:
- Send feedback directly from the app
- View the tester guide (this doc)
- Check your beta consent status and opt out at any time

---

## Using the beta build

Use TeenTalk just like you normally would. Try all the features:
- Post spotted updates (anonymous and public)
- Comment and like posts
- Send direct messages
- Browse notifications
- Switch between light/dark themes
- Update your profile

**Look out for:**
- Features that don't work as expected
- Crashes or freezing
- Typos, confusing wording, or broken layouts
- Performance issues (slow loading, laggy animations)

---

## Submitting feedback

The fastest way to help us improve TeenTalk is to report issues or suggest features through the in-app feedback form.

### How to send feedback

1. Go to **Profile** → **Beta Program** → **Send Feedback**.
2. Choose a **Feedback Type:**
   - **Bug Report:** Something broken or not working correctly
   - **Feature Request:** An idea for a new feature
   - **Improvement:** Enhancements to existing features
   - **Other:** General comments or questions
3. Set the **Priority:**
   - **Low:** Minor issue, doesn't block usage
   - **Medium:** Noticeable problem but workaround exists
   - **High:** Significant issue affecting key features
   - **Critical:** App crash or data loss
4. Write a clear **Title** (e.g. "Posts don't load on Android 13").
5. Provide a detailed **Description** including:
   - What you were trying to do
   - What happened (vs. what you expected)
   - Steps to reproduce the issue
   - Screenshots or screen recordings (if possible)
6. Tap **Submit Feedback**.

**Example bug report:**

**Title:** Messages don't send when offline  
**Description:**  
When I try to send a message with no Wi-Fi or mobile data, the app shows "Sending..." but never delivers the message when I reconnect. Steps to reproduce:
1. Turn on Airplane Mode.
2. Open Messages and try sending a message.
3. Turn off Airplane Mode.
4. Expected: Message sends. Actual: Message stays in "Sending..." state.  
Device: Pixel 7, Android 14

**Your feedback is stored in Firestore and reviewed by the product team.** We'll respond via the app or email within a few days, depending on priority.

---

## Dry-run checklist

Before we open beta testing to the wider group (school ambassadors), internal testers complete a "dry run" to catch major issues early. If you're part of the internal group, run through this checklist after each build:

- [ ] **Login:** Sign in with email/password and Google Sign-In.
- [ ] **Onboarding:** Complete profile setup (nickname, school, gender, privacy preferences).
- [ ] **Feed:** View recent posts, scroll, like, and comment.
- [ ] **Post composer:** Create a spotted post (anonymous and public), add text, confirm it appears in feed.
- [ ] **Direct messages:** Start a conversation, send/receive messages, see read receipts.
- [ ] **Notifications:** Verify push notifications arrive for likes, comments, and messages.
- [ ] **Profile:** Edit profile settings, toggle privacy options, view activity stats.
- [ ] **Admin (if applicable):** Access moderation queue, review/hide reported content, see audit logs.
- [ ] **Themes:** Switch between light and dark modes.
- [ ] **Beta feedback:** Submit a test feedback item, confirm it appears in the `betaFeedback` collection.

Log any failures or unexpected behaviour in the feedback form.

---

## Privacy & consent

### Data collection

As a beta tester, we collect the following data when you submit feedback:
- Your user ID and nickname
- Device information (OS, version, model)
- App version
- Feedback content (title, description, priority, type)
- Timestamp of submission

**We do not share this data externally.** It's used solely to triage and resolve issues during beta testing.

### Consent

By joining the beta program, you consent to:
- Receiving pre-release builds with potential bugs or incomplete features
- Submitting feedback that may include screenshots or personal observations about app usage
- Having your feedback stored in Firestore and reviewed by the TeenTalk team

**If you're a minor (under 18):** A parent or guardian must review this guide and provide consent before you participate. See [`privacy-consent.md`](privacy-consent.md) for a printable consent form.

### Opting out

You can leave the beta program at any time:
1. Go to **Profile** → **Beta Program**.
2. Toggle **Join TeenTalk Beta** to OFF.
3. You'll stop receiving future beta build invitations. Your previously submitted feedback remains in the system for analysis.

---

## FAQ

**Q: How often are beta builds released?**  
A: We aim for weekly or bi-weekly releases, depending on the development cycle. You'll get push notifications from Firebase App Tester / TestFlight when a new build is available.

**Q: Can I use both the beta and production versions of TeenTalk?**  
A: On Android, yes (different package names). On iOS, TestFlight installs override the App Store version, so you can only have one active at a time.

**Q: What if I find a security vulnerability?**  
A: Report it immediately via the feedback form with **Critical** priority, and email the team directly at [your-security-email@example.com].

**Q: Will my data carry over when the app goes live?**  
A: Yes, if you're using the same Firebase project. Your profile, posts, and messages persist across beta and production builds.

**Q: Who can I contact for support?**  
A: Use the in-app feedback form for technical issues. For account or privacy questions, email [your-support-email@example.com].

---

## Acknowledgements

Thank you for dedicating time to making TeenTalk better. Your feedback directly influences the features and quality of the final release. We're excited to build this with you!

**Happy testing!**  
*– The TeenTalk Team*
