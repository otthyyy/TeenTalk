import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:logger/logger.dart';

class FCMMessagingService {
  final FirebaseMessaging _firebaseMessaging;
  final Logger _logger = Logger();

  FCMMessagingService({FirebaseMessaging? firebaseMessaging})
      : _firebaseMessaging = firebaseMessaging ?? FirebaseMessaging.instance;

  /// Initialize FCM and request permissions
  Future<void> initialize() async {
    try {
      // Request notification permissions (iOS)
      final settings = await _firebaseMessaging.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      _logger.i(
          'FCM Notification settings: ${settings.authorizationStatus}');

      // Get and log FCM token for backend registration
      final token = await _firebaseMessaging.getToken();
      _logger.i('FCM Token: $token');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        _logger.i('Got a message whilst in the foreground!');
        _logger.i('Message data: ${message.data}');

        if (message.notification != null) {
          _logger.i(
              'Message also contained a notification: ${message.notification}');
        }
      });

      // Handle background message tap
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        _logger.i('Message clicked!');
        _logger.i('Message data: ${message.data}');
      });

      // Handle token refresh
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _logger.i('FCM Token refreshed: $newToken');
        // TODO: Send new token to backend/Firestore for user
      });
    } catch (e) {
      _logger.e('Error initializing FCM: $e');
    }
  }

  /// Send a notification for a new message
  /// This is a stub - actual implementation would use Cloud Functions
  Future<void> sendMessageNotification({
    required String recipientToken,
    required String senderName,
    required String messagePreview,
    required String conversationId,
  }) async {
    try {
      _logger.i(
          'Sending notification to $recipientToken for message from $senderName');

      // TODO: Implement via Cloud Functions
      // The actual notification would be sent from Cloud Functions
      // which are triggered by Firestore write operations

      _logger.i('Notification sent (stub implementation)');
    } catch (e) {
      _logger.e('Error sending notification: $e');
    }
  }

  /// Get current FCM token
  Future<String?> getToken() async {
    try {
      return await _firebaseMessaging.getToken();
    } catch (e) {
      _logger.e('Error getting FCM token: $e');
      return null;
    }
  }

  /// Subscribe to a topic for group notifications
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _firebaseMessaging.subscribeToTopic(topic);
      _logger.i('Subscribed to topic: $topic');
    } catch (e) {
      _logger.e('Error subscribing to topic: $e');
    }
  }

  /// Unsubscribe from a topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(topic);
      _logger.i('Unsubscribed from topic: $topic');
    } catch (e) {
      _logger.e('Error unsubscribing from topic: $e');
    }
  }

  /// Handle background message
  static Future<void> _firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    final logger = Logger();
    logger.i('Handling a background message: ${message.messageId}');
  }

  /// Set up background message handler
  static Future<void> setupBackgroundMessageHandler() async {
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);
  }
}
