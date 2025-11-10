# Privacy Statement Update - Crash Reporting

## Overview

This document outlines the data collection practices related to Firebase Crashlytics crash reporting in the TeenTalk application.

## What is Crash Reporting?

Crash reporting is a technology that automatically detects when the app stops working unexpectedly (crashes) and sends technical information to our development team. This helps us identify and fix problems quickly to improve the app experience for all users.

## What Data is Collected?

When the app crashes, the following technical information is automatically collected:

### Automatically Collected Data

- **Device Information**: Device model, operating system version, screen size
- **App Information**: App version, build number
- **Crash Details**: Technical error messages, code stack traces
- **Performance Metrics**: Memory usage, battery level at time of crash

### Custom Metadata (Privacy-Safe)

To help us better understand and prioritize fixes, we also collect:

- **User ID**: Your anonymous Firebase User ID (not your name or email)
- **School**: Your school name (if you've provided it in your profile)
- **Account Status**: Whether you've completed onboarding
- **Age Category**: Whether you're registered as a minor

### What We DON'T Collect

We **never** collect:
- Your email address
- Your phone number
- Your display name or nickname
- The content of your posts or messages
- Your location
- Your photos
- Any other personally identifiable information (PII)

## How is This Data Used?

Crash data is used exclusively to:

1. **Identify bugs**: Detect technical problems in the app
2. **Prioritize fixes**: Understand which issues affect the most users
3. **Improve stability**: Make the app more reliable and less prone to crashes
4. **Test solutions**: Verify that fixes actually resolve the problems

The data is **never** used for:
- Marketing or advertising
- Selling to third parties
- User profiling or tracking
- Any purpose other than improving app stability

## Who Has Access to This Data?

- **Development Team**: Our engineers use crash data to fix bugs
- **Firebase/Google**: Data is stored on Google's secure Firebase infrastructure
- **No Third Parties**: We do not share this data with advertisers or other third parties

## Data Retention

- Crash data is retained for 90 days in Firebase Crashlytics
- After 90 days, individual crash reports are automatically deleted
- Aggregated statistics (crash rates, trends) are retained longer for analysis

## Your Privacy Rights

### Opt-Out Option

You can opt out of crash reporting at any time:

1. Open the app
2. Go to **Profile** → **Privacy Settings**
3. Toggle **Crash Reporting** to OFF

**Note**: When you opt out, we will not be able to detect if the app crashes for you, which may limit our ability to provide you with a stable experience.

### Data Deletion

If you delete your account, we will:
- Stop collecting crash data for your user ID immediately
- Delete any crash reports associated with your user ID within 30 days

### GDPR and Privacy Laws

This crash reporting implementation complies with:
- **GDPR** (General Data Protection Regulation)
- **COPPA** (Children's Online Privacy Protection Act)
- **CCPA** (California Consumer Privacy Act)

We only collect the minimum data necessary to improve app stability, and all data is processed with appropriate security measures.

## Debug Mode

When you run the app in debug/development mode:
- Crash reporting is **automatically disabled**
- No crash data is sent to Firebase
- This ensures developer testing doesn't pollute production data

## Security

All crash data is:
- Transmitted over **encrypted connections (HTTPS)**
- Stored on **secure Firebase servers**
- Accessible only to **authorized team members**
- Protected by **Google's enterprise security measures**

## Questions or Concerns?

If you have questions about crash reporting or privacy:

- Email: privacy@teentalk.app
- Review our full Privacy Policy: [Link to full privacy policy]
- Contact support through the app

## Changes to This Statement

We will notify users of any material changes to our crash reporting practices:
- In-app notification
- Email to registered users
- Update to this document with version history

## Version History

- **v1.0.0** (Current): Initial crash reporting implementation
  - Firebase Crashlytics integration
  - Opt-out capability
  - Privacy-safe metadata collection

---

**Last Updated**: [Date]  
**Effective Date**: [Date]  
**Version**: 1.0.0
