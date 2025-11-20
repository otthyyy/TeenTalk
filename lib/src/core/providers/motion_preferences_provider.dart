import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/motion_preferences_service.dart';

final motionPreferencesServiceProvider = ChangeNotifierProvider<MotionPreferencesService>((ref) {
  throw UnimplementedError('motionPreferencesServiceProvider must be overridden');
});

final motionPreferencesProvider = Provider<MotionPreferences>((ref) {
  final service = ref.watch(motionPreferencesServiceProvider);
  return service.preferences;
});
