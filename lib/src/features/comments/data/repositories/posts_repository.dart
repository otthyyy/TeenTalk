import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/comment.dart';

class PostsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  static const String _postsCollection = 'posts';
  static const String _imagesFolder = 'post_images';
  static const int _maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int _minContentLength = 1;
  static const int _maxContentLength = 2000;

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

  Future<String?> uploadPostImage(File imageFile) async {
    try {
      // Validate image size
      final fileSize = await imageFile.length();
      if (fileSize > _maxImageSizeBytes) {
        throw Exception('Image size exceeds 5MB limit');
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'post_${timestamp}_${imageFile.path.split('/').last}';
      
      // Upload to Firebase Storage
      final ref = _storage.ref().child('$_imagesFolder/$fileName');
      final uploadTask = await ref.putFile(imageFile);
      
      // Get download URL
      final downloadUrl = await uploadTask.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  Future<void> validatePostContent(String content) {
    if (content.trim().isEmpty) {
      throw Exception('Post content cannot be empty');
    }
    if (content.trim().length < _minContentLength) {
      throw Exception('Post content must be at least $_minContentLength characters');
    }
    if (content.length > _maxContentLength) {
      throw Exception('Post content cannot exceed $_maxContentLength characters');
    }
    
    // Profanity filter placeholder - in real implementation, this would check against a profanity list
    final profanityWords = ['spam', 'inappropriate']; // Placeholder
    final lowerContent = content.toLowerCase();
    for (final word in profanityWords) {
      if (lowerContent.contains(word)) {
        throw Exception('Post contains inappropriate content');
      }
    }
  }

  Future<Post> createPost({
    required String authorId,
    required String authorNickname,
    required bool isAnonymous,
    required String content,
    File? imageFile,
    String section = 'Spotted',
  }) async {
    // Validate content
    await validatePostContent(content);

    final now = DateTime.now();
    final mentionedUserIds = _extractMentionedUserIds(content);
    String? imageUrl;

    // Upload image if provided
    if (imageFile != null) {
      imageUrl = await uploadPostImage(imageFile);
    }

    final postData = {
      'authorId': authorId,
      'authorNickname': authorNickname,
      'isAnonymous': isAnonymous,
      'content': content,
      'section': section,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'likeCount': 0,
      'likedBy': <String>[],
      'commentCount': 0,
      'mentionedUserIds': mentionedUserIds,
      'isModerated': false,
      if (imageUrl != null) 'imageUrl': imageUrl,
    };

    final docRef = await _firestore.collection(_postsCollection).add(postData);
    
    // Update user's anonymous posts count if applicable
    if (isAnonymous) {
      await _updateAnonymousPostsCount(authorId);
    }

    // Trigger moderation pipeline (placeholder)
    await _triggerModerationPipeline(docRef.id, content, imageUrl);

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
    final reportRef = _firestore.collection('postReports').doc();

    await _firestore.runTransaction((transaction) async {
      final postDoc = await transaction.get(postRef);
      
      if (!postDoc.exists) return;

      transaction.set(reportRef, {
        'postId': postId,
        'reason': reason,
        'createdAt': DateTime.now().toIso8601String(),
        'status': 'pending',
      });

      transaction.update(postRef, {
        'isModerated': true,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> _updateAnonymousPostsCount(String userId) async {
    final userRef = _firestore.collection('users').doc(userId);
    
    await _firestore.runTransaction((transaction) async {
      final userDoc = await transaction.get(userRef);
      
      if (userDoc.exists) {
        final currentCount = userDoc.data()?['anonymousPostsCount'] as int? ?? 0;
        transaction.update(userRef, {
          'anonymousPostsCount': currentCount + 1,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      } else {
        // Create user document if it doesn't exist
        transaction.set(userRef, {
          'anonymousPostsCount': 1,
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
    });
  }

  Future<void> _triggerModerationPipeline(String postId, String content, String? imageUrl) async {
    try {
      // Placeholder for Cloud Function trigger or moderation pipeline
      // In a real implementation, this would:
      // 1. Call a Cloud Function for content analysis
      // 2. Queue the post for moderation review
      // 3. Apply AI-based content filtering
      
      // For now, we'll just log the moderation request
      print('Moderation triggered for post: $postId');
      print('Content: $content');
      print('Has image: ${imageUrl != null}');
      
      // Store moderation request in Firestore for processing
      await _firestore.collection('moderationQueue').add({
        'postId': postId,
        'content': content,
        'hasImage': imageUrl != null,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
        'priority': 'normal',
      });
    } catch (e) {
      // Log error but don't fail the post creation
      print('Failed to trigger moderation pipeline: $e');
    }
  }

  List<String> _extractMentionedUserIds(String content) {
    final RegExp mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }
}