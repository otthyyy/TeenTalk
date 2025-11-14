import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/audit_log.dart';

class AuditLogService {

  AuditLogService({
    FirebaseFirestore? firestore,
    Logger? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _logger = logger ?? Logger();
  final FirebaseFirestore _firestore;
  final Logger _logger;

  Future<void> createAuditLog({
    required String contentId,
    required String originalAuthorId,
    required AuditAction action,
    String? performedBy,
    String? reason,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final auditLog = AuditLog(
        id: '',
        contentId: contentId,
        originalAuthorId: originalAuthorId,
        action: action,
        performedBy: performedBy,
        reason: reason,
        metadata: metadata,
        timestamp: DateTime.now(),
      );

      await _firestore
          .collection('moderationQueue')
          .doc(contentId)
          .collection('auditLogs')
          .add(auditLog.toFirestore());

      _logger.i('Audit log created for content: $contentId, action: ${action.value}');
    } catch (e) {
      _logger.e('Error creating audit log: $e');
      rethrow;
    }
  }

  Stream<List<AuditLog>> getAuditLogsForContent(String contentId) {
    return _firestore
        .collection('moderationQueue')
        .doc(contentId)
        .collection('auditLogs')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AuditLog.fromFirestore(doc))
            .toList());
  }

  Future<List<AuditLog>> getAuditLogsForUser(String userId) async {
    try {
      final snapshot = await _firestore
          .collectionGroup('auditLogs')
          .where('originalAuthorId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();

      return snapshot.docs.map((doc) => AuditLog.fromFirestore(doc)).toList();
    } catch (e) {
      _logger.e('Error getting audit logs for user: $e');
      return [];
    }
  }
}
