import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../../comments/data/models/comment.dart';
import '../../../comments/data/repositories/posts_repository.dart';
import '../../../profile/data/repositories/user_repository.dart';
import '../../../auth/data/auth_service.dart';

final feedRepositoryProvider = Provider<PostsRepository>((ref) {
  return PostsRepository();
});

class FeedState {
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.lastDocument,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final PostsRepository _repository;
  StreamSubscription? _postsSubscription;

  FeedNotifier(this._repository) : super(const FeedState());

  @override
  void dispose() {
    _postsSubscription?.cancel();
    super.dispose();
  }

  Future<void> loadPosts({bool refresh = false, String? section, String? school}) async {
    if (refresh) {
      state = const FeedState(isLoading: true);
    } else if (state.isLoading || state.isLoadingMore) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      final (posts, lastDoc) = await _repository.getPosts(
        lastDocument: refresh ? null : state.lastDocument,
        limit: 20,
        section: section,
        school: school,
      );

      if (posts.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          hasMore: false,
        );
        return;
      }

      final allPosts = refresh ? posts : [...state.posts, ...posts];

      state = state.copyWith(
        posts: allPosts,
        isLoading: false,
        lastDocument: lastDoc,
        hasMore: posts.length == 20,
      );

      // Set up real-time updates
      _setupRealtimeUpdates(section, school);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMorePosts({String? school}) async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final (posts, lastDoc) = await _repository.getPosts(
        lastDocument: state.lastDocument,
        limit: 20,
        school: school,
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
    String? school,
  }) async {
    try {
      final post = await _repository.createPost(
        authorId: authorId,
        authorNickname: authorNickname,
        isAnonymous: isAnonymous,
        content: content,
        section: section,
        school: school,
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

  void _setupRealtimeUpdates(String? section, String? school) {
    _postsSubscription?.cancel();
    
    _postsSubscription = _repository
        .getPostsStream(section: section, school: school, limit: 50)
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

  void clearError() {
    state = state.copyWith(error: null);
  }
}

final feedProvider = StateNotifierProvider.family<FeedNotifier, FeedState, String>(
  (ref, section) {
    final repository = ref.watch(feedRepositoryProvider);
    return FeedNotifier(repository);
  },
);

// School-aware feed provider that gets user's school and applies filtering
final schoolAwareFeedProvider = StateNotifierProvider.family<FeedNotifier, FeedState, String>(
  (ref, section) {
    final repository = ref.watch(feedRepositoryProvider);
    final userRepository = ref.watch(userRepositoryProvider);
    final authService = ref.watch(firebaseAuthServiceProvider);
    
    // Create a custom notifier that handles school filtering
    return SchoolAwareFeedNotifier(repository, userRepository, authService);
  },
);

class SchoolAwareFeedNotifier extends FeedNotifier {
  final UserRepository _userRepository;
  final FirebaseAuthService _authService;
  
  SchoolAwareFeedNotifier(
    PostsRepository repository, 
    this._userRepository, 
    this._authService,
  ) : super(repository);

  @override
  Future<void> loadPosts({bool refresh = false, String? section, String? school}) async {
    // Get current user's school if not provided
    if (school == null) {
      final user = _authService.currentUser;
      if (user != null) {
        try {
          final userProfile = await _userRepository.getUserProfile(user.uid);
          school = userProfile?.school;
        } catch (e) {
          // If we can't get user profile, proceed without school filtering
          school = null;
        }
      }
    }
    
    await super.loadPosts(refresh: refresh, section: section, school: school);
  }

  @override
  Future<void> loadMorePosts({String? school}) async {
    // Get current user's school if not provided
    if (school == null) {
      final user = _authService.currentUser;
      if (user != null) {
        try {
          final userProfile = await _userRepository.getUserProfile(user.uid);
          school = userProfile?.school;
        } catch (e) {
          // If we can't get user profile, proceed without school filtering
          school = null;
        }
      }
    }
    
    await super.loadMorePosts(school: school);
  }

  @override
  Future<void> addPost({
    required String authorId,
    required String authorNickname,
    required bool isAnonymous,
    required String content,
    String section = 'spotted',
    String? school,
  }) async {
    // Get current user's school if not provided
    if (school == null) {
      final user = _authService.currentUser;
      if (user != null) {
        try {
          final userProfile = await _userRepository.getUserProfile(user.uid);
          school = userProfile?.school;
        } catch (e) {
          // If we can't get user profile, proceed without school filtering
          school = null;
        }
      }
    }
    
    await super.addPost(
      authorId: authorId,
      authorNickname: authorNickname,
      isAnonymous: isAnonymous,
      content: content,
      section: section,
      school: school,
    );
  }
}