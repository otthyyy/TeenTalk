import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/connectivity_service.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  unawaited(service.initialize());
  ref.onDispose(service.dispose);
  return service;
});

final connectivityStatusProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});
