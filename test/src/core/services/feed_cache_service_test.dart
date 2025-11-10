import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:teen_talk_app/src/core/services/feed_cache_service.dart';
import 'package:teen_talk_app/src/features/comments/data/models/comment.dart';
import 'package:teen_talk_app/src/features/feed/domain/models/feed_sort_option.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FeedCacheService cacheService;
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('feed_cache_service_test');
    Hive.init(tempDir.path);
    cacheService = FeedCacheService();
    await cacheService.initialize();
  });

  tearDown(() async {
    await cacheService.dispose();
    await Hive.close();
    if (tempDir.existsSync()) {
      await tempDir.delete(recursive: true);
    }
  });

  group('FeedCacheService', () {
    test('should initialize successfully', () {
      expect(cacheService, isNotNull);
    });

    test('should cache and retrieve posts', () async {
      final posts = [
        Post(
          id: '1',
          authorId: 'user1',
          authorNickname: 'User One',
          isAnonymous: false,
          content: 'Test post 1',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          section: 'spotted',
        ),
        Post(
          id: '2',
          authorId: 'user2',
          authorNickname: 'User Two',
          isAnonymous: false,
          content: 'Test post 2',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          section: 'spotted',
        ),
      ];

      await cacheService.cachePosts(
        posts,
        sortOption: FeedSortOption.newest,
        section: 'spotted',
      );

      final cacheEntry = await cacheService.getCachedPosts(
        sortOption: FeedSortOption.newest,
        section: 'spotted',
      );

      expect(cacheEntry, isNotNull);
      expect(cacheEntry!.posts.length, 2);
      expect(cacheEntry.posts[0].id, '1');
      expect(cacheEntry.posts[1].id, '2');
      expect(cacheEntry.lastSyncedAt, isNotNull);
    });

    test('should return null for non-existent cache', () async {
      final cacheEntry = await cacheService.getCachedPosts(
        sortOption: FeedSortOption.newest,
        section: 'nonexistent',
      );

      expect(cacheEntry, isNull);
    });

    test('should clear cache for specific section', () async {
      final posts = [
        Post(
          id: '1',
          authorId: 'user1',
          authorNickname: 'User One',
          isAnonymous: false,
          content: 'Test post',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          section: 'spotted',
        ),
      ];

      await cacheService.cachePosts(
        posts,
        sortOption: FeedSortOption.newest,
        section: 'spotted',
      );

      await cacheService.clearCache(
        sortOption: FeedSortOption.newest,
        section: 'spotted',
      );

      final cacheEntry = await cacheService.getCachedPosts(
        sortOption: FeedSortOption.newest,
        section: 'spotted',
      );

      expect(cacheEntry, isNull);
    });

    test('should serialize and deserialize posts correctly', () async {
      final now = DateTime.now();
      final posts = [
        Post(
          id: '1',
          authorId: 'user1',
          authorNickname: 'User One',
          isAnonymous: true,
          content: 'Test post with special chars: "quotes" and \n newlines',
          createdAt: now,
          updatedAt: now,
          likeCount: 5,
          likedBy: ['user2', 'user3'],
          commentCount: 3,
          section: 'spotted',
          school: 'Test School',
          imageUrl: 'https://example.com/image.jpg',
          engagementScore: 10.5,
        ),
      ];

      await cacheService.cachePosts(
        posts,
        sortOption: FeedSortOption.trending,
        section: 'general',
        school: 'Test School',
      );

      final cacheEntry = await cacheService.getCachedPosts(
        sortOption: FeedSortOption.trending,
        section: 'general',
        school: 'Test School',
      );

      expect(cacheEntry, isNotNull);
      final cachedPost = cacheEntry!.posts.first;
      expect(cachedPost.id, posts.first.id);
      expect(cachedPost.authorId, posts.first.authorId);
      expect(cachedPost.authorNickname, posts.first.authorNickname);
      expect(cachedPost.isAnonymous, posts.first.isAnonymous);
      expect(cachedPost.content, posts.first.content);
      expect(cachedPost.likeCount, posts.first.likeCount);
      expect(cachedPost.likedBy, posts.first.likedBy);
      expect(cachedPost.commentCount, posts.first.commentCount);
      expect(cachedPost.section, posts.first.section);
      expect(cachedPost.school, posts.first.school);
      expect(cachedPost.imageUrl, posts.first.imageUrl);
      expect(cachedPost.engagementScore, posts.first.engagementScore);
    });

    test('should handle different section/school combinations', () async {
      final posts1 = [
        Post(
          id: '1',
          authorId: 'user1',
          authorNickname: 'User One',
          isAnonymous: false,
          content: 'Spotted post',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          section: 'spotted',
        ),
      ];

      final posts2 = [
        Post(
          id: '2',
          authorId: 'user2',
          authorNickname: 'User Two',
          isAnonymous: false,
          content: 'General post',
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          section: 'general',
        ),
      ];

      await cacheService.cachePosts(
        posts1,
        sortOption: FeedSortOption.newest,
        section: 'spotted',
      );

      await cacheService.cachePosts(
        posts2,
        sortOption: FeedSortOption.newest,
        section: 'general',
      );

      final cached1 = await cacheService.getCachedPosts(
        sortOption: FeedSortOption.newest,
        section: 'spotted',
      );

      final cached2 = await cacheService.getCachedPosts(
        sortOption: FeedSortOption.newest,
        section: 'general',
      );

      expect(cached1?.posts.length, 1);
      expect(cached1?.posts.first.id, '1');
      expect(cached2?.posts.length, 1);
      expect(cached2?.posts.first.id, '2');
    });
  });
}
