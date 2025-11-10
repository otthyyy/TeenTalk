import 'package:cloud_firestore/cloud_firestore.dart';

enum FeedbackType {
  bug,
  feature,
  improvement,
  other,
}

enum FeedbackPriority {
  low,
  medium,
  high,
  critical,
}

class BetaFeedback {
  final String id;
  final String userId;
  final String userNickname;
  final FeedbackType type;
  final FeedbackPriority priority;
  final String title;
  final String description;
  final String? deviceInfo;
  final String? appVersion;
  final DateTime createdAt;
  final String status;
  final String? adminResponse;
  final DateTime? respondedAt;

  const BetaFeedback({
    required this.id,
    required this.userId,
    required this.userNickname,
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    this.deviceInfo,
    this.appVersion,
    required this.createdAt,
    this.status = 'pending',
    this.adminResponse,
    this.respondedAt,
  });

  factory BetaFeedback.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BetaFeedback(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userNickname: data['userNickname'] as String? ?? 'Anonymous',
      type: FeedbackType.values.firstWhere(
        (e) => e.name == (data['type'] as String? ?? 'other'),
        orElse: () => FeedbackType.other,
      ),
      priority: FeedbackPriority.values.firstWhere(
        (e) => e.name == (data['priority'] as String? ?? 'medium'),
        orElse: () => FeedbackPriority.medium,
      ),
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      deviceInfo: data['deviceInfo'] as String?,
      appVersion: data['appVersion'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      status: data['status'] as String? ?? 'pending',
      adminResponse: data['adminResponse'] as String?,
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userNickname': userNickname,
      'type': type.name,
      'priority': priority.name,
      'title': title,
      'description': description,
      'deviceInfo': deviceInfo,
      'appVersion': appVersion,
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status,
      'adminResponse': adminResponse,
      'respondedAt': respondedAt != null 
          ? Timestamp.fromDate(respondedAt!) 
          : null,
    };
  }

  BetaFeedback copyWith({
    String? id,
    String? userId,
    String? userNickname,
    FeedbackType? type,
    FeedbackPriority? priority,
    String? title,
    String? description,
    String? deviceInfo,
    String? appVersion,
    DateTime? createdAt,
    String? status,
    String? adminResponse,
    DateTime? respondedAt,
  }) {
    return BetaFeedback(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      userNickname: userNickname ?? this.userNickname,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      title: title ?? this.title,
      description: description ?? this.description,
      deviceInfo: deviceInfo ?? this.deviceInfo,
      appVersion: appVersion ?? this.appVersion,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
      adminResponse: adminResponse ?? this.adminResponse,
      respondedAt: respondedAt ?? this.respondedAt,
    );
  }
}
