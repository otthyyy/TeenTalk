# Admin Panel MVP Implementation

## Overview
The Admin Panel MVP provides comprehensive moderation capabilities for platform administrators, including reporting management, content moderation, decision logging, and analytics dashboards.

## Features Implemented

### 1. Admin-Only Access Control
- **Admin Claims**: Users with `isAdmin: true` in their profile can access the admin panel
- **Route Protection**: Router redirect prevents non-admin users from accessing `/admin` routes
- **UI Visibility**: Admin navigation button only appears for admin users
- **Firestore Security**: All admin resources protected by `isAdmin()` security rules

### 2. Reports Management
- **Unified Reporting System**: 
  - Single `reports` collection for both posts and comments
  - Automatic capture of reported content metadata (itemType, itemId, content, author info)
  - Status tracking (pending, resolved, dismissed, restored)

- **Report Filtering**:
  - Filter by status (all, pending, resolved, dismissed)
  - Date range filtering (start and end date)
  - Real-time list updates with Riverpod

- **Report Details**:
  - View full report information
  - Display original reported content
  - Show author information
  - View report creation timestamp

### 3. Moderation Actions
Each reported item can be actioned in three ways:

1. **Resolve (Delete Content)**
   - Permanently removes the reported post/comment
   - Creates moderation decision record
   - Logs moderator ID and notes

2. **Restore Content**
   - Marks content as `isModerated: false`
   - Restores visibility in feeds
   - Creates decision log entry

3. **Dismiss Report**
   - No content changes
   - Closes the report
   - Documents dismissal reason in notes

### 4. Moderation Decision Logging
- **Complete Audit Trail**:
  - `moderationDecisions` collection stores all decisions
  - Records moderator ID for accountability
  - Includes decision type and optional notes
  - Timestamps all actions for audit purposes

- **Decision Data**:
  ```dart
  {
    reportId: string,
    moderatorId: string,
    decision: 'resolved' | 'dismissed' | 'restored',
    notes: string?,
    createdAt: timestamp
  }
  ```

### 5. Analytics Dashboard
Real-time moderation analytics with:

- **Active Metrics**:
  - Active Reports (pending)
  - Resolved Reports
  - Dismissed Reports

- **Content Metrics**:
  - Flagged Posts
  - Flagged Comments
  - Total Flagged Content

- **User Metrics**:
  - Banned Users (placeholder for future expansion)

- **Summary Statistics**:
  - Total Reports
  - Resolution Rate (percentage)
  - Total Flagged Content

## Architecture

### Data Layer

#### Models
- **Report**: Contains report metadata and content snapshot
- **ModerationDecision**: Records admin actions on reports
- **AdminAnalytics**: Aggregated statistics for dashboard

#### Repository
- **AdminRepository**: Handles all admin operations
  - `getReports()`: Query reports with filters
  - `getReportById()`: Fetch specific report
  - `updateReportStatus()`: Update status and log decision
  - `deleteContent()`: Delete flagged content
  - `restoreContent()`: Restore content visibility
  - `getAnalytics()`: Fetch analytics data
  - `getReportedContent()`: View original content
  - `getModerationDecisions()`: View decision history

### Presentation Layer

#### Pages
- **AdminPage**: Main admin panel with tabbed interface
  - Reports tab (ReportsListWidget)
  - Analytics tab (AnalyticsWidget)

#### Widgets
- **ReportsListWidget**: 
  - Filter controls (status dropdown, date pickers)
  - Paginated report list
  - Real-time updates via Riverpod

- **ReportDetailWidget**:
  - Full report information display
  - Original content preview
  - Action selection interface
  - Notes input field
  - Processing UI with loading states

- **AnalyticsWidget**:
  - Grid of metric cards with icons
  - Summary statistics section
  - Real-time data updates

#### State Management (Riverpod)
- `adminRepositoryProvider`: Repository singleton
- `adminReportsFilterProvider`: Filter state management
- `adminReportsProvider`: Reports list with filters
- `adminAnalyticsProvider`: Analytics data
- `adminReportDetailsProvider`: Individual report details
- `reportedContentProvider`: Original content for review
- `moderationDecisionsProvider`: Decision history

## Firestore Structure

### Collections

