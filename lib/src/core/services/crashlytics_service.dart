import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class CrashlyticsService {

  CrashlyticsService({
    FirebaseCrashlytics? crashlytics,
    Logger? logger,
  })  : _crashlytics = kIsWeb ? null : (crashlytics ?? FirebaseCrashlytics.instance),
        _logger = logger ?? Logger();
  final FirebaseCrashlytics? _crashlytics;
  final Logger _logger;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (kIsWeb) {
      _logger.i('Crashlytics is not supported on web platform');
      _isInitialized = false;
      return;
    }

    try {
      if (kDebugMode) {
        await _crashlytics!.setCrashlyticsCollectionEnabled(false);
        _logger.i('Crashlytics disabled in debug mode');
      } else {
        await _crashlytics!.setCrashlyticsCollectionEnabled(true);
        _logger.i('Crashlytics enabled');
      }
      _isInitialized = true;
    } catch (e) {
      _logger.e('Failed to initialize Crashlytics: $e');
      rethrow;
    }
  }

  Future<void> setCollectionEnabled(bool enabled) async {
    if (kIsWeb || _crashlytics == null) return;
    try {
      await _crashlytics.setCrashlyticsCollectionEnabled(enabled);
      _logger.i('Crashlytics collection ${enabled ? "enabled" : "disabled"}');
    } catch (e) {
      _logger.e('Failed to set Crashlytics collection: $e');
    }
  }

  Future<void> setUserId(String userId) async {
    if (!_isInitialized || kIsWeb || _crashlytics == null) return;
    try {
      await _crashlytics.setUserIdentifier(userId);
    } catch (e) {
      _logger.e('Failed to set user ID in Crashlytics: $e');
    }
  }

  Future<void> clearUserId() async {
    if (!_isInitialized || kIsWeb || _crashlytics == null) return;
    try {
      await _crashlytics.setUserIdentifier('');
    } catch (e) {
      _logger.e('Failed to clear user ID in Crashlytics: $e');
    }
  }

  Future<void> setCustomKey(String key, dynamic value) async {
    if (!_isInitialized || kIsWeb || _crashlytics == null) return;
    try {
      await _crashlytics.setCustomKey(key, value);
    } catch (e) {
      _logger.e('Failed to set custom key in Crashlytics: $e');
    }
  }

  Future<void> log(String message) async {
    if (!_isInitialized || kIsWeb || _crashlytics == null) return;
    try {
      await _crashlytics.log(message);
    } catch (e) {
      _logger.e('Failed to log message in Crashlytics: $e');
    }
  }

  Future<void> recordError(
    dynamic exception,
    StackTrace? stackTrace, {
    dynamic reason,
    bool fatal = false,
  }) async {
    if (!_isInitialized || kIsWeb || _crashlytics == null) return;
    try {
      await _crashlytics.recordError(
        exception,
        stackTrace,
        reason: reason,
        fatal: fatal,
      );
    } catch (e) {
      _logger.e('Failed to record error in Crashlytics: $e');
    }
  }

  Future<void> recordFlutterError(FlutterErrorDetails details) async {
    if (!_isInitialized || kIsWeb || _crashlytics == null) return;
    try {
      await _crashlytics.recordFlutterError(details);
    } catch (e) {
      _logger.e('Failed to record Flutter error in Crashlytics: $e');
    }
  }

  Future<void> testCrash() async {
    if (kIsWeb || _crashlytics == null) {
      _logger.w('Test crash not available on web platform');
      return;
    }
    if (kDebugMode) {
      _logger.w('Test crash triggered (only works in release mode)');
      await _crashlytics.setCrashlyticsCollectionEnabled(true);
      throw Exception('Test crash from Crashlytics');
    } else {
      throw Exception('Test crash from Crashlytics');
    }
  }
}
