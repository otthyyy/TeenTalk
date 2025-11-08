import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class CommentsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _commentsCollection = 'comments';
  static const String _postsCollection = 'posts';

  Future<List<Comment>> getCommentsByPostId({
    required String postId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection(_commentsCollection)
        .where('postId', isEqualTo: postId)
        .where('isModerated', isEqualTo: false)
        .orderBy('createdAt', descending: false)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final QuerySnapshot snapshot = await query.get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Comment.fromJson({
        ...data,
        'id': doc.id,
      });
    }).toList();
  }

  Future<Comment?> getCommentById(String commentId) async {
    final DocumentSnapshot doc = await _firestore
        .collection(_commentsCollection)
        .doc(commentId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return Comment.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  Future<Comment> createComment({
    required String postId,
    required String authorId,
    required String authorNickname,
    required bool isAnonymous,
    required String content,
    String? replyToCommentId,
  }) async {
    final now = DateTime.now();
    final mentionedUserIds = _extractMentionedUserIds(content);

    final commentData = {
      'postId': postId,
      'authorId': authorId,
      'authorNickname': authorNickname,
      'isAnonymous': isAnonymous,
      'content': content,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'likeCount': 0,
      'likedBy': <String>[],
      'mentionedUserIds': mentionedUserIds,
      'isModerated': false,
      'replyToCommentId': replyToCommentId,
      'replyCount': 0,
    };

    return await _firestore.runTransaction((transaction) async {
      final commentRef = _firestore.collection(_commentsCollection).doc();
      transaction.set(commentRef, commentData);

      final postRef = _firestore.collection(_postsCollection).doc(postId);
      final postDoc = await transaction.get(postRef);
      
      if (postDoc.exists) {
        final currentCommentCount = postDoc.get('commentCount') as int? ?? 0;
        transaction.update(postRef, {
          'commentCount': currentCommentCount + 1,
          'updatedAt': now.toIso8601String(),
        });

        if (replyToCommentId != null) {
          final replyRef = _firestore.collection(_commentsCollection).doc(replyToCommentId);
          final replyDoc = await transaction.get(replyRef);
          
          if (replyDoc.exists) {
            final currentReplyCount = replyDoc.get('replyCount') as int? ?? 0;
            transaction.update(replyRef, {
              'replyCount': currentReplyCount + 1,
              'updatedAt': now.toIso8601String(),
            });
          }
        }
      }

      return Comment.fromJson({
        ...commentData,
        'id': commentRef.id,
      });
    });
  }

  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    final now = DateTime.now();
    final mentionedUserIds = _extractMentionedUserIds(content);

    await _firestore.collection(_commentsCollection).doc(commentId).update({
      'content': content,
      'mentionedUserIds': mentionedUserIds,
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> deleteComment(String commentId) async {
    await _firestore.runTransaction((transaction) async {
      final commentRef = _firestore.collection(_commentsCollection).doc(commentId);
      final commentDoc = await transaction.get(commentRef);

      if (!commentDoc.exists) return;

      final commentData = commentDoc.data() as Map<String, dynamic>;
      final postId = commentData['postId'] as String;
      final replyToCommentId = commentData['replyToCommentId'] as String?;

      final postRef = _firestore.collection(_postsCollection).doc(postId);
      final postDoc = await transaction.get(postRef);
      
      if (postDoc.exists) {
        final currentCommentCount = postDoc.get('commentCount') as int? ?? 0;
        transaction.update(postRef, {
          'commentCount': (currentCommentCount - 1).clamp(0, double.infinity).toInt(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }

      if (replyToCommentId != null) {
        final replyRef = _firestore.collection(_commentsCollection).doc(replyToCommentId);
        final replyDoc = await transaction.get(replyRef);
        
        if (replyDoc.exists) {
          final currentReplyCount = replyDoc.get('replyCount') as int? ?? 0;
          transaction.update(replyRef, {
            'replyCount': (currentReplyCount - 1).clamp(0, double.infinity).toInt(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      }

      transaction.delete(commentRef);
    });
  }

  Future<void> likeComment(String commentId, String userId) async {
    final commentRef = _firestore.collection(_commentsCollection).doc(commentId);

    await _firestore.runTransaction((transaction) async {
      final commentDoc = await transaction.get(commentRef);
      
      if (!commentDoc.exists) return;

      final data = commentDoc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] as List? ?? []);
      final currentLikeCount = data['likeCount'] as int? ?? 0;

      if (!likedBy.contains(userId)) {
        likedBy.add(userId);
        transaction.update(commentRef, {
          'likedBy': likedBy,
          'likeCount': currentLikeCount + 1,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  Future<void> unlikeComment(String commentId, String userId) async {
    final commentRef = _firestore.collection(_commentsCollection).doc(commentId);

    await _firestore.runTransaction((transaction) async {
      final commentDoc = await transaction.get(commentRef);
      
      if (!commentDoc.exists) return;

      final data = commentDoc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] as List? ?? []);
      final currentLikeCount = data['likeCount'] as int? ?? 0;

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
        transaction.update(commentRef, {
          'likedBy': likedBy,
          'likeCount': (currentLikeCount - 1).clamp(0, double.infinity).toInt(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  Future<void> reportComment(String commentId, String reason) async {
    final commentRef = _firestore.collection(_commentsCollection).doc(commentId);
    final reportRef = _firestore.collection('commentReports').doc();

    await _firestore.runTransaction((transaction) async {
      final commentDoc = await transaction.get(commentRef);
      
      if (!commentDoc.exists) return;

      transaction.set(reportRef, {
        'commentId': commentId,
        'reason': reason,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'pending',
      });

      transaction.update(commentRef, {
        'isModerated': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<List<Comment>> getRepliesForComment({
    required String commentId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    Query query = _firestore
        .collection(_commentsCollection)
        .where('replyToCommentId', isEqualTo: commentId)
        .where('isModerated', isEqualTo: false)
        .orderBy('createdAt', descending: false)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final QuerySnapshot snapshot = await query.get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Comment.fromJson({
        ...data,
        'id': doc.id,
      });
    }).toList();
  }

  List<String> _extractMentionedUserIds(String content) {
    final RegExp mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }
}