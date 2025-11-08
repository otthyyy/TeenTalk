import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'app_config.dart';

class FirebaseBootstrap {
  static final Logger _logger = Logger();
  static FirebaseAnalytics? _analytics;
  static FirebaseMessaging? _messaging;

  static Future<void> initialize() async {
    try {
      _logger.i('Initializing Firebase for environment: ${AppConfig.environment}');
      
      // Validate configuration
      if (!AppConfig.isFirebaseConfigValid) {
        _logger.e('Firebase configuration is invalid. Check your .env file.');
        throw Exception('Invalid Firebase configuration');
      }

      // Initialize Firebase Core
      await Firebase.initializeApp(
        options: FirebaseOptions(
          apiKey: AppConfig.firebaseApiKey,
          authDomain: AppConfig.firebaseAuthDomain,
          projectId: AppConfig.firebaseProjectId,
          storageBucket: AppConfig.firebaseStorageBucket,
          messagingSenderId: AppConfig.firebaseMessagingSenderId,
          appId: AppConfig.firebaseAppId,
        ),
      );

      _logger.i('Firebase Core initialized successfully');

      // Initialize Analytics
      _analytics = FirebaseAnalytics.instance;
      await _analytics?.setAnalyticsCollectionEnabled(!kDebugMode);
      _logger.i('Firebase Analytics initialized');

      // Initialize Cloud Functions with appropriate region
      FirebaseFunctions functions = FirebaseFunctions.instance;
      if (AppConfig.isDevelopment) {
        functions.useFunctionsEmulator('localhost', 5001);
      }
      _logger.i('Firebase Functions initialized');

      // Initialize Messaging
      _messaging = FirebaseMessaging.instance;
      await _messaging?.requestPermission();
      _logger.i('Firebase Messaging initialized');

      // Test Firestore connectivity
      await FirebaseFirestore.instance.collection('test').limit(1).get();
      _logger.i('Firestore connectivity verified');

      // Test Storage connectivity
      await FirebaseStorage.instance.ref().child('test').getDownloadURL().catchError((e) {
        if (e is FirebaseException && e.code == 'object-not-found') {
          // Expected for test
          return;
        }
        throw e;
      });
      _logger.i('Firebase Storage connectivity verified');

      _logger.i('All Firebase services initialized successfully');

    } catch (e) {
      _logger.e('Failed to initialize Firebase: $e');
      rethrow;
    }
  }

  static FirebaseAnalytics? get analytics => _analytics;
  static FirebaseMessaging? get messaging => _messaging;

  static Future<String?> getFCMToken() async {
    try {
      return await _messaging?.getToken();
    } catch (e) {
      _logger.e('Failed to get FCM token: $e');
      return null;
    }
  }
}