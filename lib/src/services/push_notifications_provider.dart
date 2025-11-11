import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'push_notifications_service.dart';

/// Provider for SharedPreferences
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider must be overridden in main.dart',
  );
});

/// Provider for PushNotificationsService
final pushNotificationsServiceProvider = Provider<PushNotificationsService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return PushNotificationsService(prefs: prefs);
});
