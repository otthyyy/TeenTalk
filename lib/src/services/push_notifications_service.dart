import 'dart:async';
import 'dart:io';

import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing push notifications via Firebase Cloud Messaging
/// Handles permission requests, token registration/unregistration, and notification display
class PushNotificationsService {

  PushNotificationsService({
    FirebaseMessaging? messaging,
    FirebaseFunctions? functions,
    FlutterLocalNotificationsPlugin? localNotifications,
    required SharedPreferences prefs,
  })  : _messaging = messaging ?? FirebaseMessaging.instance,
        _functions = functions ?? FirebaseFunctions.instance,
        _localNotifications =
            localNotifications ?? FlutterLocalNotificationsPlugin(),
        _prefs = prefs;
  final FirebaseMessaging _messaging;
  final FirebaseFunctions _functions;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final SharedPreferences _prefs;
  final Logger _logger = Logger();

  static const String _tokenKey = 'fcm_token';
  static const String _androidChannelId = 'teen_talk_notifications';
  static const String _androidChannelName = 'TeenTalk Notifications';
  static const String _androidChannelDescription =
      'Notifications for new messages, comments, and likes';

  /// Initialize the push notifications service
  /// Sets up local notifications, requests permissions, and configures message handlers
  Future<void> initialize() async {
    try {
      _logger.i('Initializing PushNotificationsService');

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Request notification permissions
      final hasPermission = await requestPermission();
      if (!hasPermission) {
        _logger.w('Notification permission denied');
        return;
      }

      // Get and register FCM token
      await _handleTokenRegistration();

      // Listen to token refresh
      _messaging.onTokenRefresh.listen(_onTokenRefresh);

      // Configure foreground message handler
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Configure message opened handler
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);

      // Check for notification that opened the app
      final initialMessage = await _messaging.getInitialMessage();
      if (initialMessage != null) {
        _handleMessageOpened(initialMessage);
      }

      _logger.i('PushNotificationsService initialized successfully');
    } catch (e, stackTrace) {
      _logger.e('Error initializing PushNotificationsService',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Initialize flutter_local_notifications with platform-specific settings
  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    if (!kIsWeb && Platform.isAndroid) {
      final androidPlugin =
          _localNotifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          _androidChannelId,
          _androidChannelName,
          description: _androidChannelDescription,
          importance: Importance.high,
          playSound: true,
          enableVibration: true,
        ),
      );
    }
  }

  /// Request notification permissions from the user
  /// Returns true if permission was granted, false otherwise
  Future<bool> requestPermission() async {
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      final granted = settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;

      _logger.i('Notification permission status: ${settings.authorizationStatus}');
      return granted;
    } catch (e) {
      _logger.e('Error requesting notification permission: $e');
      return false;
    }
  }

  /// Get the current FCM token and register it with the backend if changed
  Future<void> _handleTokenRegistration() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) {
        _logger.w('FCM token is null');
        return;
      }

      _logger.i('FCM Token obtained: ${token.substring(0, 20)}...');

      // Check if token has changed
      final lastToken = _prefs.getString(_tokenKey);
      if (lastToken == token) {
        _logger.i('Token unchanged, skipping registration');
        return;
      }

      // Unregister old token if exists
      if (lastToken != null) {
        await _unregisterToken(lastToken);
      }

      // Register new token
      await _registerToken(token);

      // Save token locally
      await _prefs.setString(_tokenKey, token);
    } catch (e, stackTrace) {
      _logger.e('Error handling token registration',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Register FCM token with the backend via Cloud Function
  Future<void> _registerToken(String token) async {
    try {
      _logger.i('Registering FCM token with backend');
      final callable = _functions.httpsCallable('registerFCMToken');
      final result = await callable.call({'token': token});

      _logger.i('Token registration response: ${result.data}');
    } catch (e) {
      _logger.e('Error registering FCM token: $e');
      rethrow;
    }
  }

  /// Unregister FCM token from the backend via Cloud Function
  Future<void> _unregisterToken(String token) async {
    try {
      _logger.i('Unregistering FCM token from backend');
      final callable = _functions.httpsCallable('unregisterFCMToken');
      final result = await callable.call({'token': token});

      _logger.i('Token unregistration response: ${result.data}');
    } catch (e) {
      _logger.e('Error unregistering FCM token: $e');
      // Don't rethrow - unregistration failure shouldn't block registration
    }
  }

  /// Handle token refresh events
  Future<void> _onTokenRefresh(String newToken) async {
    try {
      _logger.i('FCM token refreshed');

      // Get old token
      final oldToken = _prefs.getString(_tokenKey);

      // Unregister old token
      if (oldToken != null && oldToken != newToken) {
        await _unregisterToken(oldToken);
      }

      // Register new token
      await _registerToken(newToken);

      // Save new token locally
      await _prefs.setString(_tokenKey, newToken);
    } catch (e, stackTrace) {
      _logger.e('Error handling token refresh',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Handle foreground messages by displaying a local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    try {
      _logger.i('Received foreground message: ${message.messageId}');
      _logger.d('Message data: ${message.data}');

      final notification = message.notification;
      if (notification == null) {
        _logger.w('Notification payload is null');
        return;
      }

      // Display local notification
      await _displayNotification(
        title: notification.title ?? 'TeenTalk',
        body: notification.body ?? '',
        payload: message.data.toString(),
      );
    } catch (e, stackTrace) {
      _logger.e('Error handling foreground message',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Handle notification opened/tapped events
  void _handleMessageOpened(RemoteMessage message) {
    _logger.i('Message opened: ${message.messageId}');
    _logger.d('Message data: ${message.data}');

    // TODO: Navigate to appropriate screen based on notification type
    // This will be implemented when UI routing is added
    final type = message.data['type'];
    switch (type) {
      case 'comment':
        _logger.i('Navigate to post: ${message.data['postId']}');
        break;
      case 'like':
        _logger.i('Navigate to post: ${message.data['postId']}');
        break;
      case 'message':
        _logger.i('Navigate to conversation: ${message.data['conversationId']}');
        break;
      default:
        _logger.w('Unknown notification type: $type');
    }
  }

  /// Handle notification tapped via local notifications
  void _onNotificationTapped(NotificationResponse response) {
    _logger.i('Local notification tapped: ${response.payload}');
    // TODO: Parse payload and navigate to appropriate screen
  }

  /// Display a local notification with platform-specific styling
  Future<void> _displayNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        _androidChannelId,
        _androidChannelName,
        channelDescription: _androidChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        styleInformation: BigTextStyleInformation(''),
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (e, stackTrace) {
      _logger.e('Error displaying notification',
          error: e, stackTrace: stackTrace);
    }
  }

  /// Clear all stored tokens and unregister from backend
  /// Should be called on sign-out
  Future<void> clearTokens() async {
    try {
      _logger.i('Clearing FCM tokens');

      final token = _prefs.getString(_tokenKey);
      if (token != null) {
        await _unregisterToken(token);
        await _prefs.remove(_tokenKey);
      }

      // Delete FCM token from device
      await _messaging.deleteToken();

      _logger.i('FCM tokens cleared successfully');
    } catch (e, stackTrace) {
      _logger.e('Error clearing tokens', error: e, stackTrace: stackTrace);
    }
  }

  /// Refresh and re-register the current token
  /// Should be called on sign-in
  Future<void> refreshToken() async {
    try {
      _logger.i('Refreshing FCM token');

      // Delete existing token to force refresh
      await _messaging.deleteToken();
      await _prefs.remove(_tokenKey);

      // Get new token and register
      await _handleTokenRegistration();

      _logger.i('FCM token refreshed successfully');
    } catch (e, stackTrace) {
      _logger.e('Error refreshing token', error: e, stackTrace: stackTrace);
    }
  }

  /// Check current notification permission status
  Future<bool> checkPermission() async {
    try {
      final settings = await _messaging.getNotificationSettings();
      return settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional;
    } catch (e) {
      _logger.e('Error checking notification permission: $e');
      return false;
    }
  }

  /// Get the current FCM token (for debugging)
  Future<String?> getCurrentToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      _logger.e('Error getting current token: $e');
      return null;
    }
  }

  /// Called when user signs in
  Future<void> onUserSignedIn(String uid) async {
    try {
      _logger.i('User signed in: $uid - refreshing token');
      await refreshToken();
    } catch (e, stackTrace) {
      _logger.e('Error handling user sign in', error: e, stackTrace: stackTrace);
    }
  }

  /// Called when user signs out
  Future<void> onUserSignedOut() async {
    try {
      _logger.i('User signed out - clearing tokens');
      await clearTokens();
    } catch (e, stackTrace) {
      _logger.e('Error handling user sign out', error: e, stackTrace: stackTrace);
    }
  }

  /// Sync token with backend without forcing refresh
  Future<void> syncToken({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        await refreshToken();
      } else {
        await _handleTokenRegistration();
      }
    } catch (e, stackTrace) {
      _logger.e('Error syncing token', error: e, stackTrace: stackTrace);
    }
  }
}
