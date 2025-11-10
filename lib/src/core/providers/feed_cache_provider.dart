import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/feed_cache_service.dart';

final feedCacheServiceProvider = Provider<FeedCacheService>((ref) {
  final service = FeedCacheService();
  ref.onDispose(() => service.dispose());
  return service;
});
