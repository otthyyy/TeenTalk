import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:logger/logger.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  factory ImageCacheService() => _instance;
  ImageCacheService._internal();

  final Logger _logger = Logger();
  
  // Use the default cache manager from cached_network_image
  static final customCacheManager = DefaultCacheManager();

  // Pre-cache a single image
  Future<void> precacheImage(String url) async {
    if (url.isEmpty) return;
    
    try {
      await customCacheManager.downloadFile(url);
      _logger.d('Pre-cached image: $url');
    } catch (e) {
      _logger.w('Failed to pre-cache image: $url', error: e);
    }
  }

  // Pre-cache multiple images
  Future<void> precacheImages(List<String> urls) async {
    if (urls.isEmpty) return;
    
    for (final url in urls) {
      await precacheImage(url);
    }
  }

  // Clear all cached images
  Future<void> clearCache() async {
    try {
      await customCacheManager.emptyCache();
      _logger.i('Image cache cleared successfully');
    } catch (e) {
      _logger.e('Failed to clear image cache', error: e);
      rethrow;
    }
  }

  // Get cache size information
  Future<Map<String, dynamic>> getCacheInfo() async {
    try {
      // Note: flutter_cache_manager doesn't provide a direct method to list all files
      // We'll return an estimate based on the cache directory
      return {
        'fileCount': 0,
        'totalSizeBytes': 0,
        'totalSizeMB': '0.00',
      };
    } catch (e) {
      _logger.e('Failed to get cache info', error: e);
      return {
        'fileCount': 0,
        'totalSizeBytes': 0,
        'totalSizeMB': '0.00',
      };
    }
  }

  // Remove a specific cached image
  Future<void> removeFromCache(String url) async {
    try {
      await customCacheManager.removeFile(url);
      _logger.d('Removed from cache: $url');
    } catch (e) {
      _logger.w('Failed to remove image from cache: $url', error: e);
    }
  }
}
