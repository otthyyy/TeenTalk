import 'package:cloud_firestore/cloud_firestore.dart';

/// Model for user notification preferences
/// Stored under users/{uid}/preferences/notifications
class NotificationPreferences {

  const NotificationPreferences({
    this.enabled = true,
    this.commentsEnabled = true,
    this.likesEnabled = true,
    this.messagesEnabled = true,
    this.followsEnabled = true,
    this.mentionsEnabled = true,
    this.systemEnabled = true,
    required this.updatedAt,
  });

  factory NotificationPreferences.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return NotificationPreferences(
      enabled: data['enabled'] as bool? ?? true,
      commentsEnabled: data['commentsEnabled'] as bool? ?? true,
      likesEnabled: data['likesEnabled'] as bool? ?? true,
      messagesEnabled: data['messagesEnabled'] as bool? ?? true,
      followsEnabled: data['followsEnabled'] as bool? ?? true,
      mentionsEnabled: data['mentionsEnabled'] as bool? ?? true,
      systemEnabled: data['systemEnabled'] as bool? ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory NotificationPreferences.fromMap(Map<String, dynamic> data) {
    return NotificationPreferences(
      enabled: data['enabled'] as bool? ?? true,
      commentsEnabled: data['commentsEnabled'] as bool? ?? true,
      likesEnabled: data['likesEnabled'] as bool? ?? true,
      messagesEnabled: data['messagesEnabled'] as bool? ?? true,
      followsEnabled: data['followsEnabled'] as bool? ?? true,
      mentionsEnabled: data['mentionsEnabled'] as bool? ?? true,
      systemEnabled: data['systemEnabled'] as bool? ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create default notification preferences
  factory NotificationPreferences.defaults() {
    return NotificationPreferences(
      enabled: true,
      commentsEnabled: true,
      likesEnabled: true,
      messagesEnabled: true,
      followsEnabled: true,
      mentionsEnabled: true,
      systemEnabled: true,
      updatedAt: DateTime.now(),
    );
  }
  final bool enabled;
  final bool commentsEnabled;
  final bool likesEnabled;
  final bool messagesEnabled;
  final bool followsEnabled;
  final bool mentionsEnabled;
  final bool systemEnabled;
  final DateTime updatedAt;

  NotificationPreferences copyWith({
    bool? enabled,
    bool? commentsEnabled,
    bool? likesEnabled,
    bool? messagesEnabled,
    bool? followsEnabled,
    bool? mentionsEnabled,
    bool? systemEnabled,
    DateTime? updatedAt,
  }) {
    return NotificationPreferences(
      enabled: enabled ?? this.enabled,
      commentsEnabled: commentsEnabled ?? this.commentsEnabled,
      likesEnabled: likesEnabled ?? this.likesEnabled,
      messagesEnabled: messagesEnabled ?? this.messagesEnabled,
      followsEnabled: followsEnabled ?? this.followsEnabled,
      mentionsEnabled: mentionsEnabled ?? this.mentionsEnabled,
      systemEnabled: systemEnabled ?? this.systemEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'enabled': enabled,
      'commentsEnabled': commentsEnabled,
      'likesEnabled': likesEnabled,
      'messagesEnabled': messagesEnabled,
      'followsEnabled': followsEnabled,
      'mentionsEnabled': mentionsEnabled,
      'systemEnabled': systemEnabled,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
