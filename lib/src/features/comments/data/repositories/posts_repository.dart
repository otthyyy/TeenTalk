import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:logger/logger.dart';
import 'dart:io';
import 'dart:typed_data';
import '../models/comment.dart';
import '../../../feed/domain/models/feed_sort_option.dart';
import '../../../../core/utils/search_keywords_generator.dart';
import '../../../feed/data/services/feed_cache_service.dart';
import '../../../../core/exceptions/post_exceptions.dart';

/// Repository for managing posts in Firestore.
/// 
/// IMPORTANT: Ensure Firestore security rules allow:
/// - Read access to posts collection for authenticated users
/// - Write access to posts collection for authenticated users
/// - Update access to likedBy and likeCount fields for authenticated users
/// - Transaction access for atomic updates on like/unlike operations
/// 
/// Example security rule for likes:
/// ```
/// allow update: if request.auth != null 
///   && request.resource.data.keys().hasOnly(['likedBy', 'likeCount', 'updatedAt'])
///   && request.auth.uid in request.resource.data.likedBy;
/// ```
class PostsRepository {

  PostsRepository({
    FirebaseFirestore? firestore,
    FirebaseStorage? storage,
    Logger? logger,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance,
        _logger = logger ?? Logger();
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final Logger _logger;
  final FeedCacheService _cacheService = FeedCacheService();
  
  static const String _postsCollection = 'posts';
  static const String _imagesFolder = 'post_images';
  static const int _maxImageSizeBytes = 5 * 1024 * 1024; // 5MB
  static const int _minContentLength = 1;
  static const int _maxContentLength = 2000;

  void invalidateCache({String? section, String? school}) {
    if (section != null || school != null) {
      _cacheService.invalidate(section: section, school: school);
    } else {
      _cacheService.clearAll();
    }
  }

  Map<String, dynamic> getCacheMetrics() => _cacheService.getMetrics();

  Future<({
    List<Post> posts,
    DocumentSnapshot? lastDocument,
    bool hasMore,
    String? paginationToken,
  })> getPosts({
    DocumentSnapshot? lastDocument,
    int limit = 20,
    String? section,
    String? school,
    FeedSortOption sortOption = FeedSortOption.newest,
    bool forceRefresh = false,
  }) async {
    final shouldUseCache = !forceRefresh && lastDocument == null;

    if (shouldUseCache) {
      final cached = _cacheService.get(
        section: section,
        school: school,
        sortField: sortOption.primaryOrderField,
      );
      if (cached != null) {
        _logger.d('Feed cache hit for section=$section sort=${sortOption.name}');
        return (
          posts: cached.posts,
          lastDocument: cached.lastDocument,
          hasMore: cached.hasMore,
          paginationToken: cached.paginationToken,
        );
      }
    }

    Query query = _firestore
        .collection(_postsCollection)
        .where('isModerated', isEqualTo: false);

    if (section != null) {
      query = query.where('section', isEqualTo: section);
    }

    if (school != null) {
      query = query.where('school', isEqualTo: school);
    }

    query = query.orderBy(
      sortOption.primaryOrderField,
      descending: sortOption.isDescending,
    );

    final secondaryOrderField = sortOption.secondaryOrderField;
    if (secondaryOrderField != null) {
      query = query.orderBy(
        secondaryOrderField,
        descending: sortOption.isDescending,
      );
    }

    query = query.limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final QuerySnapshot snapshot = await query.get();

    final posts = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Post.fromJson({
        ...data,
        'id': doc.id,
      });
    }).toList();

    final nextLastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : lastDocument;
    final hasMore = snapshot.docs.length == limit;
    final paginationToken = posts.isNotEmpty
        ? '${posts.last.createdAt.toIso8601String()}_${posts.last.id}'
        : null;

    if (shouldUseCache && posts.isNotEmpty) {
      _cacheService.set(
        posts: posts,
        hasMore: hasMore,
        readCount: snapshot.docs.length,
        lastDocument: nextLastDocument,
        section: section,
        school: school,
        sortField: sortOption.primaryOrderField,
      );
    }

    return (
      posts: posts,
      lastDocument: nextLastDocument,
      hasMore: hasMore,
      paginationToken: paginationToken,
    );
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

  Future<String?> uploadPostImage(
    File? imageFile, {
    Uint8List? imageBytes,
    String? imageName,
  }) async {
    try {
      if (imageFile == null && imageBytes == null) {
        return null;
      }

      _logger.i('[PostsRepository] Starting image upload '
          'source=${imageFile != null ? 'file' : 'bytes'} name=$imageName');

      final int fileSize;
      if (imageFile != null) {
        try {
          fileSize = await imageFile.length();
        } on FileSystemException catch (e) {
          _logger.e('[PostsRepository] Failed to read image file size', error: e);
          throw const ImageValidationException(
            'Failed to read selected image. Please select a different file.',
          );
        }
      } else {
        fileSize = imageBytes!.length;
      }

      if (fileSize > _maxImageSizeBytes) {
        throw const ImageValidationException(
          'The selected image is larger than 5MB. Choose a smaller image.',
        );
      }

      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = imageFile != null
          ? 'post_${timestamp}_${imageFile.path.split('/').last}'
          : 'post_${timestamp}_${imageName ?? 'image.jpg'}';

      final ref = _storage.ref().child('$_imagesFolder/$fileName');
      final metadata = SettableMetadata(contentType: _inferImageContentType(fileName));

      UploadTask uploadTask;
      try {
        uploadTask = imageFile != null
            ? ref.putFile(imageFile, metadata)
            : ref.putData(imageBytes!, metadata);
      } on FirebaseException catch (e, stackTrace) {
        _logger.e('[PostsRepository] Failed to start image upload task',
            error: e, stackTrace: stackTrace);
        throw const PostStorageException(
          'Unable to start image upload. Please try again.',
        );
      }

      try {
        final snapshot = await uploadTask;
        final downloadUrl = await snapshot.ref.getDownloadURL();
        _logger.i('[PostsRepository] Image upload completed downloadUrl=$downloadUrl');
        return downloadUrl;
      } on FirebaseException catch (e, stackTrace) {
        _logger.e('[PostsRepository] Storage error during upload',
            error: e, stackTrace: stackTrace);
        if (e.code == 'canceled') {
          throw const PostStorageException('Image upload was cancelled.');
        }
        throw const ImageUploadNetworkException();
      } catch (e, stackTrace) {
        _logger.e('[PostsRepository] Unknown error during image upload',
            error: e, stackTrace: stackTrace);
        throw const PostStorageException();
      }
    } on ImageValidationException {
      rethrow;
    } on PostException {
      rethrow;
    } catch (e, stackTrace) {
      _logger.e('[PostsRepository] Unexpected image upload failure',
          error: e, stackTrace: stackTrace);
      throw const PostStorageException();
    }
  }

  Future<void> validatePostContent(String content) async {
    if (content.trim().isEmpty) {
      throw const PostValidationException(
        'Post content cannot be empty',
        userMessage: 'Please enter some content for your post.',
      );
    }
    if (content.trim().length < _minContentLength) {
      throw const PostValidationException(
        'Post content must be at least $_minContentLength characters',
        userMessage: 'Your post must be at least $_minContentLength character long.',
      );
    }
    if (content.length > _maxContentLength) {
      throw const PostValidationException(
        'Post content cannot exceed $_maxContentLength characters',
        userMessage: 'Your post is too long. Maximum is $_maxContentLength characters.',
      );
    }

    // Profanity filter placeholder - in real implementation, this would check against a profanity list
    final profanityWords = ['spam', 'inappropriate']; // Placeholder
    final lowerContent = content.toLowerCase();
    for (final word in profanityWords) {
      if (lowerContent.contains(word)) {
        throw const PostValidationException(
          'Post contains inappropriate content',
          userMessage: 'Your post contains content that violates our guidelines.',
        );
      }
    }
  }

  Future<Post> createPost({
    required String authorId,
    required String authorNickname,
    required bool isAnonymous,
    required String content,
    File? imageFile,
    Uint8List? imageBytes,
    String? imageName,
    String section = 'spotted',
    String? school,
  }) async {
    _logger.i('[PostsRepository] createPost start author=$authorId section=$section');
    try {
      await validatePostContent(content);

      final now = DateTime.now();
      final mentionedUserIds = _extractMentionedUserIds(content);
      String? imageUrl;

      if (imageFile != null || imageBytes != null) {
        imageUrl = await uploadPostImage(
          imageFile,
          imageBytes: imageBytes,
          imageName: imageName,
        );
      }

      final searchKeywords = SearchKeywordsGenerator.generatePostKeywords(
        content: content,
        authorNickname: authorNickname,
        isAnonymous: isAnonymous,
        section: section,
        school: school,
      );

      final postData = {
        'authorId': authorId,
        'authorNickname': authorNickname,
        'isAnonymous': isAnonymous,
        'content': content,
        'section': section,
        'school': school,
        'searchKeywords': searchKeywords,
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
        'likeCount': 0,
        'likedBy': <String>[],
        'commentCount': 0,
        'mentionedUserIds': mentionedUserIds,
        'isModerated': false,
        if (imageUrl != null) 'imageUrl': imageUrl,
      };

      final docRef = _firestore.collection(_postsCollection).doc();

      _logger.i('[PostsRepository] Writing post document id=${docRef.id}');

      await docRef.set(
        postData,
        SetOptions(merge: true),
      );

      if (isAnonymous) {
        await _updateAnonymousPostsCount(authorId);
      }

      await _triggerModerationPipeline(docRef.id, content, imageUrl);

      _logger.i('[PostsRepository] Post created id=${docRef.id}');

      return Post.fromJson({
        ...postData,
        'id': docRef.id,
      });
    } on PostValidationException {
      rethrow;
    } on ImageValidationException {
      rethrow;
    } on PostException catch (e) {
      _logger.e('[PostsRepository] Post creation failed', error: e);
      rethrow;
    } on FirebaseException catch (e, stackTrace) {
      _logger.e('[PostsRepository] Firestore error during create',
          error: e, stackTrace: stackTrace);
      throw const PostFirestoreException();
    } catch (e, stackTrace) {
      _logger.e('[PostsRepository] Unexpected error creating post',
          error: e, stackTrace: stackTrace);
      throw const PostFirestoreException(
        'Unexpected error while creating the post.',
      );
    }
  }

  Future<void> updatePost({
    required String postId,
    required String content,
  }) async {
    final now = DateTime.now();
    final mentionedUserIds = _extractMentionedUserIds(content);

    final postDoc = await _firestore.collection(_postsCollection).doc(postId).get();
    if (!postDoc.exists) {
      throw Exception('Post not found');
    }

    final postData = postDoc.data() as Map<String, dynamic>;
    final searchKeywords = SearchKeywordsGenerator.generatePostKeywords(
      content: content,
      authorNickname: postData['authorNickname'] as String?,
      isAnonymous: postData['isAnonymous'] as bool? ?? false,
      section: postData['section'] as String?,
      school: postData['school'] as String?,
    );

    await _firestore.collection(_postsCollection).doc(postId).update({
      'content': content,
      'mentionedUserIds': mentionedUserIds,
      'searchKeywords': searchKeywords,
      'updatedAt': now.toIso8601String(),
    });
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection(_postsCollection).doc(postId).delete();
  }

  Future<void> likePost(String postId, String userId) async {
    final postRef = _firestore.collection(_postsCollection).doc(postId);

    try {
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) {
          _logger.w('Attempted to like non-existent post: $postId');
          throw Exception('This post no longer exists.');
        }

        final data = postDoc.data() as Map<String, dynamic>;
        final likedBy = List<String>.from(data['likedBy'] as List? ?? []);

        if (likedBy.contains(userId)) {
          return;
        }

        transaction.update(postRef, {
          'likedBy': FieldValue.arrayUnion([userId]),
          'likeCount': FieldValue.increment(1),
          'updatedAt': DateTime.now().toIso8601String(),
        });
      });
    } catch (error, stackTrace) {
      _logger.e('Failed to like post $postId', error: error, stackTrace: stackTrace);
      debugPrint('likePost error for $postId: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception(
        _mapLikeErrorMessage(
          error,
          fallbackMessage: 'We couldn\'t register your like. Please try again.',
          permissionDeniedMessage: 'You don\'t have permission to like this post.',
        ),
      );
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    final postRef = _firestore.collection(_postsCollection).doc(postId);

    try {
      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);

        if (!postDoc.exists) {
          _logger.w('Attempted to unlike non-existent post: $postId');
          throw Exception('This post no longer exists.');
        }

        final data = postDoc.data() as Map<String, dynamic>;
        final likedBy = List<String>.from(data['likedBy'] as List? ?? []);
        final currentLikeCount = data['likeCount'] as int? ?? 0;

        if (!likedBy.contains(userId)) {
          return;
        }

        final updates = <String, dynamic>{
          'likedBy': FieldValue.arrayRemove([userId]),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        if (currentLikeCount > 0) {
          updates['likeCount'] = FieldValue.increment(-1);
        } else {
          updates['likeCount'] = 0;
        }

        transaction.update(postRef, updates);
      });
    } catch (error, stackTrace) {
      _logger.e('Failed to unlike post $postId', error: error, stackTrace: stackTrace);
      debugPrint('unlikePost error for $postId: $error');
      debugPrintStack(stackTrace: stackTrace);
      throw Exception(
        _mapLikeErrorMessage(
          error,
          fallbackMessage: 'We couldn\'t update your like. Please try again.',
          permissionDeniedMessage: 'You don\'t have permission to update this like.',
        ),
      );
    }
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
      _logger.e('Failed to trigger moderation pipeline: $e');
    }
  }

  String _inferImageContentType(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'png':
        return 'image/png';
      case 'gif':
        return 'image/gif';
      case 'webp':
        return 'image/webp';
      case 'heic':
      case 'heif':
        return 'image/heic';
      default:
        return 'image/jpeg';
    }
  }

  Stream<List<Post>> getPostsStream({
    String? section,
    String? school,
    int limit = 20,
    FeedSortOption sortOption = FeedSortOption.newest,
  }) {
    Query query = _firestore
        .collection(_postsCollection)
        .where('isModerated', isEqualTo: false);

    if (section != null) {
      query = query.where('section', isEqualTo: section);
    }

    if (school != null) {
      query = query.where('school', isEqualTo: school);
    }

    query = query.orderBy(
      sortOption.primaryOrderField,
      descending: sortOption.isDescending,
    );

    final secondaryOrderField = sortOption.secondaryOrderField;
    if (secondaryOrderField != null) {
      query = query.orderBy(
        secondaryOrderField,
        descending: sortOption.isDescending,
      );
    }

    query = query.limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }

  String _mapLikeErrorMessage(
    Object error, {
    required String fallbackMessage,
    required String permissionDeniedMessage,
  }) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return permissionDeniedMessage;
        case 'unavailable':
        case 'deadline-exceeded':
          return 'Network connection lost. Please check your connection and try again.';
        case 'not-found':
          return 'This post no longer exists.';
        case 'resource-exhausted':
          return 'Too many requests. Please wait a moment and try again.';
        default:
          return fallbackMessage;
      }
    }

    final errorMessage = error.toString();
    if (errorMessage.contains('post no longer exists')) {
      return 'This post no longer exists.';
    }
    if (errorMessage.contains('network') || errorMessage.contains('connection')) {
      return 'Network connection lost. Please check your connection and try again.';
    }

    return fallbackMessage;
  }

  List<String> _extractMentionedUserIds(String content) {
    final RegExp mentionRegex = RegExp(r'@(\w+)');
    final matches = mentionRegex.allMatches(content);
    return matches.map((match) => match.group(1)!).toList();
  }

  Future<(List<Post>, DocumentSnapshot?)> getPostsByAuthor({
    required String authorId,
    String? school,
    DocumentSnapshot? lastDocument,
    int limit = 20,
  }) async {
    Query query = _firestore
        .collection(_postsCollection)
        .where('authorId', isEqualTo: authorId)
        .where('isAnonymous', isEqualTo: false)
        .where('isModerated', isEqualTo: false);

    if (school != null) {
      query = query.where('school', isEqualTo: school);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final QuerySnapshot snapshot = await query.get();
    
    final posts = snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Post.fromJson({
        ...data,
        'id': doc.id,
      });
    }).toList();

    final lastDoc = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    return (posts, lastDoc);
  }

  Stream<List<Post>> getPostsStreamByAuthor({
    required String authorId,
    String? school,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(_postsCollection)
        .where('authorId', isEqualTo: authorId)
        .where('isAnonymous', isEqualTo: false)
        .where('isModerated', isEqualTo: false);

    if (school != null) {
      query = query.where('school', isEqualTo: school);
    }

    query = query.orderBy('createdAt', descending: true).limit(limit);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Post.fromJson({
          ...data,
          'id': doc.id,
        });
      }).toList();
    });
  }
}