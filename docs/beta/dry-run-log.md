# Beta Dry-Run Log

This log tracks internal testing (dry-run) results for each beta build before distributing to the wider school ambassadors group. It ensures critical features are functional and reduces the risk of major regressions reaching external testers.

---

## Instructions

1. Before distributing a beta build externally, assign at least **two internal testers** to complete the smoke checklist.
2. Record findings below with build version, date, tester initials, and pass/fail status for each item.
3. If any item fails, log the issue in the `betaFeedback` Firestore collection or your issue tracker and **hold distribution** until resolved.
4. Once all critical items pass, proceed with Firebase App Distribution to the `internal` and `school-ambassadors` groups.

---

## Dry-run checklist

**Tested features:**

- **Login & authentication**  
  - Email/password sign-in  
  - Google Sign-In  
  - Sign-out and re-auth  
- **Onboarding**  
  - Profile setup (nickname, school, gender)  
  - Privacy preferences  
  - Parental consent prompt (for minors)  
  - Beta consent opt-in  
- **Feed**  
  - View posts (public + anonymous)  
  - Like a post  
  - Comment on a post  
  - Scroll performance (no stuttering)  
- **Post composer**  
  - Create a post (anonymous)  
  - Create a post (public)  
  - Character limits enforced  
  - Post appears in feed immediately  
- **Direct messages**  
  - Start a new conversation  
  - Send a message  
  - Receive a message (real-time)  
  - Read receipts update correctly  
- **Notifications**  
  - Push notification for new like  
  - Push notification for new comment  
  - Push notification for new message  
  - Notification navigation to target screen  
- **Profile**  
  - View own profile  
  - Edit profile settings (nickname, school, gender)  
  - Toggle privacy settings (anonymous posts, profile visibility)  
  - View consent history  
  - Join beta programme toggle  
- **Admin panel (if user is admin/moderator)**  
  - View moderation queue  
  - Hide/approve reported content  
  - View audit logs  
- **Beta feedback**  
  - Open feedback form  
  - Submit a test feedback item  
  - Verify submission in Firestore `betaFeedback` collection  
- **Themes**  
  - Switch between light and dark mode  
  - UI elements render correctly in both themes  
- **Cross-platform (if applicable)**  
  - Test on Android (emulator/device)  
  - Test on iOS (simulator/device)  

---

## Test results

### Build: v1.0.0+1-beta.1  
**Date:** YYYY-MM-DD  
**Testers:** [Initials]  

| Feature                          | Status | Notes                                      |
|----------------------------------|--------|--------------------------------------------|
| Login (email/password)           | ✅ Pass |                                            |
| Login (Google)                   | ✅ Pass |                                            |
| Onboarding (profile setup)       | ✅ Pass |                                            |
| Feed (view/like/comment)         | ✅ Pass |                                            |
| Post composer (anonymous/public) | ✅ Pass |                                            |
| Direct messages (send/receive)   | ✅ Pass |                                            |
| Push notifications               | ❌ Fail | Notifications not arriving on Android 13   |
| Profile (edit settings)          | ✅ Pass |                                            |
| Admin panel (moderation)         | ✅ Pass | Tested by admin user only                  |
| Beta feedback form               | ✅ Pass |                                            |
| Themes (light/dark)              | ✅ Pass |                                            |

**Outcome:** ❌ **Hold distribution**  
**Action items:**
- Investigate notification delivery on Android 13 (check FCM token registration).
- Retest and update log once resolved.

---

### Build: v1.0.0+1-beta.2  
**Date:** YYYY-MM-DD  
**Testers:** [Initials]  

| Feature                          | Status | Notes                                      |
|----------------------------------|--------|--------------------------------------------|
| Login (email/password)           | ✅ Pass |                                            |
| Login (Google)                   | ✅ Pass |                                            |
| Onboarding (profile setup)       | ✅ Pass |                                            |
| Feed (view/like/comment)         | ✅ Pass |                                            |
| Post composer (anonymous/public) | ✅ Pass |                                            |
| Direct messages (send/receive)   | ✅ Pass |                                            |
| Push notifications               | ✅ Pass | Fixed: FCM token registration corrected    |
| Profile (edit settings)          | ✅ Pass |                                            |
| Admin panel (moderation)         | ✅ Pass |                                            |
| Beta feedback form               | ✅ Pass |                                            |
| Themes (light/dark)              | ✅ Pass |                                            |

**Outcome:** ✅ **Approved for distribution**  
**Action items:**
- Distribute to `internal` and `school-ambassadors` groups.
- Monitor feedback for 24 hours before wider rollout.

---

## Template for new builds

Copy the section below for each new beta release:

```markdown
### Build: v[version]+build-beta.[number]  
**Date:** YYYY-MM-DD  
**Testers:** [Initials]  

| Feature                          | Status | Notes |
|----------------------------------|--------|-------|
| Login (email/password)           |        |       |
| Login (Google)                   |        |       |
| Onboarding (profile setup)       |        |       |
| Feed (view/like/comment)         |        |       |
| Post composer (anonymous/public) |        |       |
| Direct messages (send/receive)   |        |       |
| Push notifications               |        |       |
| Profile (edit settings)          |        |       |
| Admin panel (moderation)         |        |       |
| Beta feedback form               |        |       |
| Themes (light/dark)              |        |       |

**Outcome:** [ ] Pass / [ ] Hold  
**Action items:**
- 

---
```

Keep this log up to date to maintain a historical record of testing quality before each beta release.
