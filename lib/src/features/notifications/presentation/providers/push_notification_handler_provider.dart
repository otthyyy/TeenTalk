import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:logger/logger.dart';

final pushNotificationHandlerProvider = Provider<PushNotificationHandler>((ref) {
  final handler = PushNotificationHandler();
  ref.onDispose(handler.dispose);
  return handler;
});

class PushNotificationHandler {
  final Logger _logger = Logger();
  StreamSubscription<RemoteMessage>? _messageOpenedAppSubscription;
  GoRouter? _router;
  bool _isInitialized = false;

  void initialize(GoRouter router, {Stream<RemoteMessage>? messageOpenedAppStream}) {
    if (_isInitialized) {
      _router = router;
      return;
    }

    _router = router;
    _isInitialized = true;

    final stream = messageOpenedAppStream ?? FirebaseMessaging.onMessageOpenedApp;

    _messageOpenedAppSubscription = stream.listen((message) {
      _logger.i('Push notification tapped (background): ${message.data}');
      _handleNotificationTap(message.data);
    });
    
    _logger.i('Push notification handler initialized');
  }

  Future<void> handleInitialMessage(RemoteMessage? message) async {
    if (message == null) return;
    
    _logger.i('Handling initial message (terminated state): ${message.data}');
    
    await Future.delayed(const Duration(milliseconds: 500));
    
    _handleNotificationTap(message.data);
  }

  void handleForegroundNotificationTap(Map<String, dynamic> data) {
    _logger.i('Foreground notification tapped: $data');
    _handleNotificationTap(data);
  }

  void _handleNotificationTap(Map<String, dynamic> data) {
    if (_router == null) {
      _logger.w('Router not initialized, cannot handle notification tap');
      return;
    }

    final type = data['type'] as String?;
    final postId = data['postId'] as String?;
    final conversationId = data['conversationId'] as String?;
    final otherUserId = data['otherUserId'] as String?;

    _logger.i('Notification type: $type, postId: $postId, conversationId: $conversationId');

    // TODO: Add analytics logging here
    // _logNotificationOpen(type: type, route: targetRoute);

    switch (type) {
      case 'comment_reply':
      case 'comment_mention':
      case 'post_mention':
        if (postId != null && postId.isNotEmpty) {
          _router!.go('/feed?openComments=true&postId=$postId');
        } else {
          _logger.w('Post ID missing for comment notification, navigating to notifications');
          _router!.go('/notifications');
        }
        break;

      case 'direct_message':
        if (conversationId != null && conversationId.isNotEmpty && 
            otherUserId != null && otherUserId.isNotEmpty) {
          final displayName = data['displayName'] as String?;
          _router!.go(
            '/messages/chat/$conversationId/$otherUserId${displayName != null ? '?displayName=${Uri.encodeComponent(displayName)}' : ''}',
          );
        } else {
          _logger.w('Conversation/User ID missing for DM notification, navigating to messages');
          _router!.go('/messages');
        }
        break;

      default:
        _logger.i('Unknown notification type or fallback, navigating to notifications');
        _router!.go('/notifications');
        break;
    }
  }

  void dispose() {
    _messageOpenedAppSubscription?.cancel();
  }
}
