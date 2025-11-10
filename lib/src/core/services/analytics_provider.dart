import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'analytics_service.dart';

final analyticsServiceProvider = Provider<AnalyticsService>((ref) {
  return AnalyticsService();
});
