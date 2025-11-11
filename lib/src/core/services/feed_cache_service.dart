import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:logger/logger.dart';

import '../../features/comments/data/models/comment.dart';
import '../../features/feed/domain/models/feed_sort_option.dart';

class FeedCacheEntry {
  final List<Post> posts;
  final DateTime? lastSyncedAt;
  final FeedSortOption sortOption;

  const FeedCacheEntry({
    required this.posts,
    required this.sortOption,
    this.lastSyncedAt,
  });
}

class FeedCacheService {
  static const String _postsBoxName = 'posts_cache';
  static const String _metadataBoxName = 'cache_metadata';

  final Logger _logger = Logger();

  Box<String>? _postsBox;
  Box<String>? _metadataBox;

  Future<void> initialize() async {
    try {
      _postsBox = await Hive.openBox<String>(_postsBoxName);
      _metadataBox = await Hive.openBox<String>(_metadataBoxName);
      _logger.i('Feed cache service initialized');
    } catch (e, stackTrace) {
      _logger.e('Failed to initialize feed cache service', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  String _cacheKey({
    required FeedSortOption sortOption,
    required String section,
    String? school,
  }) {
    final schoolKey = school ?? 'global';
    return '${section}_${schoolKey}_${sortOption.name}';
  }

  String _metadataKey({
    required FeedSortOption sortOption,
    required String section,
    String? school,
  }) {
    return 'lastSync_${_cacheKey(sortOption: sortOption, section: section, school: school)}';
  }

  Future<void> cachePosts(
    List<Post> posts, {
    required FeedSortOption sortOption,
    required String section,
    String? school,
  }) async {
    try {
      if (_postsBox == null) {
        _logger.w('Posts box not initialized');
        return;
      }

      final key = _cacheKey(sortOption: sortOption, section: section, school: school);
      final metadataKey = _metadataKey(sortOption: sortOption, section: section, school: school);

      final postsJson = posts.map((post) => post.toJson()).toList();
      final serialized = jsonEncode(postsJson);

      await _postsBox!.put(key, serialized);
      await _metadataBox?.put(metadataKey, DateTime.now().toIso8601String());
      _logger.i('Cached ${posts.length} posts for key: $key');
    } catch (e, stackTrace) {
      _logger.e('Failed to cache posts', error: e, stackTrace: stackTrace);
    }
  }

  Future<FeedCacheEntry?> getCachedPosts({
    required FeedSortOption sortOption,
    required String section,
    String? school,
  }) async {
    try {
      if (_postsBox == null) {
        _logger.w('Posts box not initialized');
        return null;
      }

      final key = _cacheKey(sortOption: sortOption, section: section, school: school);
      final metadataKey = _metadataKey(sortOption: sortOption, section: section, school: school);

      final serialized = _postsBox!.get(key);
      if (serialized == null) {
        return null;
      }

      final decoded = jsonDecode(serialized);
      if (decoded is! List) {
        return null;
      }

      final posts = decoded
          .whereType<Map<String, dynamic>>()
          .map(Post.fromJson)
          .toList(growable: false);

      final lastSyncedRaw = _metadataBox?.get(metadataKey);
      final lastSyncedAt = lastSyncedRaw != null ? DateTime.tryParse(lastSyncedRaw) : null;

      return FeedCacheEntry(
        posts: posts,
        sortOption: sortOption,
        lastSyncedAt: lastSyncedAt,
      );
    } catch (e, stackTrace) {
      _logger.e('Failed to retrieve cached posts', error: e, stackTrace: stackTrace);
      return null;
    }
  }

  Future<void> clearCache({
    required FeedSortOption sortOption,
    required String section,
    String? school,
  }) async {
    if (_postsBox == null) return;

    final key = _cacheKey(sortOption: sortOption, section: section, school: school);
    final metadataKey = _metadataKey(sortOption: sortOption, section: section, school: school);

    await _postsBox!.delete(key);
    await _metadataBox?.delete(metadataKey);
  }

  Future<void> clearAllCache() async {
    await _postsBox?.clear();
    await _metadataBox?.clear();
  }

  Future<void> dispose() async {
    await _postsBox?.close();
    await _metadataBox?.close();
  }
}
