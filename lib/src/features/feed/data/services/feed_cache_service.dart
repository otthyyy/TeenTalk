import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../comments/data/models/comment.dart';

class FeedCacheEntry {
  final List<Post> posts;
  final DateTime fetchedAt;
  final bool hasMore;
  final int readCount;
  final DocumentSnapshot? lastDocument;
  final String? paginationToken;

  const FeedCacheEntry({
    required this.posts,
    required this.fetchedAt,
    required this.hasMore,
    required this.readCount,
    required this.lastDocument,
    required this.paginationToken,
  });

  bool isStale(Duration maxAge) {
    return DateTime.now().difference(fetchedAt) > maxAge;
  }
}

class FeedCacheService {
  final Map<String, FeedCacheEntry> _cache = {};
  final Duration _defaultMaxAge = const Duration(minutes: 2);
  int _totalReads = 0;
  int _cacheHits = 0;

  String _buildCacheKey({
    String? section,
    String? school,
    String? sortField,
  }) {
    return '${section ?? "all"}_${school ?? "all"}_${sortField ?? "createdAt"}';
  }

  FeedCacheEntry? get({
    String? section,
    String? school,
    String? sortField,
    Duration? maxAge,
  }) {
    _totalReads++;
    final key = _buildCacheKey(
      section: section,
      school: school,
      sortField: sortField,
    );
    final entry = _cache[key];
    if (entry == null) return null;

    final age = maxAge ?? _defaultMaxAge;
    if (entry.isStale(age)) {
      _cache.remove(key);
      return null;
    }

    _cacheHits++;
    return entry;
  }

  void set({
    required List<Post> posts,
    required bool hasMore,
    required int readCount,
    required DocumentSnapshot? lastDocument,
    String? section,
    String? school,
    String? sortField,
  }) {
    final key = _buildCacheKey(
      section: section,
      school: school,
      sortField: sortField,
    );
    final paginationToken = posts.isNotEmpty
        ? '${posts.last.createdAt.toIso8601String()}_${posts.last.id}'
        : null;
    _cache[key] = FeedCacheEntry(
      posts: posts,
      fetchedAt: DateTime.now(),
      hasMore: hasMore,
      readCount: readCount,
      lastDocument: lastDocument,
      paginationToken: paginationToken,
    );
  }

  void invalidate({
    String? section,
    String? school,
    String? sortField,
  }) {
    final key = _buildCacheKey(
      section: section,
      school: school,
      sortField: sortField,
    );
    _cache.remove(key);
  }

  void clearAll() {
    _cache.clear();
  }

  Map<String, dynamic> getMetrics() {
    return {
      'totalReads': _totalReads,
      'cacheHits': _cacheHits,
      'hitRate': _totalReads > 0 ? (_cacheHits / _totalReads * 100).toStringAsFixed(1) + '%' : '0%',
      'cachedEntries': _cache.length,
    };
  }

  void resetMetrics() {
    _totalReads = 0;
    _cacheHits = 0;
  }
}