#### reports
```json
{
  "id": "reportId",
  "itemId": "postId or commentId",
  "itemType": "post" | "comment",
  "authorId": "userId",
  "authorNickname": "nickname",
  "content": "full content text",
  "reason": "Spam | Inappropriate | Other",
  "status": "pending" | "resolved" | "dismissed" | "restored",
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

#### moderationDecisions
```json
{
  "id": "decisionId",
  "reportId": "reportId",
  "moderatorId": "adminUserId",
  "decision": "resolved" | "dismissed" | "restored",
  "notes": "optional moderator notes",
  "createdAt": "timestamp"
}
```

#### posts (updated)
- Added admin update/delete permissions via `isAdmin()` check

#### comments (updated)
- Added admin update/delete permissions via `isAdmin()` check

### Security Rules

#### Admin Access Check
```firestore
function isAdmin() {
  return get(/databases/$(database)/documents/users/$(request.auth.uid)).data.isAdmin == true;
}
```

#### Reports Collection
- Read: Admin only
- Create: Admin only (triggered by user reports through comments/posts repos)
- Update: Admin only
- Delete: Admin only

#### Moderation Decisions Collection
- Read: Admin only
- Create: Admin only
- List: Admin only

## Integration Points

### Comments System
- `CommentsRepository.reportComment()` creates report records
- Updated to use new unified reports collection
- Automatically captures comment data in report

### Posts System
- `PostsRepository.reportPost()` creates report records
- Updated to use new unified reports collection
- Automatically captures post data in report

### Router
- Admin route protected in `GoRouter` redirect logic
- Admin button conditionally shown based on `userProfile.isAdmin`
- Unauthorized access redirects to feed

### Auth System
- `UserProfile` model extended with `isAdmin` boolean
- Admin status persisted in Firestore `users/{userId}`
- Loaded during profile initialization

## Usage

### For Admins

1. **Access Admin Panel**
   - Navigate to admin tab in bottom navigation
   - Only visible if user has admin claims

2. **Review Reports**
   - View all reports or filter by status
   - Use date range filters for time-based queries
   - Click report to view full details

3. **Take Action**
   - Select action (resolve, restore, dismiss)
   - Optionally add notes for audit trail
   - Submit to log decision and update content

4. **Monitor Analytics**
   - Navigate to Analytics tab
   - View real-time moderation metrics
   - Track resolution rates and flagged content

### For Users (Reporting)

1. **Report Content**
   - Click report button on post or comment
   - Select reason for report
   - Submit report

2. **Content Gets Flagged**
   - Report automatically creates record in `reports` collection
   - Content marked as `isModerated: true`
   - Content hidden from feeds

3. **Admin Reviews and Acts**
   - Admin reviews report details
   - Takes moderation action (delete/restore/dismiss)
   - Decision logged for audit purposes

## Testing Checklist

- [ ] Admin user can access admin panel
- [ ] Non-admin user redirected from admin panel
- [ ] Admin button appears for admin users only
- [ ] Reports list displays all pending reports
- [ ] Status filter works correctly
- [ ] Date range filters function properly
- [ ] Report detail view shows correct content
- [ ] Resolve action deletes content
- [ ] Restore action returns content to visibility
- [ ] Dismiss action closes report without changes
- [ ] Notes are saved in decision records
- [ ] Analytics numbers update correctly
- [ ] Moderator ID logged for all decisions
- [ ] Timestamps recorded accurately
- [ ] Firestore security rules prevent non-admin access

## Future Enhancements

1. **User Management**
   - Ban/unban users
   - View user history
   - Bulk moderation actions

2. **Advanced Filtering**
   - Filter by content type
   - Search by reason or keywords
   - Filter by reporter or reported author

3. **Notifications**
   - Notify moderators of new reports
   - Alert authors of decisions
   - Bulk notification management

4. **Reporting Insights**
   - Charts and graphs
   - Trend analysis
   - Pattern detection

5. **Batch Operations**
   - Bulk status updates
   - Bulk content deletion
   - Batch user bans

6. **Integration**
   - Cloud Function webhooks
   - Slack integration
   - Email notifications

## Database Migration Notes

### Existing Report Collections
If migrating from old `postReports`/`commentReports` collections:

1. Create new `reports` collection with unified schema
2. Migrate old data with appropriate `itemType` values
3. Update report references in `moderationDecisions`
4. Gradually phase out old collections
5. Update all code to use new unified structure

## Related Documentation
- See [COMMENTS_FEATURE.md](COMMENTS_FEATURE.md) for reporting integration
- See [FIREBASE_SETUP.md](FIREBASE_SETUP.md) for security rules deployment
- See [AUTH_IMPLEMENTATION.md](AUTH_IMPLEMENTATION.md) for admin claims setup
