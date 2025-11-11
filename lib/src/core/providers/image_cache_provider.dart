import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/image_cache_service.dart';
import '../services/image_prefetch_service.dart';

final imageCacheServiceProvider = Provider<ImageCacheService>((ref) {
  return ImageCacheService();
});

final imagePrefetchServiceProvider = Provider<ImagePrefetchService>((ref) {
  return ImagePrefetchService();
});

final cacheInfoProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final service = ref.watch(imageCacheServiceProvider);
  return service.getCacheInfo();
});
