import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import '../../../features/comments/data/models/comment.dart';
import 'image_cache_service.dart';

class ImagePrefetchService {
  static final ImagePrefetchService _instance = ImagePrefetchService._internal();
  factory ImagePrefetchService() => _instance;
  ImagePrefetchService._internal();

  final Logger _logger = Logger();
  final ImageCacheService _cacheService = ImageCacheService();
  final Set<String> _prefetchedUrls = {};

  // Prefetch images from a list of posts based on scroll position
  void prefetchPostImages({
    required List<Post> posts,
    required int currentIndex,
    int lookAhead = 3,
  }) {
    if (posts.isEmpty) return;

    // Prefetch images for next few posts
    final endIndex = (currentIndex + lookAhead).clamp(0, posts.length);
    
    for (var i = currentIndex; i < endIndex; i++) {
      final post = posts[i];
      if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
        _prefetchImage(post.imageUrl!);
      }
    }
  }

  // Prefetch a single image if not already prefetched
  void _prefetchImage(String url) {
    if (_prefetchedUrls.contains(url)) {
      return;
    }

    _prefetchedUrls.add(url);
    _cacheService.precacheImage(url).then((_) {
      _logger.d('Successfully pre-cached: $url');
    }).catchError((error) {
      _logger.w('Failed to pre-cache: $url', error: error);
      // Remove from set so we can retry later
      _prefetchedUrls.remove(url);
    });
  }

  // Clear prefetch tracking (useful when refreshing feed)
  void clearPrefetchTracking() {
    _prefetchedUrls.clear();
  }

  // Prefetch all images from a batch of posts
  Future<void> batchPrefetch(List<Post> posts) async {
    final imageUrls = posts
        .where((post) => post.imageUrl != null && post.imageUrl!.isNotEmpty)
        .map((post) => post.imageUrl!)
        .where((url) => !_prefetchedUrls.contains(url))
        .toList();

    if (imageUrls.isEmpty) return;

    _logger.d('Batch prefetching ${imageUrls.length} images');
    
    for (final url in imageUrls) {
      _prefetchImage(url);
    }
  }
}
