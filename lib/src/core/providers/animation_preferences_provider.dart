import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/animation_preferences_service.dart';

final animationPreferencesServiceProvider = Provider<AnimationPreferencesService>((ref) {
  return AnimationPreferencesService();
});

final hasSeenIntroProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(animationPreferencesServiceProvider);
  return service.hasSeenIntro();
});

final isMotionEnabledProvider = FutureProvider<bool>((ref) async {
  final service = ref.watch(animationPreferencesServiceProvider);
  return service.isMotionEnabled();
});
