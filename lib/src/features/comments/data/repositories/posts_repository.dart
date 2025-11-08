import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/comment.dart';

class PostsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _postsCollection = 'posts';

  Future<List<Post>> getPosts({
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection(_postsCollection)
        .where('isModerated', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final QuerySnapshot snapshot = await query.get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Post.fromJson({
        ...data,
        'id': doc.id,
      });
    }).toList();
  }

  Future<Post?> getPostById(String postId) async {
    final DocumentSnapshot doc = await _firestore
        .collection(_postsCollection)
        .doc(postId)
        .get();

    if (!doc.exists) return null;

    final data = doc.data() as Map<String, dynamic>;
    return Post.fromJson({
      ...data,
      'id': doc.id,
    });
  }

  Future<Post> createPost({
    required String authorId,
    required String authorNickname,
    required bool isAnonymous,
    required String content,
  }) async {
    final now = DateTime.now();
    final mentionedUserIds = _extractMentionedUserIds(content);

    final postData = {
      'authorId': authorId,
      'authorNickname': authorNickname,
      'isAnonymous': isAnonymous,
      'content': content,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'likeCount': 0,
      'likedBy': <String>[],
      'commentCount': 0,
      'mentionedUserIds': mentionedUserIds,
      'isModerated': false,
    };

    final docRef = await _firestore.collection(_postsCollection).add(postData);
    
    return Post.fromJson({
      ...postData,
      'id': docRef.id,
    });
  }

  Future<void> updatePost({
    required String postId,
    required String content,
  }) async {
    final now = DateTime.now();
    final mentionedUserIds = _extractMentionedUserIds(content);

    await _firestore.collection(_postsCollection).doc(postId).update({
      'content': content,
      'mentionedUserIds': mentionedUserIds,
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection(_postsCollection).doc(postId).delete();
  }

  Future<void> likePost(String postId, String userId) async {
    final postRef = _firestore.collection(_postsCollection).doc(postId);

    await _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      
      if (!postDoc.exists) return;

      final data = postDoc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] as List? ?? []);
      final currentLikeCount = data['likeCount'] as int? ?? 0;

      if (!likedBy.contains(userId)) {
        likedBy.add(userId);
        transaction.update(postRef, {
          'likedBy': likedBy,
          'likeCount': currentLikeCount + 1,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  Future<void> unlikePost(String postId, String userId) async {
    final postRef = _firestore.collection(_postsCollection).doc(postId);

    await _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      
      if (!postDoc.exists) return;

      final data = postDoc.data() as Map<String, dynamic>;
      final likedBy = List<String>.from(data['likedBy'] as List? ?? []);
      final currentLikeCount = data['likeCount'] as int? ?? 0;

      if (likedBy.contains(userId)) {
        likedBy.remove(userId);
        transaction.update(postRef, {
          'likedBy': likedBy,
          'likeCount': (currentLikeCount - 1).clamp(0, double.infinity).toInt(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  Future<void> reportPost(String postId, String reason) async {
    final postRef = _firestore.collection(_postsCollection).doc(postId);
    final reportRef = _firestore.collection('reports').doc();

    await _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      
      if (!postDoc.exists) return;

      final postData = postDoc.data() as Map<String, dynamic>;
      final now = DateTime.now();

      transaction.set(reportRef, {
        'itemId': postId,
        'itemType': 'post',
        'authorId': postData['authorId'],
        'authorNickname': postData['authorNickname'],
        'content': postData['content'],
        'reason': reason,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'status': 'pending',
      });

      transaction.update(postRef, {
        'isModerated': true,
        'updatedAt': now.toIso8601String(),
      });
    });
  }

  List<String> _extractMentionedUserIds(String content) {
    final RegExp mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }
}