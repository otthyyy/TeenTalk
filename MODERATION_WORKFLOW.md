# Moderation Workflow Implementation

This document describes the comprehensive moderation workflow system implemented for the Teen Talk app.

## Overview

The moderation system provides a complete content reporting and review workflow, including:
- In-app reporting UI for posts/comments
- Automatic content hiding based on report thresholds
- Audit logs for anonymous posts
- Admin moderation queue
- Client-side rate limiting and safeguards

## Architecture

### Data Models

#### ContentReport
Represents a report submitted by a user:
- `contentId`: ID of the reported content
- `contentType`: Type of content (post/comment)
- `reporterId`: User who submitted the report
- `contentAuthorId`: Author of the reported content
- `reason`: Reason for report (enum: spam, harassment, hate_speech, violence, sexual_content, misinformation, self_harm, other)
- `additionalDetails`: Optional additional context
- `status`: Report status (pending, under_review, resolved, dismissed)
- `createdAt`: Timestamp of report submission
- `resolvedAt`: Timestamp of resolution (if resolved)
- `resolvedBy`: Admin who resolved the report
- `resolutionNotes`: Admin notes on resolution

#### ModerationItem
Represents content under moderation:
- `contentId`: ID of the content
- `contentType`: Type of content (post/comment)
- `authorId`: Author of the content
- `reportCount`: Number of reports received
- `status`: Moderation status (active, hidden, removed)
- `hiddenAt`: Timestamp when content was hidden
- `reviewedAt`: Timestamp when reviewed by admin
- `reviewedBy`: Admin who reviewed the content
- `isAnonymous`: Whether content was posted anonymously
- `createdAt`: Content creation timestamp
- `updatedAt`: Last update timestamp

#### AuditLog
Immutable log entries for content actions (stored in subcollection):
- `contentId`: ID of the content
- `originalAuthorId`: Original author (preserved for anonymous posts)
- `action`: Action taken (post_created, post_reported, post_hidden, post_removed, post_restored)
- `performedBy`: User who performed the action
- `reason`: Reason for the action
- `metadata`: Additional metadata
- `timestamp`: Action timestamp

### Services

#### ModerationService
Client-side service for reporting and moderation operations:
- `submitReport()`: Submit a content report
- `isContentHidden()`: Check if content is hidden
- `getUserReportCount()`: Get user's report count for rate limiting
- `hasUserReportedContent()`: Check if user already reported content
- `getReportsForContent()`: Stream reports for specific content
- `getModerationQueue()`: Stream moderation queue items
- `resolveReport()`: Admin resolves a report
- `updateModerationStatus()`: Admin updates content status

**Rate Limiting:**
- Maximum 10 reports per user per day
- Rate limit checked before accepting reports
- Client-side warnings at 8+ reports

#### AuditLogService
Service for managing audit logs:
- `createAuditLog()`: Create new audit log entry
- `getAuditLogsForContent()`: Stream audit logs for content
- `getAuditLogsForUser()`: Get all audit logs for a user (admin only)

### Cloud Functions

#### onReportCreated
Triggered when a new report is created:
1. Increments report count in moderationQueue
2. Auto-hides content if report count >= 3
3. Creates audit log entries

#### onPostCreated
Triggered when a new post is created:
1. Creates audit log for anonymous posts
2. Stores original authorId in restricted subcollection

#### cleanupOldReports
Scheduled function (runs daily at midnight):
1. Removes resolved/dismissed reports older than 30 days
2. Helps maintain database performance

#### getModerationStats
Callable function for admins:
- Returns statistics about pending reports, hidden content, etc.
- Only accessible to users with isAdmin or isModerator flag

## User Interface

### ReportButton
Reusable button component that can be added to any content:
- Shows "Report" for unreported content
- Shows "Reported" for already-reported content
- Handles rate limiting checks
- Shows warnings at 8+ reports per day
- Can be displayed as icon button or text button

### ReportDialog
Modal dialog for submitting reports:
- Radio buttons for selecting report reason
- Optional text field for additional details
- Community guidelines acknowledgment checkbox
- Link to view full community guidelines
- Real-time validation
- Loading states during submission

### ModerationQueuePage
Admin interface for reviewing reported content:
- List of all reported content sorted by report count
- Color-coded status indicators
- View reports for each item
- Take action: Keep Active, Keep Hidden, or Remove
- View content details and audit logs
- Empty state when queue is clear

## Firestore Security Rules

### reportedContent Collection
- **Read**: Users can read their own reports; moderators can read all
- **Create**: Authenticated users can create reports (must match reporterId)
- **Update**: Only moderators can update reports
- **Delete**: Only admins can delete reports

