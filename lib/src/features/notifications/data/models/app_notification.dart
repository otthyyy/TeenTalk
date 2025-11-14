import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  commentMention,
  commentReply,
  postMention,
  general;

  static NotificationType fromString(String value) {
    switch (value) {
      case 'comment_mention':
        return NotificationType.commentMention;
      case 'comment_reply':
        return NotificationType.commentReply;
      case 'post_mention':
        return NotificationType.postMention;
      default:
        return NotificationType.general;
    }
  }

  String toFirebaseValue() {
    switch (this) {
      case NotificationType.commentMention:
        return 'comment_mention';
      case NotificationType.commentReply:
        return 'comment_reply';
      case NotificationType.postMention:
        return 'post_mention';
      case NotificationType.general:
        return 'general';
    }
  }
}

class AppNotification {

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    required this.createdAt,
    required this.read,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final rawData = doc.data() as Map<String, dynamic>? ?? {};
    return AppNotification(
      id: doc.id,
      userId: rawData['userId'] as String? ?? '',
      type: NotificationType.fromString(rawData['type'] as String? ?? ''),
      title: rawData['title'] as String? ?? '',
      body: rawData['body'] as String? ?? '',
      data: Map<String, String>.from(rawData['data'] as Map? ?? {}),
      createdAt: DateTime.tryParse(rawData['createdAt'] as String? ?? '') ?? DateTime.now(),
      read: rawData['read'] as bool? ?? false,
    );
  }
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String body;
  final Map<String, String> data;
  final DateTime createdAt;
  final bool read;

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    Map<String, String>? data,
    DateTime? createdAt,
    bool? read,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      read: read ?? this.read,
    );
  }

  String? get postId => data['postId'];
  String? get commentId => data['commentId'];
}
