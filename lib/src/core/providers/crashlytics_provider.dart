import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/crashlytics_service.dart';

final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  throw UnimplementedError(
    'crashlyticsServiceProvider must be overridden in main.dart',
  );
});