### moderationQueue Collection
- **Read**: Only moderators can read
- **Create**: Authenticated users can create (for initial report)
- **Update**: Only moderators can update
- **Delete**: Only admins can delete

### auditLogs Subcollection
- **Read**: Only moderators can read (admin access to anonymous post authors)
- **Create**: System can create (via Cloud Functions)
- **Update/Delete**: Not allowed (immutable logs)

## Workflow

### Reporting Flow
1. User clicks "Report" button on content
2. System checks if user has already reported this content
3. System checks user's daily report count (< 10)
4. If 8+ reports, shows warning dialog
5. User selects reason and optionally adds details
6. User acknowledges community guidelines
7. Report submitted to Firestore
8. Cloud Function processes report:
   - Increments report count
   - Auto-hides if count >= 3
   - Creates audit logs

### Admin Moderation Flow
1. Admin opens Moderation Queue
2. Views list of reported content (sorted by report count)
3. Reviews content and associated reports
4. Takes action:
   - **Keep Active**: Content is fine, dismiss reports
   - **Keep Hidden**: Content stays hidden pending review
   - **Remove**: Permanently remove content
5. Report status updated in database
6. Audit log created for admin action

### Anonymous Post Audit Trail
1. User creates anonymous post
2. Cloud Function creates audit log in restricted subcollection
3. Original authorId stored in audit log
4. Only admins/moderators can access audit logs
5. Regular users cannot see original author of anonymous posts

## Client-Side Safeguards

### Rate Limiting
- Maximum 10 reports per user per 24 hours
- Count checked before displaying report dialog
- Hard limit enforced in Cloud Function

### Warning System
- At 8 reports: Warning dialog before proceeding
- At 10 reports: Report button disabled with error message

### Community Guidelines
- Must acknowledge guidelines before submitting report
- Link to view full guidelines in report dialog
- Guidelines displayed in plain language

## Localization

All user-facing strings are localized in English and Spanish:
- Report reasons
- Dialog titles and messages
- Error messages
- Community guidelines
- Admin interface strings

## Security Considerations

1. **Audit Logs**: Immutable logs prevent tampering with anonymous post author records
2. **Role-Based Access**: Only admins/moderators can access moderation queue and audit logs
3. **Rate Limiting**: Prevents abuse of reporting system
4. **Client + Server Validation**: Both client and Cloud Functions validate reports
5. **Anonymous Protection**: Original author only accessible via audit logs to privileged users

## Future Enhancements

Potential improvements to consider:
1. Machine learning integration for automatic content flagging
2. Appeal system for content removal
3. Moderator action history and analytics
4. User reputation system
5. Automated response to common report types
6. Bulk moderation actions
7. Report reason statistics and trending issues

## Setup Instructions

### 1. Deploy Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### 2. Deploy Firestore Indexes
```bash
firebase deploy --only firestore:indexes
```

### 3. Install Cloud Functions Dependencies
```bash
cd functions
npm install
```

### 4. Deploy Cloud Functions
```bash
firebase deploy --only functions
```

### 5. Set Admin/Moderator Roles
Add `isAdmin` or `isModerator` flag to user documents:
```javascript
await admin.firestore().collection('users').doc(userId).update({
  isAdmin: true,
  // or
  isModerator: true
});
```

## Testing

### Test Report Submission
1. Create test content (post/comment)
2. Submit report from different user account
3. Verify report appears in reportedContent collection
4. Verify moderationQueue item created/updated
5. Submit 2 more reports from different accounts
6. Verify content is auto-hidden after 3rd report

### Test Rate Limiting
1. Submit 10 reports in quick succession
2. Verify 11th report is blocked
3. Wait 24 hours or manually adjust timestamps
4. Verify rate limit resets

### Test Admin Functions
1. Log in as admin/moderator
2. Access moderation queue page
3. Review reported content
4. Take moderation action
5. Verify status updates in Firestore

### Test Audit Logs
1. Create anonymous post
2. Verify audit log created in subcollection
3. Attempt to access as regular user (should fail)
4. Access as admin (should succeed)

## Monitoring

Monitor these metrics in Firebase Console:
- Number of pending reports
- Average time to resolution
- Most common report reasons
- Users hitting rate limits
- Cloud Function execution counts and errors

## Support

For issues or questions about the moderation system:
1. Check Firebase logs for Cloud Function errors
2. Verify Firestore rules are deployed correctly
3. Check user roles (isAdmin/isModerator flags)
4. Review audit logs for specific content issues
