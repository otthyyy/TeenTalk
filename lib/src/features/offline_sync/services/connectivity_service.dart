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
  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  Stream<ConnectivityStatus> get connectivityStream => _statusController.stream;

  ConnectivityService() {
    _init();
  }

  void _init() {
    _connectivity.onConnectivityChanged.listen((List<ConnectivityResult> results) {
      final hasConnection = results.isNotEmpty &&
          !results.every((result) => result == ConnectivityResult.none);
      
      final status = hasConnection
          ? ConnectivityStatus.online
          : ConnectivityStatus.offline;
      
      _logger.d('Connectivity changed: $status (results: $results)');
      _statusController.add(status);
    });

    _checkInitialConnectivity();
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasConnection = results.isNotEmpty &&
          !results.every((result) => result == ConnectivityResult.none);
      
      final status = hasConnection
          ? ConnectivityStatus.online
          : ConnectivityStatus.offline;
      
      _logger.d('Initial connectivity: $status');
      _statusController.add(status);
    } catch (e, stackTrace) {
      _logger.e('Error checking initial connectivity', error: e, stackTrace: stackTrace);
      _statusController.add(ConnectivityStatus.offline);
    }
  }

  Future<bool> isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.isNotEmpty &&
          !results.every((result) => result == ConnectivityResult.none);
    } catch (e) {
      _logger.e('Error checking connectivity: $e');
      return false;
    }
  }

  void dispose() {
    _statusController.close();
  }
}
