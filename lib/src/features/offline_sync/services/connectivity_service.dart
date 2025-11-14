import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return ConnectivityService();
});

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream;
});

enum ConnectivityStatus {
  online,
  offline,
}

class ConnectivityService {

  ConnectivityService() {
    _init();
  }
  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();
  StreamSubscription<ConnectivityResult>? _subscription;

  Stream<ConnectivityStatus> get connectivityStream => _statusController.stream;

  void _init() {
    _subscription = _connectivity.onConnectivityChanged.listen((result) {
      final status = _mapResultToStatus(result);

      _logger.d('Connectivity changed: $status (result: $result)');
      _statusController.add(status);
    });

    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      final status = _mapResultToStatus(result);

      _logger.d('Initial connectivity: $status');
      _statusController.add(status);
    } catch (e, stackTrace) {
      _logger.e('Error checking initial connectivity', error: e, stackTrace: stackTrace);
      _statusController.add(ConnectivityStatus.offline);
    }
  }

  Future<bool> isOnline() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
      return false;
    }
  }

  ConnectivityStatus _mapResultToStatus(ConnectivityResult result) {
    return result == ConnectivityResult.none
        ? ConnectivityStatus.offline
        : ConnectivityStatus.online;
  }

  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }
}
