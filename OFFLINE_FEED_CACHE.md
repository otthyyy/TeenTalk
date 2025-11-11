# Offline Feed Cache Implementation

This document describes the implementation of offline feed caching for the TeenTalk app, enabling users to view previously synced posts when offline.

## Overview

The offline feed cache system provides a read-only offline experience by:
- Caching recent posts locally using Hive
- Enabling Firestore offline persistence for recently viewed data
- Detecting network connectivity changes
- Automatically falling back to cached data when offline
- Displaying an offline banner with last sync time
- Caching images using cached_network_image

## Architecture

### Components

1. **FeedCacheService** (`lib/src/core/services/feed_cache_service.dart`)
   - Manages local post caching using Hive
   - Stores posts keyed by section, school, and sort option
   - Tracks last sync time for each cache entry
   - Serializes/deserializes post data to JSON

2. **ConnectivityService** (`lib/src/core/services/connectivity_service.dart`)
   - Monitors network connectivity using connectivity_plus
   - Provides stream of connectivity status changes
   - Supports mobile, WiFi, and ethernet connections

3. **FeedState** (updated in `lib/src/features/feed/presentation/providers/feed_provider.dart`)
   - Added `isOffline` flag to track offline status
   - Added `lastSyncedAt` to track when posts were last fetched

4. **FeedNotifier** (updated in `lib/src/features/feed/presentation/providers/feed_provider.dart`)
   - Integrates with ConnectivityService and FeedCacheService
   - Falls back to cache when offline
   - Caches posts on successful network fetch
   - Automatically refreshes when connection restored

5. **OfflineBanner** (`lib/src/features/feed/presentation/widgets/offline_banner.dart`)
   - Displays when device is offline
   - Shows last sync time
   - Hides automatically when online

## Features

### Firestore Offline Persistence
- Enabled for non-web platforms in `main.dart`
- Automatically caches Firestore documents for offline access
- Configured with: `FirebaseFirestore.instance.settings = Settings(persistenceEnabled: true)`

### Local Cache Layer
- Uses Hive for lightweight, fast local storage
- Stores posts as JSON in two boxes:
  - `posts_cache`: Actual post data
  - `cache_metadata`: Last sync timestamps
- Cache keys include section, school, and sort option for granular caching

### Connectivity Detection
- Uses connectivity_plus package
- Monitors for network changes (WiFi, mobile, ethernet)
- Automatically updates feed state when connection status changes

### Image Caching
- Uses cached_network_image package
- Automatically caches images on first load
- Shows placeholder while loading
- Displays error icon if image fails to load

### Offline Banner
- Appears at top of feed when offline
- Shows: "You're offline - Showing cached posts • Last synced X ago"
- Formatting: just now, Xm ago, Xh ago, Xd ago, yesterday, over a week ago

## Data Flow

### Online Mode
1. User opens feed
2. FeedNotifier checks connectivity
3. Fetches posts from Firestore
4. Caches posts locally via FeedCacheService
5. Updates state with `isOffline: false` and current `lastSyncedAt`
6. Images load and cache automatically

### Offline Mode
1. User opens feed (or goes offline)
2. FeedNotifier checks connectivity
3. Fetches posts from FeedCacheService
4. Updates state with `isOffline: true` and cached `lastSyncedAt`
5. OfflineBanner appears showing last sync time
6. Cached images display automatically

### Connection Restored
1. ConnectivityService detects connection
2. Stream emits connectivity change
3. FeedNotifier automatically triggers refresh
4. Fresh data fetched from Firestore
5. Cache updated with new data
6. OfflineBanner disappears

## API

### FeedCacheService

```dart
// Initialize
await cacheService.initialize();

// Cache posts
await cacheService.cachePosts(
  posts,
  sortOption: FeedSortOption.newest,
  section: 'spotted',
  school: 'High School',
);

// Retrieve cached posts
final cacheEntry = await cacheService.getCachedPosts(
  sortOption: FeedSortOption.newest,
  section: 'spotted',
  school: 'High School',
);

// Clear cache
await cacheService.clearCache(
  sortOption: FeedSortOption.newest,
  section: 'spotted',
  school: 'High School',
);

// Clear all caches
await cacheService.clearAllCache();
```

### ConnectivityService

```dart
// Initialize
await connectivityService.initialize();

// Check current status
final isConnected = connectivityService.isConnected;

// Listen to connectivity changes
connectivityService.connectivityStream.listen((isConnected) {
  if (isConnected) {
    print('Connected to network');
  } else {
    print('Offline');
  }
});
```

## Testing

### Unit Tests

1. **feed_cache_service_test.dart**
   - Tests cache initialization
   - Tests post caching and retrieval
   - Tests serialization/deserialization
   - Tests cache clearing
   - Tests multiple section/school combinations

2. **feed_offline_test.dart**
   - Tests offline feed loading
   - Tests cache fallback when offline
   - Tests automatic refresh when connection restored
   - Uses mock repositories and fake connectivity service

### Running Tests

```bash
flutter test test/src/core/services/feed_cache_service_test.dart
flutter test test/src/features/feed/presentation/providers/feed_offline_test.dart
```

## Configuration

### Dependencies Added

```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0
  connectivity_plus: ^5.0.2
  cached_network_image: ^3.3.1
```

### Initialization in main.dart

```dart
// Initialize Hive
await Hive.initFlutter();

// Enable Firestore offline persistence (non-web only)
if (!kIsWeb) {
  FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
}

// Initialize feed cache service
final feedCacheService = await _initializeFeedCache();
```

## Limitations

1. **Read-only offline mode**: Users cannot create, edit, or interact with posts while offline
2. **Cache size**: No automatic cache size management (could be added in future)
3. **Cache expiration**: No automatic expiration of old cached data (could be added in future)
4. **Web support**: Firestore offline persistence not enabled on web platform
5. **Pagination**: Cannot load more posts when offline (only shows cached initial set)

## Future Enhancements

1. **Cache size management**: Implement LRU cache eviction or size limits
2. **Cache expiration**: Auto-delete posts older than X days
3. **Background sync**: Sync cache in background when app reopens
4. **Offline interactions**: Queue likes/comments for later submission
5. **Conflict resolution**: Handle conflicts when syncing queued actions
6. **Cache analytics**: Track cache hit rates and effectiveness
7. **Selective caching**: Allow users to control what gets cached

## Troubleshooting

### Cache not working
- Check that Hive is initialized properly
- Verify FeedCacheService is being provided via Riverpod
- Check console logs for cache errors

### Connectivity detection not working
- Verify connectivity_plus package is installed
- Check that ConnectivityService is initialized
- Test on physical device (emulator connectivity may differ)

### Images not caching
- Verify cached_network_image is properly installed
- Check image URLs are valid
- Ensure device has loaded images at least once while online

## Performance Considerations

- **Hive** is very fast for small to medium datasets
- **JSON serialization** is reasonably efficient for post objects
- **Cache lookups** are O(1) by key
- **Memory usage** is minimal as Hive uses lazy loading
- **Disk space** depends on number of cached posts (typically KB per post)

## Security Considerations

- Cache is stored in app's private directory (sandboxed)
- No sensitive data should be cached (posts are public)
- Cache is cleared when app is uninstalled
- No encryption needed for public feed data
