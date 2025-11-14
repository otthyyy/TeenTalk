import 'package:cloud_firestore/cloud_firestore.dart';

enum AuditAction {
  postCreated('post_created'),
  postReported('post_reported'),
  postHidden('post_hidden'),
  postRemoved('post_removed'),
  postRestored('post_restored');

  final String value;
  const AuditAction(this.value);

  static AuditAction fromString(String value) {
    return AuditAction.values.firstWhere(
      (action) => action.value == value,
      orElse: () => AuditAction.postCreated,
    );
  }
}

class AuditLog {

  const AuditLog({
    required this.id,
    required this.contentId,
    required this.originalAuthorId,
    required this.action,
    this.performedBy,
    this.reason,
    this.metadata,
    required this.timestamp,
  });

  factory AuditLog.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AuditLog(
      id: doc.id,
      contentId: data['contentId'] as String,
      originalAuthorId: data['originalAuthorId'] as String,
      action: AuditAction.fromString(data['action'] as String),
      performedBy: data['performedBy'] as String?,
      reason: data['reason'] as String?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }
  final String id;
  final String contentId;
  final String originalAuthorId;
  final AuditAction action;
  final String? performedBy;
  final String? reason;
  final Map<String, dynamic>? metadata;
  final DateTime timestamp;

  Map<String, dynamic> toFirestore() {
    return {
      'contentId': contentId,
      'originalAuthorId': originalAuthorId,
      'action': action.value,
      'performedBy': performedBy,
      'reason': reason,
      'metadata': metadata,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }
}
