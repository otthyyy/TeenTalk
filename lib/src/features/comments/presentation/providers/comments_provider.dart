import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../data/models/comment.dart';
import '../../data/repositories/comments_repository.dart';
import '../../data/repositories/posts_repository.dart';
import '../../data/services/notification_service.dart';

final commentsRepositoryProvider = Provider<CommentsRepository>((ref) {
  return CommentsRepository();
});

final postsRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepository();
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

final selectedCommentSchoolProvider = StateProvider<String?>((ref) => null);

class CommentsState {
  final List<Comment> comments;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const CommentsState({
    this.comments = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.lastDocument,
    this.hasMore = true,
  });

  CommentsState copyWith({
    List<Comment>? comments,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
  }) {
    return CommentsState(
      comments: comments ?? this.comments,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class CommentsNotifier extends StateNotifier<CommentsState> {
  final CommentsRepository _repository;
  final String _postId;

  CommentsNotifier(this._repository, this._postId) : super(const CommentsState());

  Future<void> loadComments({bool refresh = false}) async {
    if (refresh) {
      state = const CommentsState(isLoading: true);
    } else if (state.isLoading || state.isLoadingMore) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final comments = await _repository.getCommentsByPostId(
        postId: _postId,
        lastDocument: refresh ? null : state.lastDocument,
        limit: 20,
      );

      if (comments.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          hasMore: false,
        );
        return;
      }

      final allComments = refresh ? comments : [...state.comments, ...comments];
      final newLastDocument = comments.length < 20 ? null : comments.last;

      state = state.copyWith(
        comments: allComments,
        isLoading: false,
        lastDocument: newLastDocument,
        hasMore: comments.length == 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMoreComments() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final comments = await _repository.getCommentsByPostId(
        postId: _postId,
        lastDocument: state.lastDocument,
        limit: 20,
      );

      if (comments.isEmpty) {
        state = state.copyWith(
          isLoadingMore: false,
          hasMore: false,
        );
        return;
      }

      final allComments = [...state.comments, ...comments];
      final newLastDocument = comments.length < 20 ? null : comments.last;

      state = state.copyWith(
        comments: allComments,
        isLoadingMore: false,
        lastDocument: newLastDocument,
        hasMore: comments.length == 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addComment({
    required String authorId,
    required String authorNickname,
    required bool isAnonymous,
    required String content,
    required String school,
    String? replyToCommentId,
  }) async {
    try {
      final comment = await _repository.createComment(
        postId: _postId,
        authorId: authorId,
        authorNickname: authorNickname,
        isAnonymous: isAnonymous,
        content: content,
        school: school,
        replyToCommentId: replyToCommentId,
      );

      state = state.copyWith(
        comments: [comment, ...state.comments],
      );

      if (replyToCommentId != null) {
        final updatedComments = state.comments.map((c) {
          if (c.id == replyToCommentId) {
            return c.copyWith(replyCount: c.replyCount + 1);
          }
          return c;
        }).toList();

        state = state.copyWith(comments: updatedComments);
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> updateComment(String commentId, String content) async {
    try {
      await _repository.updateComment(commentId: commentId, content: content);

      final updatedComments = state.comments.map((comment) {
        if (comment.id == commentId) {
          return comment.copyWith(
            content: content,
            updatedAt: DateTime.now(),
          );
        }
        return comment;
      }).toList();

      state = state.copyWith(comments: updatedComments);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> deleteComment(String commentId) async {
    try {
      await _repository.deleteComment(commentId);

      final updatedComments = state.comments
          .where((comment) => comment.id != commentId)
          .toList();

      state = state.copyWith(comments: updatedComments);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> likeComment(String commentId, String userId) async {
    try {
      await _repository.likeComment(commentId, userId);

      final updatedComments = state.comments.map((comment) {
        if (comment.id == commentId) {
          final likedBy = [...comment.likedBy, userId];
          return comment.copyWith(
            likeCount: comment.likeCount + 1,
            likedBy: likedBy,
          );
        }
        return comment;
      }).toList();

      state = state.copyWith(comments: updatedComments);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unlikeComment(String commentId, String userId) async {
    try {
      await _repository.unlikeComment(commentId, userId);

      final updatedComments = state.comments.map((comment) {
        if (comment.id == commentId) {
          final likedBy = comment.likedBy.where((id) => id != userId).toList();
          return comment.copyWith(
            likeCount: (comment.likeCount - 1).clamp(0, double.infinity).toInt(),
            likedBy: likedBy,
          );
        }
        return comment;
      }).toList();

      state = state.copyWith(comments: updatedComments);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final commentsProvider = StateNotifierProvider.family<CommentsNotifier, CommentsState, String>(
  (ref, postId) {
    final repository = ref.watch(commentsRepositoryProvider);
    return CommentsNotifier(repository, postId);
  },
);

class PostsState {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;
  final String? currentSection;

  const PostsState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.lastDocument,
    this.hasMore = true,
    this.currentSection,
  });

  PostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    DocumentSnapshot? lastDocument,
    bool? hasMore,
    String? currentSection,
  }) {
    return PostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      lastDocument: lastDocument ?? this.lastDocument,
      hasMore: hasMore ?? this.hasMore,
      currentSection: currentSection ?? this.currentSection,
    );
  }
}

class PostsNotifier extends StateNotifier<PostsState> {
  final PostsRepository _repository;
  StreamSubscription? _postsSubscription;

  PostsNotifier(this._repository) : super(const PostsState());

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadPosts({bool refresh = false, String? section}) async {
    if (refresh) {
      state = PostsState(isLoading: true, currentSection: section);
    } else if (state.isLoading || state.isLoadingMore) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final (posts, lastDoc) = await _repository.getPosts(
        lastDocument: refresh ? null : state.lastDocument,
        limit: 20,
        section: section,
      );

      if (posts.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          hasMore: false,
          currentSection: section,
        );
        return;
      }

      final allPosts = refresh ? posts : [...state.posts, ...posts];

      state = state.copyWith(
        posts: allPosts,
        isLoading: false,
        lastDocument: lastDoc,
        hasMore: posts.length == 20,
        currentSection: section,
      );

      // Set up real-time updates
      _setupRealtimeUpdates(section);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
        currentSection: section,
      );
    }
  }

  void _setupRealtimeUpdates(String? section) {
    _postsSubscription?.cancel();
    
    _postsSubscription = _repository
        .getPostsStream(section: section, limit: 50)
        .listen((realtimePosts) {
      if (state.posts.isNotEmpty && realtimePosts.isNotEmpty) {
        // Merge real-time updates with existing posts
        final existingPostIds = state.posts.map((p) => p.id).toSet();
        final newPosts = realtimePosts.where((p) => !existingPostIds.contains(p.id));
        
        if (newPosts.isNotEmpty) {
          final updatedPosts = [...newPosts, ...state.posts];
          state = state.copyWith(posts: updatedPosts);
        }
      }
    }, onError: (error) {
      // Handle real-time errors silently to not disrupt UI
    });
  }

  Future<void> loadMorePosts() async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final (posts, lastDoc) = await _repository.getPosts(
        lastDocument: state.lastDocument,
        limit: 20,
        section: state.currentSection,
      );

      if (posts.isEmpty) {
        state = state.copyWith(
          isLoadingMore: false,
          hasMore: false,
        );
        return;
      }

      final allPosts = [...state.posts, ...posts];

      state = state.copyWith(
        posts: allPosts,
        isLoadingMore: false,
        lastDocument: lastDoc,
        hasMore: posts.length == 20,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }

  Future<void> addPost({
    required String authorId,
    required String authorNickname,
    required bool isAnonymous,
    required String content,
    String section = 'spotted',
  }) async {
    try {
      final post = await _repository.createPost(
        authorId: authorId,
        authorNickname: authorNickname,
        isAnonymous: isAnonymous,
        content: content,
        section: section,
      );

      state = state.copyWith(
        posts: [post, ...state.posts],
      );
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> likePost(String postId, String userId) async {
    try {
      await _repository.likePost(postId, userId);

      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          final likedBy = [...post.likedBy, userId];
          return post.copyWith(
            likeCount: post.likeCount + 1,
            likedBy: likedBy,
          );
        }
        return post;
      }).toList();

      state = state.copyWith(posts: updatedPosts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  Future<void> unlikePost(String postId, String userId) async {
    try {
      await _repository.unlikePost(postId, userId);

      final updatedPosts = state.posts.map((post) {
        if (post.id == postId) {
          final likedBy = post.likedBy.where((id) => id != userId).toList();
          return post.copyWith(
            likeCount: (post.likeCount - 1).clamp(0, double.infinity).toInt(),
            likedBy: likedBy,
          );
        }
        return post;
      }).toList();

      state = state.copyWith(posts: updatedPosts);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final postsProvider = StateNotifierProvider<PostsNotifier, PostsState>(
  (ref) {
    final repository = ref.watch(postsRepositoryProvider);
    return PostsNotifier(repository);
  },
);