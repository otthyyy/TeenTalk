# TeenTalk Analytics Events

This document defines the analytics events tracked in the TeenTalk application. All events are logged through `AnalyticsService` and map directly to Firebase Analytics events.

> **Privacy:** No personally identifiable information (PII) is collected. Events only include contextual metadata such as school, anonymized identifiers, and feature usage details.

## Table of Contents
- [User Context](#user-context)
- [Authentication & Onboarding](#authentication--onboarding)
- [Feed & Posts](#feed--posts)
- [Comments](#comments)
- [Moderation](#moderation)
- [Notifications](#notifications)
- [Sharing](#sharing)
- [Search](#search)
- [Profile](#profile)
- [Privacy & Preferences](#privacy--preferences)

---

## User Context

| Property | Firebase Key | Description |
| --- | --- | --- |
| School | `school` | User's school (string). |
| Is Minor | `is_minor` | Whether the user is a minor (`true/false`). |
| Parental Consent | `has_parental_consent` | Indicates if parental consent is recorded (`true/false`). |
| Is Admin | `is_admin` | User has admin privileges (`true/false`). |
| Is Moderator | `is_moderator` | User has moderator privileges (`true/false`). |

User properties are set after onboarding and cleared on sign out.

## Authentication & Onboarding

| Event | Key | Parameters | Description |
| --- | --- | --- | --- |
| Sign Up | `sign_up` | `method` | Fired when the user completes sign-up (`email`, `google`, `phone`, `anonymous`). |
| Sign In | `sign_in` | `method` | Fired when the user signs in. |
| Sign Out | `sign_out` | — | Fired when the user signs out; also clears user properties. |
| Onboarding Started | `onboarding_started` | — | Fired when entering the onboarding flow. |
| Onboarding Step Completed | `onboarding_step_completed` | `step_number`, `step_name` | Fired after each onboarding step. |
| Onboarding Completed | `onboarding_completed` | `school`, `is_minor` | Fired when onboarding is completed. |

## Feed & Posts

| Event | Key | Parameters | Description |
| --- | --- | --- | --- |
| Feed Section Changed | `feed_section_changed` | `section`, `previous_section` | User switches feed tab (e.g., `spotted`, `general`). |
| Feed Refreshed | `feed_refreshed` | `section` | Pull-to-refresh on current feed section. |
| Post Viewed | `post_viewed` | `content_id`, `post_section`, `is_anonymous` | Post enters viewport. |
| Post Liked | `post_liked` | `content_id`, `post_section` | User likes a post. |
| Post Unliked | `post_unliked` | `content_id`, `post_section` | User removes a like. |
| Post Creation Started | `post_creation_started` | `post_section` | User opens composer from a section. |
| Post Created | `post_created` | `content_id`, `post_section`, `is_anonymous` | Post successfully published. |
| Post Creation Cancelled | `post_creation_cancelled` | `post_section` | User exits composer without posting. |

## Comments

| Event | Key | Parameters | Description |
| --- | --- | --- | --- |
| Comments Viewed | `comments_viewed` | `post_id` | User opens comments for a post. |
| Comment Created | `comment_created` | `content_id`, `post_id` | User publishes a comment. |

## Moderation

| Event | Key | Parameters | Description |
| --- | --- | --- | --- |
| Content Reported | `content_reported` | `content_id`, `reported_content_type`, `report_reason` | User reports content (post/comment). |
| User Blocked | `user_blocked` | `blocked_user_id` | User blocks another user. |
| User Unblocked | `user_unblocked` | `unblocked_user_id` | User unblocks a previously blocked user. |

## Notifications

| Event | Key | Parameters | Description |
| --- | --- | --- | --- |
| Notification Received | `notification_received` | `notification_type` | Push notification delivered (app foreground/background). |
| Notification Opened | `notification_opened` | `notification_type`, `action_taken` | User opens a notification or performs an action. |
| Notification Settings Changed | `notification_settings_changed` | `setting`, `enabled` | User toggles notification preferences. |

## Sharing

| Event | Key | Parameters | Description |
| --- | --- | --- | --- |
| Content Shared | `content_shared` | `content_id`, `content_type`, `share_method`, `share_destination` | User shares a post/comment. |

## Search

> **Note:** Search instrumentation is prepared for future implementation.

| Event | Key | Parameters | Description |
| --- | --- | --- | --- |
| Search Performed | `search_performed` | `search_query`, `result_count` | User executes a search query. |
| Search Result Clicked | `search_result_clicked` | `search_query`, `content_id`, `content_type` | User selects a search result. |

## Profile

| Event | Key | Parameters | Description |
| --- | --- | --- | --- |
| Profile Viewed | `profile_viewed` | `profile_id` | User views another profile. |
| Profile Edited | `profile_edited` | — | User updates their profile information. |

## Privacy & Preferences

| Event | Key | Parameters | Description |
| --- | --- | --- | --- |
| Privacy Settings Changed | `privacy_settings_changed` | `setting_name` | User updates a privacy preference (including analytics). |
| Analytics Opted In | `analytics_opted_in` | — | User explicitly enables analytics collection. |
| Analytics Opted Out | `analytics_opted_out` | — | User disables analytics collection. |
