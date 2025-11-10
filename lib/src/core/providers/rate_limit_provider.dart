import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/rate_limit_service.dart';

final rateLimitServiceProvider = Provider<RateLimitService>((ref) {
  return RateLimitService();
});

final postRateLimitStatusProvider = StreamProvider.autoDispose<RateLimitStatus>((ref) async* {
  final service = ref.watch(rateLimitServiceProvider);
  
  while (true) {
    yield service.checkLimit(ContentType.post);
    await Future.delayed(const Duration(seconds: 1));
  }
});

final commentRateLimitStatusProvider = StreamProvider.autoDispose<RateLimitStatus>((ref) async* {
  final service = ref.watch(rateLimitServiceProvider);
  
  while (true) {
    yield service.checkLimit(ContentType.comment);
    await Future.delayed(const Duration(seconds: 1));
  }
});
