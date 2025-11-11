import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final Logger _logger = Logger();
  
  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Stream<bool> get connectivityStream {
    _connectivityController ??= StreamController<bool>.broadcast();
    return _connectivityController!.stream;
  }

  Future<void> initialize() async {
    try {
      _connectivityController ??= StreamController<bool>.broadcast();

      final initialResult = await _connectivity.checkConnectivity();
      _isConnected = _isNetworkConnected(_normalizeResults(initialResult));
      _connectivityController?.add(_isConnected);
      
      _subscription = _connectivity.onConnectivityChanged.listen((results) {
        final normalized = _normalizeResults(results);
        final wasConnected = _isConnected;
        _isConnected = _isNetworkConnected(normalized);
        
        if (wasConnected != _isConnected) {
          _logger.i('Connectivity changed: ${_isConnected ? 'online' : 'offline'}');
          _connectivityController?.add(_isConnected);
        }
      });
    } catch (e) {
      _logger.e('Failed to initialize connectivity service', error: e);
      _isConnected = true;
      _connectivityController?.add(_isConnected);
    }
  }

  List<ConnectivityResult> _normalizeResults(dynamic result) {
    if (result is List<ConnectivityResult>) {
      return result;
    }
    if (result is ConnectivityResult) {
      return [result];
    }
    return const [];
  }

  bool _isNetworkConnected(List<ConnectivityResult> results) {
    return results.isNotEmpty && 
           results.any((result) => 
             result == ConnectivityResult.mobile || 
             result == ConnectivityResult.wifi ||
             result == ConnectivityResult.ethernet
           );
  }

  void dispose() {
    _subscription?.cancel();
    _connectivityController?.close();
  }
}
