# TeenTalk Beta Program

Welcome to the TeenTalk beta program documentation hub. This folder centralises everything needed to operate, distribute, and support beta builds across Android and iOS using Firebase App Distribution.

## Contents

- [`distribution.md`](distribution.md) – Operational checklist for preparing and shipping a beta build.
- [`tester-guide.md`](tester-guide.md) – Onboarding flow, install steps, and feedback guidance shared with testers.
- [`privacy-consent.md`](privacy-consent.md) – Consent language for testers (and guardians where required).
- [`dry-run-log.md`](dry-run-log.md) – Record of smoke tests executed before inviting the wider group.

## Quick summary

- **Distribution channel:** Firebase App Distribution with two managed groups: `internal` (core team) and `school-ambassadors` (pilot students).
- **Feedback loop:** In-app "Send Feedback" form writes to the `betaFeedback` Firestore collection. Responses are triaged by the product team.
- **Consent:** Testers must accept the in-app consent prompt before toggling the beta switch. Guardians for minors should sign the form contained in `privacy-consent.md`.
- **Dry runs:** Every release must pass the smoke checklist captured in `dry-run-log.md` before distribution.

Use this index to keep the beta programme aligned across engineering, product, and school partners.
