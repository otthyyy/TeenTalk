import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager/flutter_windowmanager.dart';
import 'package:logger/logger.dart';

class ScreenshotProtectionService {
  static const MethodChannel _channel = MethodChannel('com.teentalk.app/screenshot');
  final Logger _logger = Logger();
  
  final StreamController<bool> _screenshotDetectedController = StreamController<bool>.broadcast();
  Stream<bool> get screenshotDetected => _screenshotDetectedController.stream;
  
  final StreamController<bool> _screenCaptureStatusController = StreamController<bool>.broadcast();
  Stream<bool> get screenCaptureStatus => _screenCaptureStatusController.stream;
  
  bool _isProtectionEnabled = false;
  bool _isIosCaptureActive = false;

  Future<void> initialize() async {
    if (!kIsWeb && Platform.isIOS) {
      await _setupIosScreenCaptureDetection();
    }
  }

  Future<void> enableProtection() async {
    if (kIsWeb) {
      _logger.i('Screenshot protection is not supported on web platform');
      return;
    }
    
    try {
      if (Platform.isAndroid) {
        await FlutterWindowManager.addFlags(FlutterWindowManager.FLAG_SECURE);
        _isProtectionEnabled = true;
        _logger.i('Screenshot protection enabled on Android');
      } else if (Platform.isIOS) {
        _isProtectionEnabled = true;
        _logger.i('Screenshot detection enabled on iOS');
      }
    } catch (e) {
      _logger.e('Failed to enable screenshot protection: $e');
      rethrow;
    }
  }

  Future<void> disableProtection() async {
    if (kIsWeb) {
      _logger.i('Screenshot protection is not supported on web platform');
      return;
    }
    
    try {
      if (Platform.isAndroid) {
        await FlutterWindowManager.clearFlags(FlutterWindowManager.FLAG_SECURE);
        _isProtectionEnabled = false;
        _logger.i('Screenshot protection disabled on Android');
      } else if (Platform.isIOS) {
        _isProtectionEnabled = false;
        _logger.i('Screenshot detection disabled on iOS');
      }
    } catch (e) {
      _logger.e('Failed to disable screenshot protection: $e');
      rethrow;
    }
  }

  Future<void> _setupIosScreenCaptureDetection() async {
    try {
      _channel.setMethodCallHandler((call) async {
        if (call.method == 'onScreenCaptureChanged') {
          final isCaptured = call.arguments as bool;
          _isIosCaptureActive = isCaptured;
          _screenCaptureStatusController.add(isCaptured);
          _logger.i('iOS screen capture status changed: $isCaptured');
        } else if (call.method == 'onScreenshotDetected') {
          _screenshotDetectedController.add(true);
          _logger.i('Screenshot detected on iOS');
        }
      });
      
      await _channel.invokeMethod('startScreenCaptureDetection');
      _logger.i('iOS screen capture detection started');
    } catch (e) {
      _logger.e('Failed to setup iOS screen capture detection: $e');
    }
  }

  bool get isProtectionEnabled => _isProtectionEnabled;
  bool get isIosCaptureActive => _isIosCaptureActive;

  void dispose() {
    _screenshotDetectedController.close();
    _screenCaptureStatusController.close();
  }
}
