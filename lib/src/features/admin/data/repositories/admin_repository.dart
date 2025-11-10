import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import '../models/report.dart';
import '../models/extended_analytics.dart';

class AdminRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  static const String _reportsCollection = 'reports';
  static const String _moderationDecisionsCollection = 'moderationDecisions';
  static const String _postsCollection = 'posts';
  static const String _commentsCollection = 'comments';

  Future<List<Report>> getReports({
    String? status,
    DateTime? startDate,
    DateTime? endDate,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query query = _firestore.collection(_reportsCollection);

    if (status != null && status.isNotEmpty && status != 'all') {
      query = query.where('status', isEqualTo: status);
    }

    if (startDate != null) {
      query = query.where('createdAt',
          isGreaterThanOrEqualTo: startDate.toIso8601String());
    }

    if (endDate != null) {
      query = query.where('createdAt',
          isLessThanOrEqualTo: endDate.toIso8601String());
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final QuerySnapshot snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Report.fromJson({
        ...data,
        'id': doc.id,
      });
    }).toList();
  }

  Future<Report?> getReportById(String reportId) async {
    final DocumentSnapshot doc =
        await _firestore.collection(_reportsCollection).doc(reportId).get();

    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return Report.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  Future<void> updateReportStatus({
    required String reportId,
    required String status,
    required String moderatorId,
    String? notes,
  }) async {
    final now = DateTime.now();

    await _firestore.runTransaction((transaction) async {
      final reportRef = _firestore.collection(_reportsCollection).doc(reportId);
      final reportDoc = await transaction.get(reportRef);

      if (!reportDoc.exists) return;

      transaction.update(reportRef, {
        'status': status,
        'updatedAt': now.toIso8601String(),
      });

      final decisionRef =
          _firestore.collection(_moderationDecisionsCollection).doc();
      transaction.set(decisionRef, {
        'reportId': reportId,
        'moderatorId': moderatorId,
        'decision': status,
        'notes': notes,
        'createdAt': now.toIso8601String(),
      });
    });
  }

  Future<void> deleteContent({
    required String itemId,
    required String itemType,
  }) async {
    if (itemType == 'post') {
      await _firestore.collection(_postsCollection).doc(itemId).delete();
    } else if (itemType == 'comment') {
      await _firestore.collection(_commentsCollection).doc(itemId).delete();
    }
  }

  Future<void> restoreContent({
    required String itemId,
    required String itemType,
  }) async {
    if (itemType == 'post') {
      await _firestore
          .collection(_postsCollection)
          .doc(itemId)
          .update({'isModerated': false});
    } else if (itemType == 'comment') {
      await _firestore
          .collection(_commentsCollection)
          .doc(itemId)
          .update({'isModerated': false});
    }
  }

  Future<AdminAnalytics> getAnalytics() async {
    try {
      final callable = _functions.httpsCallable('getModerationStats');
      final result = await callable.call();
      final data = result.data as Map<String, dynamic>;
      return AdminAnalytics.fromJson(data);
    } catch (e) {
      return const AdminAnalytics(
        activeReportCount: 0,
        flaggedPostCount: 0,
        flaggedCommentCount: 0,
        userBanCount: 0,
        resolvedReportCount: 0,
        dismissedReportCount: 0,
      );
    }
  }

  Future<Map<String, dynamic>?> getReportedContent({
    required String itemId,
    required String itemType,
  }) async {
    if (itemType == 'post') {
      final doc =
          await _firestore.collection(_postsCollection).doc(itemId).get();
      return doc.data();
    } else if (itemType == 'comment') {
      final doc =
          await _firestore.collection(_commentsCollection).doc(itemId).get();
      return doc.data();
    }
    return null;
  }

  Future<List<ModerationDecision>> getModerationDecisions({
    String? reportId,
    int limit = 50,
  }) async {
    Query query = _firestore.collection(_moderationDecisionsCollection);

    if (reportId != null) {
      query = query.where('reportId', isEqualTo: reportId);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    final QuerySnapshot snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ModerationDecision.fromJson({
        ...data,
        'id': doc.id,
      });
    }).toList();
  }

  Future<ExtendedAnalytics> getExtendedAnalytics({
    DateTime? startDate,
    DateTime? endDate,
    String? school,
  }) async {
    try {
      final callable = _functions.httpsCallable('getExtendedAnalytics');
      final result = await callable.call({
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (school != null) 'school': school,
      });

      return ExtendedAnalytics.fromJson(
        result.data as Map<String, dynamic>,
      );
    } catch (e) {
      return const ExtendedAnalytics(
        dailyMetrics: [],
        schoolMetrics: [],
        reportReasons: {},
        totalUsers: 0,
        activeUsers: 0,
        totalPosts: 0,
        totalComments: 0,
      );
    }
  }
}
