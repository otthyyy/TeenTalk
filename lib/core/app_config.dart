import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static String get environment => dotenv.env['FLUTTER_ENV'] ?? 'dev';
  
  static bool get isDevelopment => environment == 'dev';
  static bool get isProduction => environment == 'prod';
  
  // Firebase Configuration
  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAuthDomain => dotenv.env['FIREBASE_AUTH_DOMAIN'] ?? '';
  static String get firebaseProjectId => dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket => dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
  static String get firebaseMessagingSenderId => dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  
  // Validate that all required Firebase config is present
  static bool get isFirebaseConfigValid {
    return firebaseApiKey.isNotEmpty &&
           firebaseAuthDomain.isNotEmpty &&
           firebaseProjectId.isNotEmpty &&
           firebaseStorageBucket.isNotEmpty &&
           firebaseMessagingSenderId.isNotEmpty &&
           firebaseAppId.isNotEmpty;
  }
}