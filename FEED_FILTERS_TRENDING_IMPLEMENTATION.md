# Feed Filters & Trending Implementation

## Overview

This document describes the implementation of feed sorting filters with persistence, including Newest, Most Liked, and Trending options.

## Features

### Sort Options

1. **Newest**: Orders posts by creation time (most recent first)
2. **Most Liked**: Orders posts by like count (with creation time as tie-breaker)
3. **Trending**: Orders posts by engagement score (with creation time as tie-breaker)

### Persistence

User-selected filter preferences are persisted per section (spotted/general) using `SharedPreferences`. When a user returns to a section, their previously selected sort option is automatically restored.

## Implementation Details

### Data Models

#### FeedSortOption Enum
Located at: `lib/src/features/feed/domain/models/feed_sort_option.dart`

Defines three sort options with their storage keys, labels, and Firestore field mappings:
- `newest`: Orders by `createdAt` field
- `mostLiked`: Orders by `likeCount` field, then `createdAt`
- `trending`: Orders by `engagementScore` field, then `createdAt`

#### Post Model Enhancement
The `Post` model now includes an `engagementScore` field (defaults to 0.0) which is used for trending calculations.

### Repository Layer

#### PostsRepository.getPosts()
Updated to accept a `FeedSortOption` parameter that determines query ordering:

```dart
Future<(List<Post>, DocumentSnapshot?)> getPosts({
  DocumentSnapshot? lastDocument,
  int limit = 20,
  String? section,
  String? school,
  FeedSortOption sortOption = FeedSortOption.newest,
})
```

The method builds Firestore queries with appropriate `orderBy` clauses based on the selected sort option.

### State Management

#### FeedState
Enhanced with a `sortOption` field that tracks the current sorting preference.

#### FeedNotifier
- Tracks current section, school, and sort option
- `loadPosts()` method accepts optional `sortOption` parameter
- `updateSortOption()` method allows changing sort preference and triggers feed refresh
- Real-time updates respect the current sort option

#### SchoolAwareFeedNotifier
Extends `FeedNotifier` with additional functionality:
- Auto-loads persisted sort preferences on initialization
- Saves sort preferences when changed via `updateSortOption()`
- Manages school-aware filtering alongside sorting

### Preferences Service

#### FilterPreferencesService
Located at: `lib/src/features/feed/data/services/filter_preferences_service.dart`

Handles persistence of sort preferences:
- `saveSortOrder(section, sortOption)`: Saves preference for a section
- `getSortOrder(section)`: Retrieves saved preference (defaults to `newest`)
- Uses key format: `feed_sort_order_{section}`

### UI Components

#### FeedFilterChips
Located at: `lib/src/features/feed/presentation/widgets/feed_filter_chips.dart`

Displays filter options as Material `FilterChip` widgets:
- Shows all three sort options
- Highlights selected option
- Triggers callback on selection change

#### FeedSectionsPage Updates
- Displays filter chips below section segmented control
- Shows "Sort by" label
- Updates hero header badge to reflect active filter
- Persists user selection per section

### Hero Header Dynamic Badge

The hero header now displays a dynamic badge that reflects the active sort option:
- **Newest**: Clock icon with "Latest" label
- **Most Liked**: Heart icon with "Most Liked" label  
- **Trending**: Trending up icon with "Trending Now" label

## Trending Calculation

### Engagement Score

The `engagementScore` field should be maintained by backend Cloud Functions or triggers to ensure consistency and performance. The score can be calculated using a weighted formula:

```
engagementScore = (likeCount × likeWeight) + (commentCount × commentWeight) + recencyBonus
```

Suggested weights:
- `likeWeight`: 1.0
- `commentWeight`: 2.0 (comments indicate higher engagement)
- `recencyBonus`: Decreases over time (e.g., `max(0, 100 - hoursSinceCreation)`)

### Backend Implementation Required

A Cloud Function should update `engagementScore` whenever:
- A post receives a like/unlike
- A comment is added
- Periodically (e.g., every hour) to adjust recency bonus

Example Cloud Function trigger:
```javascript
exports.updateEngagementScore = functions.firestore
  .document('posts/{postId}')
  .onUpdate(async (change, context) => {
    const post = change.after.data();
    const likeCount = post.likeCount || 0;
    const commentCount = post.commentCount || 0;
    const createdAt = post.createdAt.toDate();
    const hoursSinceCreation = (Date.now() - createdAt.getTime()) / (1000 * 60 * 60);
    
    const engagementScore = (likeCount * 1.0) + (commentCount * 2.0) + 
                           Math.max(0, 100 - hoursSinceCreation);
    
    return change.after.ref.update({ engagementScore });
  });
```

## Firestore Indexes

The following composite indexes are required for efficient queries:

### Spotted Section
```
Collection: posts
Fields:
  - isModerated (Ascending)
  - section (Ascending)
  - school (Ascending)
  - createdAt (Descending)
```

```
Collection: posts
Fields:
  - isModerated (Ascending)
  - section (Ascending)
  - school (Ascending)
  - likeCount (Descending)
  - createdAt (Descending)
```

```
Collection: posts
Fields:
  - isModerated (Ascending)
  - section (Ascending)
  - school (Ascending)
  - engagementScore (Descending)
  - createdAt (Descending)
```

### General Section
Same indexes as above but for the general section.

### Index Creation

Indexes will be automatically suggested by Firebase when queries run. Alternatively, create them manually in the Firebase Console or using `firebase deploy --only firestore:indexes`.

## Testing

### Unit Tests

Located at:
- `test/src/features/feed/feed_provider_test.dart`
- `test/src/features/feed/feed_sort_filter_test.dart`

Tests cover:
- Default sort option (newest)
- Sort option updates
- Sort option persistence across loads
- Repository query parameter passing
- Field name mappings
- Storage value parsing

### Integration Testing

To test the full flow:
1. Open the app and navigate to feed
2. Verify "Newest" is selected by default
3. Select "Most Liked" - feed should refresh and show most-liked posts first
4. Close and reopen the app
5. Verify "Most Liked" is still selected
6. Switch sections and back - each section maintains its own preference

## Performance Considerations

1. **Query Performance**: All queries use indexed fields for efficient ordering
2. **Pagination**: Cursored pagination with `startAfterDocument` maintains performance
3. **Real-time Updates**: Limited to 50 most recent posts to avoid excessive data transfer
4. **Preference Loading**: Async loading with fallback to default doesn't block UI

## Future Enhancements

1. **Custom Time Ranges**: Filter by "Today", "This Week", etc.
2. **Combined Filters**: Allow combining multiple filters
3. **User-specific Trending**: Personalized trending based on user interests
4. **A/B Testing**: Test different engagement score formulas
5. **Analytics**: Track which filters are most popular
