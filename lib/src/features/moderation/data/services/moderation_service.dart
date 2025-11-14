import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:logger/logger.dart';
import '../models/content_report.dart';
import '../models/moderation_item.dart';
import '../models/report_reason.dart';

class ModerationService {

  ModerationService({
    FirebaseFirestore? firestore,
    Logger? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _logger = logger ?? Logger();
  final FirebaseFirestore _firestore;
  final Logger _logger;

  static const int _reportThreshold = 3;
  static const int _maxReportsPerUserPerDay = 10;

  Future<void> submitReport({
    required String contentId,
    required ContentType contentType,
    required String reporterId,
    required String contentAuthorId,
    required ReportReason reason,
    String? additionalDetails,
  }) async {
    try {
      final canReport = await _checkReportRateLimit(reporterId);
      if (!canReport) {
        throw Exception('Rate limit exceeded. You can only submit $maxReportsPerUserPerDay reports per day.');
      }

      final report = ContentReport(
        id: '',
        contentId: contentId,
        contentType: contentType,
        reporterId: reporterId,
        contentAuthorId: contentAuthorId,
        reason: reason,
        additionalDetails: additionalDetails,
        status: ReportStatus.pending,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('reportedContent').add(report.toFirestore());

      await _incrementReportCount(contentId, contentType, contentAuthorId);

      _logger.i('Report submitted successfully for $contentType: $contentId');
    } catch (e) {
      _logger.e('Error submitting report: $e');
      rethrow;
    }
  }

  Future<bool> _checkReportRateLimit(String userId) async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final reportsSnapshot = await _firestore
          .collection('reportedContent')
          .where('reporterId', isEqualTo: userId)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(yesterday))
          .get();

      return reportsSnapshot.docs.length < _maxReportsPerUserPerDay;
    } catch (e) {
      _logger.e('Error checking report rate limit: $e');
      return true;
    }
  }

  Future<void> _incrementReportCount(
    String contentId,
    ContentType contentType,
    String authorId,
  ) async {
    try {
      final docRef = _firestore.collection('moderationQueue').doc(contentId);
      final doc = await docRef.get();

      if (doc.exists) {
        await docRef.update({
          'reportCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        final moderationItem = ModerationItem(
          contentId: contentId,
          contentType: contentType,
          authorId: authorId,
          reportCount: 1,
          status: ModerationStatus.active,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await docRef.set(moderationItem.toFirestore());
      }
    } catch (e) {
      _logger.e('Error incrementing report count: $e');
      rethrow;
    }
  }

  Future<bool> isContentHidden(String contentId) async {
    try {
      final doc = await _firestore
          .collection('moderationQueue')
          .doc(contentId)
          .get();

      if (!doc.exists) return false;

      final item = ModerationItem.fromFirestore(doc);
      return item.status == ModerationStatus.hidden || 
             item.status == ModerationStatus.removed;
    } catch (e) {
      _logger.e('Error checking content visibility: $e');
      return false;
    }
  }

  Future<int> getUserReportCount(String userId) async {
    try {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final reportsSnapshot = await _firestore
          .collection('reportedContent')
          .where('reporterId', isEqualTo: userId)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(yesterday))
          .get();

      return reportsSnapshot.docs.length;
    } catch (e) {
      _logger.e('Error getting user report count: $e');
      return 0;
    }
  }

  Future<bool> hasUserReportedContent(String userId, String contentId) async {
    try {
      final reportsSnapshot = await _firestore
          .collection('reportedContent')
          .where('reporterId', isEqualTo: userId)
          .where('contentId', isEqualTo: contentId)
          .limit(1)
          .get();

      return reportsSnapshot.docs.isNotEmpty;
    } catch (e) {
      _logger.e('Error checking if user reported content: $e');
      return false;
    }
  }

  Stream<List<ContentReport>> getReportsForContent(String contentId) {
    return _firestore
        .collection('reportedContent')
        .where('contentId', isEqualTo: contentId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ContentReport.fromFirestore(doc))
            .toList());
  }

  Stream<List<ModerationItem>> getModerationQueue() {
    return _firestore
        .collection('moderationQueue')
        .where('status', whereIn: [
          ModerationStatus.active.value,
          ModerationStatus.hidden.value
        ])
        .orderBy('reportCount', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ModerationItem.fromFirestore(doc))
            .toList());
  }

  Future<void> resolveReport({
    required String reportId,
    required String adminId,
    required ReportStatus newStatus,
    String? resolutionNotes,
  }) async {
    try {
      await _firestore.collection('reportedContent').doc(reportId).update({
        'status': newStatus.value,
        'resolvedAt': FieldValue.serverTimestamp(),
        'resolvedBy': adminId,
        'resolutionNotes': resolutionNotes,
      });

      _logger.i('Report $reportId resolved by admin $adminId');
    } catch (e) {
      _logger.e('Error resolving report: $e');
      rethrow;
    }
  }

  Future<void> updateModerationStatus({
    required String contentId,
    required ModerationStatus newStatus,
    required String adminId,
  }) async {
    try {
      await _firestore.collection('moderationQueue').doc(contentId).update({
        'status': newStatus.value,
        'reviewedAt': FieldValue.serverTimestamp(),
        'reviewedBy': adminId,
        'updatedAt': FieldValue.serverTimestamp(),
        if (newStatus == ModerationStatus.hidden)
          'hiddenAt': FieldValue.serverTimestamp(),
      });

      _logger.i('Content $contentId moderation status updated to ${newStatus.value}');
    } catch (e) {
      _logger.e('Error updating moderation status: $e');
      rethrow;
    }
  }

  int get reportThreshold => _reportThreshold;
  int get maxReportsPerUserPerDay => _maxReportsPerUserPerDay;
}
