import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../core/firebase_bootstrap.dart';
import 'analytics_service.dart';

/// Provider for AnalyticsService
final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  final analytics = FirebaseBootstrap.analytics ?? FirebaseAnalytics.instance;
  return AnalyticsService(
    analytics: analytics,
    logger: Logger(),
  );
});

/// Provider to watch analytics enabled state
final analyticsEnabledProvider = StateProvider<bool>((ref) => true);

/// Provider to manage analytics opt-in/out
class AnalyticsPreferencesNotifier extends StateNotifier<bool> {

  AnalyticsPreferencesNotifier(this._analyticsService) : super(true);
  final AnalyticsService _analyticsService;

  Future<void> setEnabled(bool enabled) async {
    await _analyticsService.setEnabled(enabled);
    state = enabled;
  }

  Future<void> optOut() async {
    await _analyticsService.logAnalyticsOptedOut();
    state = false;
  }

  Future<void> optIn() async {
    await _analyticsService.logAnalyticsOptedIn();
    state = true;
  }
}

final analyticsPreferencesProvider =
    StateNotifierProvider<AnalyticsPreferencesNotifier, bool>((ref) {
  final service = ref.watch(analyticsServiceProvider);
  return AnalyticsPreferencesNotifier(service);
});
