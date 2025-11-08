import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../models/comment.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> sendCommentNotification({
    required Comment comment,
    required List<String> mentionedUserIds,
  }) async {
    for (final userId in mentionedUserIds) {
      await _createNotification(
        userId: userId,
        type: 'comment_mention',
        title: 'You were mentioned in a comment',
        body: '${comment.authorNickname} mentioned you: ${_truncateContent(comment.content)}',
        data: {
          'commentId': comment.id,
          'postId': comment.postId,
          'type': 'comment_mention',
        },
      );
    }

    await _createNotification(
      userId: comment.authorId,
      type: 'comment_reply',
      title: 'New reply to your comment',
      body: 'Someone replied to your comment: ${_truncateContent(comment.content)}',
      data: {
        'commentId': comment.id,
        'postId': comment.postId,
        'type': 'comment_reply',
      },
    );
  }

  Future<void> sendPostNotification({
    required String postAuthorId,
    required String postAuthorNickname,
    required String postId,
    required List<String> mentionedUserIds,
  }) async {
    for (final userId in mentionedUserIds) {
      await _createNotification(
        userId: userId,
        type: 'post_mention',
        title: 'You were mentioned in a post',
        body: '$postAuthorNickname mentioned you in a post',
        data: {
          'postId': postId,
          'type': 'post_mention',
        },
      );
    }
  }

  Future<void> _createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    final notificationRef = _firestore.collection('notifications').doc();

    await notificationRef.set({
      'userId': userId,
      'type': type,
      'title': title,
      'body': body,
      'data': data,
      'createdAt': DateTime.now().toIso8601String(),
      'read': false,
    });

    await _sendPushNotification(
      userId: userId,
      title: title,
      body: body,
      data: data,
    );
  }

  Future<void> _sendPushNotification({
    required String userId,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return;

      final fcmToken = userDoc.get('fcmToken') as String?;
      if (fcmToken == null) return;

      await _messaging.sendMessage(
        to: fcmToken,
        data: {
          'title': title,
          'body': body,
          ...data,
        },
      );
    } catch (e) {
      // Log error but don't fail the operation
      print('Failed to send push notification: $e');
    }
  }

  String _truncateContent(String content, {int maxLength = 50}) {
    if (content.length <= maxLength) return content;
    return '${content.substring(0, maxLength)}...';
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'read': true,
    });
  }

  Future<void> markAllNotificationsAsRead(String userId) async {
    final notifications = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .get();

    final batch = _firestore.batch();
    for (final doc in notifications.docs) {
      batch.update(doc.reference, {'read': true});
    }
    await batch.commit();
  }

  Stream<QuerySnapshot> getUnreadNotificationsStream(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Future<List<DocumentSnapshot>> getUnreadNotifications(String userId) async {
    final snapshot = await _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs;
  }
}