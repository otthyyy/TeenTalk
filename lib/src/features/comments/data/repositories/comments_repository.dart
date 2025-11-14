import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/comment.dart';
import '../models/comment_failure.dart';

class CommentsRepository {

  CommentsRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _firestore;
  static const String _commentsCollection = 'comments';
  static const String _postsCollection = 'posts';

  Future<(List<Comment>, DocumentSnapshot?)> getCommentsByPostId({
    required String postId,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    try {
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

      final comments = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Comment.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();

      final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      return (comments, lastDoc);
    } catch (error, stackTrace) {
      debugPrint('getCommentsByPostId error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw _mapError(error);
    }
  }

  Future<Comment?> getCommentById(String commentId) async {
    try {
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
    } catch (error) {
      throw _mapError(error);
    }
  }

  Future<Comment> createComment({
    required String postId,
    required String authorId,
    required String authorNickname,
    required bool isAnonymous,
    required String content,
    required String school,
    String? replyToCommentId,
  }) async {
    try {
      if (content.trim().isEmpty) {
        throw CommentFailure.invalidData(
          message: 'Comment content cannot be empty.',
        );
      }

      final now = DateTime.now();
      final mentionedUserIds = _extractMentionedUserIds(content);

      final commentData = {
        'postId': postId,
        'authorId': authorId,
        'authorNickname': authorNickname,
        'isAnonymous': isAnonymous,
        'content': content,
        'school': school,
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

        if (!postDoc.exists) {
          throw CommentFailure.notFound(
            message: 'Cannot comment on a post that no longer exists.',
          );
        }

        final currentCommentCount = postDoc.get('commentCount') as int? ?? 0;
        transaction.update(postRef, {
          'commentCount': currentCommentCount + 1,
          'updatedAt': now.toIso8601String(),
        });

        if (replyToCommentId != null) {
          final replyRef =
              _firestore.collection(_commentsCollection).doc(replyToCommentId);
          final replyDoc = await transaction.get(replyRef);

          if (replyDoc.exists) {
            final currentReplyCount = replyDoc.get('replyCount') as int? ?? 0;
            transaction.update(replyRef, {
              'replyCount': currentReplyCount + 1,
              'updatedAt': now.toIso8601String(),
            });
          } else {
            throw CommentFailure.notFound(
              message: 'The comment you are replying to was not found.',
            );
          }
        }

        return Comment.fromJson({
          ...commentData,
          'id': commentRef.id,
        });
      }).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          debugPrint('createComment timeout after 15 seconds');
          throw CommentFailure.timeout(
            message: 'Comment submission timed out. Please check your connection and try again.',
          );
        },
      );
    } catch (error, stackTrace) {
      debugPrint('createComment error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw _mapError(error);
    }
  }

