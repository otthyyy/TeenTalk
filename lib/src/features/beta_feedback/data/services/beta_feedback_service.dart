import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../models/beta_feedback.dart';

final betaFeedbackServiceProvider = Provider<BetaFeedbackService>((ref) {
  return BetaFeedbackService();
});

class BetaFeedbackService {

  BetaFeedbackService({
    FirebaseFirestore? firestore,
    Logger? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _logger = logger ?? Logger();
  final FirebaseFirestore _firestore;
  final Logger _logger;

  Future<String> submitFeedback({
    required String userId,
    required String userNickname,
    required FeedbackType type,
    required FeedbackPriority priority,
    required String title,
    required String description,
    String? deviceInfo,
    String? appVersion,
  }) async {
    try {
      final feedback = BetaFeedback(
        id: '',
        userId: userId,
        userNickname: userNickname,
        type: type,
        priority: priority,
        title: title,
        description: description,
        deviceInfo: deviceInfo,
        appVersion: appVersion,
        createdAt: DateTime.now(),
        status: 'pending',
      );

      final docRef = await _firestore
          .collection('betaFeedback')
          .add(feedback.toFirestore());

      _logger.i('Beta feedback submitted successfully: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      _logger.e('Error submitting beta feedback: $e');
      rethrow;
    }
  }

  Stream<List<BetaFeedback>> getUserFeedback(String userId) {
    return _firestore
        .collection('betaFeedback')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BetaFeedback.fromFirestore(doc))
            .toList());
  }

  Stream<List<BetaFeedback>> getAllFeedback() {
    return _firestore
        .collection('betaFeedback')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BetaFeedback.fromFirestore(doc))
            .toList());
  }

  Stream<List<BetaFeedback>> getFeedbackByStatus(String status) {
    return _firestore
        .collection('betaFeedback')
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => BetaFeedback.fromFirestore(doc))
            .toList());
  }

  Future<void> updateFeedbackStatus({
    required String feedbackId,
    required String status,
    String? adminResponse,
  }) async {
    try {
      final updates = <String, dynamic>{
        'status': status,
      };

      if (adminResponse != null) {
        updates['adminResponse'] = adminResponse;
        updates['respondedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore
          .collection('betaFeedback')
          .doc(feedbackId)
          .update(updates);

      _logger.i('Feedback status updated: $feedbackId -> $status');
    } catch (e) {
      _logger.e('Error updating feedback status: $e');
      rethrow;
    }
  }

  Future<BetaFeedback?> getFeedback(String feedbackId) async {
    try {
      final doc = await _firestore
          .collection('betaFeedback')
          .doc(feedbackId)
          .get();

      if (!doc.exists) return null;
      return BetaFeedback.fromFirestore(doc);
    } catch (e) {
      _logger.e('Error getting feedback: $e');
      rethrow;
    }
  }

  Future<int> getUserFeedbackCount(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('betaFeedback')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      _logger.e('Error getting user feedback count: $e');
      return 0;
    }
  }
}