  Future<void> updateComment({
    required String commentId,
    required String content,
  }) async {
    try {
      if (content.trim().isEmpty) {
        throw CommentFailure.invalidData(
          message: 'Comment content cannot be empty.',
        );
      }

      final now = DateTime.now();
      final mentionedUserIds = _extractMentionedUserIds(content);

      await _firestore.collection(_commentsCollection).doc(commentId).update({
        'content': content,
        'mentionedUserIds': mentionedUserIds,
        'updatedAt': now.toIso8601String(),
      });
    } catch (error, stackTrace) {
      debugPrint('updateComment error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw _mapError(error);
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _firestore.runTransaction((transaction) async {
        final commentRef =
            _firestore.collection(_commentsCollection).doc(commentId);
        final commentDoc = await transaction.get(commentRef);

        if (!commentDoc.exists) {
          throw CommentFailure.notFound(
            message: 'The comment you are trying to delete no longer exists.',
          );
        }

        final commentData = commentDoc.data() as Map<String, dynamic>;
        final postId = commentData['postId'] as String;
        final replyToCommentId = commentData['replyToCommentId'] as String?;

        final postRef = _firestore.collection(_postsCollection).doc(postId);
        final postDoc = await transaction.get(postRef);

        if (postDoc.exists) {
          final currentCommentCount = postDoc.get('commentCount') as int? ?? 0;
          transaction.update(postRef, {
            'commentCount': (currentCommentCount - 1)
                .clamp(0, double.infinity)
                .toInt(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }

        if (replyToCommentId != null) {
          final replyRef =
              _firestore.collection(_commentsCollection).doc(replyToCommentId);
          final replyDoc = await transaction.get(replyRef);

          if (replyDoc.exists) {
            final currentReplyCount = replyDoc.get('replyCount') as int? ?? 0;
            transaction.update(replyRef, {
              'replyCount': (currentReplyCount - 1)
                  .clamp(0, double.infinity)
                  .toInt(),
              'updatedAt': DateTime.now().toIso8601String(),
            });
          }
        }

        transaction.delete(commentRef);
      });
    } catch (error, stackTrace) {
      debugPrint('deleteComment error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw _mapError(error);
    }
  }

  Future<void> likeComment(String commentId, String userId) async {
    try {
      final commentRef =
          _firestore.collection(_commentsCollection).doc(commentId);

      await _firestore.runTransaction((transaction) async {
        final commentDoc = await transaction.get(commentRef);

        if (!commentDoc.exists) {
          throw CommentFailure.notFound(
            message: 'The comment you are trying to like was not found.',
          );
        }

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
    } catch (error, stackTrace) {
      debugPrint('likeComment error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw _mapError(error);
    }
  }

  Future<void> unlikeComment(String commentId, String userId) async {
    try {
      final commentRef =
          _firestore.collection(_commentsCollection).doc(commentId);

      await _firestore.runTransaction((transaction) async {
        final commentDoc = await transaction.get(commentRef);

        if (!commentDoc.exists) {
          throw CommentFailure.notFound(
            message: 'The comment you are trying to unlike was not found.',
          );
        }

        final data = commentDoc.data() as Map<String, dynamic>;
        final likedBy = List<String>.from(data['likedBy'] as List? ?? []);
        final currentLikeCount = data['likeCount'] as int? ?? 0;

        if (likedBy.contains(userId)) {
          likedBy.remove(userId);
          transaction.update(commentRef, {
            'likedBy': likedBy,
            'likeCount': (currentLikeCount - 1)
                .clamp(0, double.infinity)
                .toInt(),
            'updatedAt': DateTime.now().toIso8601String(),
          });
        }
      });
    } catch (error, stackTrace) {
      debugPrint('unlikeComment error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw _mapError(error);
    }
  }

  Future<void> reportComment(String commentId, String reason) async {
    try {
      if (reason.trim().isEmpty) {
        throw CommentFailure.invalidData(
          message: 'Report reason cannot be empty.',
        );
      }

      final commentRef =
          _firestore.collection(_commentsCollection).doc(commentId);
      final reportRef = _firestore.collection('reports').doc();

      await _firestore.runTransaction((transaction) async {
        final commentDoc = await transaction.get(commentRef);

        if (!commentDoc.exists) {
          throw CommentFailure.notFound(
            message: 'The comment you are reporting was not found.',
          );
        }

        final commentData = commentDoc.data() as Map<String, dynamic>;
        final now = DateTime.now();

        transaction.set(reportRef, {
          'itemId': commentId,
          'itemType': 'comment',
          'authorId': commentData['authorId'],
          'authorNickname': commentData['authorNickname'],
          'content': commentData['content'],
          'reason': reason,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
          'status': 'pending',
        });

        transaction.update(commentRef, {
          'isModerated': true,
          'updatedAt': now.toIso8601String(),
        });
      });
    } catch (error, stackTrace) {
      debugPrint('reportComment error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw _mapError(error);
    }
  }

  Future<List<Comment>> getRepliesForComment({
    required String commentId,
    DocumentSnapshot? lastDocument,
    int limit = 10,
  }) async {
    try {
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
    } catch (error, stackTrace) {
      debugPrint('getRepliesForComment error: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw _mapError(error);
    }
  }

  List<String> _extractMentionedUserIds(String content) {
    final RegExp mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }

  CommentFailure _mapError(Object error) {
    if (error is CommentFailure) {
      return error;
    }

    if (error is FirebaseException) {
      return CommentFailure.fromFirebaseException(error);
    }

    if (error is FirebaseException) {
      return CommentFailure.fromFirebaseException(error);
    }

    return CommentFailure.unknown(
      message: error.toString(),
      originalError: error,
    );
  }
}
