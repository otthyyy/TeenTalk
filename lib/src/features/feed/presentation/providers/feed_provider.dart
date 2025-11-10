import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/providers/feed_cache_provider.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/feed_cache_service.dart';
import '../../../auth/data/services/firebase_auth_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../comments/data/models/comment.dart';
import '../../../comments/data/repositories/posts_repository.dart';
import '../../../profile/data/repositories/user_repository.dart';
import '../../data/services/filter_preferences_service.dart';
import '../../domain/models/feed_sort_option.dart';

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
  final FeedSortOption sortOption;
  final bool isOffline;
  final DateTime? lastSyncedAt;

  const FeedState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.hasMore = true,
    this.lastDocument,
    this.sortOption = FeedSortOption.newest,
    this.isOffline = false,
    this.lastSyncedAt,
  });

  FeedState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool? hasMore,
    DocumentSnapshot? lastDocument,
    FeedSortOption? sortOption,
    bool? isOffline,
    DateTime? lastSyncedAt,
  }) {
    return FeedState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      hasMore: hasMore ?? this.hasMore,
      lastDocument: lastDocument ?? this.lastDocument,
      sortOption: sortOption ?? this.sortOption,
      isOffline: isOffline ?? this.isOffline,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }
}

class FeedNotifier extends StateNotifier<FeedState> {
  final PostsRepository _repository;
  final FeedCacheService _cacheService;
  final ConnectivityService _connectivityService;
  final Logger _logger = Logger();

  StreamSubscription? _postsSubscription;
  StreamSubscription<bool>? _connectivitySubscription;

  String? _currentSection;
  String? _currentSchool;
  FeedSortOption _currentSortOption = FeedSortOption.newest;

  String? get currentSection => _currentSection;
  String? get currentSchool => _currentSchool;
  FeedSortOption get currentSortOption => _currentSortOption;

  FeedNotifier(
    this._repository,
    this._cacheService,
    this._connectivityService,
  ) : super(const FeedState()) {
    _connectivitySubscription = _connectivityService.connectivityStream.listen((isConnected) {
      state = state.copyWith(isOffline: !isConnected);

      if (isConnected && state.posts.isEmpty) {
        unawaited(
          loadPosts(
            refresh: true,
            section: _currentSection,
            school: _currentSchool,
            sortOption: _currentSortOption,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _postsSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }

  Future<void> loadPosts({
    bool refresh = false,
    String? section,
    String? school,
    FeedSortOption? sortOption,
  }) async {
    final effectiveSortOption = sortOption ?? state.sortOption;

    if (refresh) {
      state = FeedState(
        isLoading: true,
        sortOption: effectiveSortOption,
        isOffline: !_connectivityService.isConnected,
      );
    } else if (state.isLoading || state.isLoadingMore) {
      return;
    }

    try {
      state = state.copyWith(isLoading: true, error: null);

      if (section != null) {
        _currentSection = section;
      }
      if (school != null) {
        _currentSchool = school;
      }
      _currentSortOption = effectiveSortOption;

      final resolvedSection = _currentSection ?? 'spotted';
      final resolvedSchool = _currentSchool;

      if (!_connectivityService.isConnected) {
        final cacheEntry = await _cacheService.getCachedPosts(
          sortOption: effectiveSortOption,
          section: resolvedSection,
          school: resolvedSchool,
        );

        if (cacheEntry != null && cacheEntry.posts.isNotEmpty) {
          _logger.i('Loaded ${cacheEntry.posts.length} posts from cache (offline mode)');
          state = state.copyWith(
            posts: cacheEntry.posts,
            isLoading: false,
            hasMore: false,
            sortOption: effectiveSortOption,
            isOffline: true,
            lastSyncedAt: cacheEntry.lastSyncedAt,
          );
        } else {
          state = state.copyWith(
            posts: [],
            isLoading: false,
            hasMore: false,
            isOffline: true,
            error: 'No cached posts available offline',
          );
        }
        return;
      }

      final (posts, lastDoc) = await _repository.getPosts(
        lastDocument: refresh ? null : state.lastDocument,
        limit: 20,
        section: resolvedSection,
        school: resolvedSchool,
        sortOption: effectiveSortOption,
      );

      if (posts.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          hasMore: false,
        );
        return;
      }

      await _cacheService.cachePosts(
        posts,
        sortOption: effectiveSortOption,
        section: resolvedSection,
        school: resolvedSchool,
      );

      final allPosts = refresh ? posts : [...state.posts, ...posts];

      state = state.copyWith(
        posts: allPosts,
        isLoading: false,
        lastDocument: lastDoc,
        hasMore: posts.length == 20,
        sortOption: effectiveSortOption,
        isOffline: false,
        lastSyncedAt: DateTime.now(),
      );

      _setupRealtimeUpdates(resolvedSection, resolvedSchool);
    } catch (e) {
      _logger.e('Error loading posts', error: e);

      if (!_connectivityService.isConnected) {
        final resolvedSection = _currentSection ?? 'spotted';
        final cacheEntry = await _cacheService.getCachedPosts(
          sortOption: effectiveSortOption,
          section: resolvedSection,
          school: _currentSchool,
        );

        if (cacheEntry != null && cacheEntry.posts.isNotEmpty) {
          _logger.i('Fallback to cache after error');
          state = state.copyWith(
            posts: cacheEntry.posts,
            isLoading: false,
            hasMore: false,
            isOffline: true,
            lastSyncedAt: cacheEntry.lastSyncedAt,
            error: null,
          );
          return;
        }
      }

      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadMorePosts({
    String? section,
    String? school,
    FeedSortOption? sortOption,
  }) async {
    if (!state.hasMore || state.isLoadingMore || state.isLoading) return;

    if (!_connectivityService.isConnected) {
      state = state.copyWith(isOffline: true);
      return;
    }

    state = state.copyWith(isLoadingMore: true);

    if (section != null) {
      _currentSection = section;
    }
    if (school != null) {
      _currentSchool = school;
    }
    if (sortOption != null) {
      _currentSortOption = sortOption;
    }

    final resolvedSection = _currentSection ?? 'spotted';
    final resolvedSchool = _currentSchool;
    final resolvedSort = _currentSortOption;

    try {
      final (posts, lastDoc) = await _repository.getPosts(
        lastDocument: state.lastDocument,
        limit: 20,
        section: resolvedSection,
        school: resolvedSchool,
        sortOption: resolvedSort,
      );

      if (posts.isEmpty) {
        state = state.copyWith(
          isLoadingMore: false,
          hasMore: false,
        );
        return;
      }

      await _cacheService.cachePosts(
        [...state.posts, ...posts],
        sortOption: resolvedSort,
        section: resolvedSection,
        school: resolvedSchool,
      );

      final allPosts = [...state.posts, ...posts];

      state = state.copyWith(
        posts: allPosts,
        isLoadingMore: false,
        lastDocument: lastDoc,
        hasMore: posts.length == 20,
        sortOption: resolvedSort,
        lastSyncedAt: DateTime.now(),
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
    } catch (error, stackTrace) {
      _logger.e('Failed to like post $postId', error: error, stackTrace: stackTrace);
      state = state.copyWith(
        error: 'We couldn\'t register your like. Please try again.',
      );
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
    } catch (error, stackTrace) {
      _logger.e('Failed to unlike post $postId', error: error, stackTrace: stackTrace);
      state = state.copyWith(
        error: 'We couldn\'t update your like. Please check your connection and try again.',
      );
    }
  }

  Future<void> updateSortOption(
    FeedSortOption option, {
    String? section,
    String? school,
  }) async {
    if (option == _currentSortOption &&
        (section == null || section == _currentSection) &&
        (school == null || school == _currentSchool)) {
      return;
    }

    await loadPosts(
      refresh: true,
      section: section ?? _currentSection,
      school: school ?? _currentSchool,
      sortOption: option,
    );
  }

  void _setupRealtimeUpdates(String? section, String? school) {
    _postsSubscription?.cancel();
    
    _postsSubscription = _repository
        .getPostsStream(
          section: section,
          school: school,
          limit: 50,
          sortOption: _currentSortOption,
        )
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
    final cacheService = ref.watch(feedCacheServiceProvider);
    final connectivityService = ref.watch(connectivityServiceProvider);

    return FeedNotifier(
      repository,
      cacheService,
      connectivityService,
    );
  },
);

// School-aware feed provider that gets user's school and applies filtering
final schoolAwareFeedProvider = StateNotifierProvider.family<FeedNotifier, FeedState, String>(
  (ref, section) {
    final repository = ref.watch(feedRepositoryProvider);
    final userRepository = ref.watch(userRepositoryProvider);
    final authService = ref.watch(firebaseAuthServiceProvider);
    final cacheService = ref.watch(feedCacheServiceProvider);
    final connectivityService = ref.watch(connectivityServiceProvider);
    
    return SchoolAwareFeedNotifier(
      repository,
      cacheService,
      connectivityService,
      userRepository,
      authService,
    );
  },
);

class SchoolAwareFeedNotifier extends FeedNotifier {
  final UserRepository _userRepository;
  final FirebaseAuthService _authService;
  final FilterPreferencesService _preferencesService = FilterPreferencesService();
  
  SchoolAwareFeedNotifier(
    PostsRepository repository,
    FeedCacheService cacheService,
    ConnectivityService connectivityService,
    this._userRepository,
    this._authService,
  ) : super(
          repository,
          cacheService,
          connectivityService,
        );

  @override
  Future<void> loadPosts({
    bool refresh = false,
    String? section,
    String? school,
    FeedSortOption? sortOption,
  }) async {
    String? effectiveSchool = school;
    FeedSortOption? effectiveSortOption = sortOption;

    if (effectiveSchool == null) {
      final user = _authService.currentUser;
      if (user != null) {
        try {
          final userProfile = await _userRepository.getUserProfile(user.uid);
          effectiveSchool = userProfile?.school;
        } catch (e) {
          effectiveSchool = null;
        }
      }
    }

    if (effectiveSortOption == null && section != null) {
      try {
        effectiveSortOption = await _preferencesService.getSortOrder(section);
      } catch (e) {
        effectiveSortOption = FeedSortOption.newest;
      }
    }
    
    await super.loadPosts(
      refresh: refresh,
      section: section,
      school: effectiveSchool,
      sortOption: effectiveSortOption,
    );
  }

  @override
  Future<void> loadMorePosts({
    String? section,
    String? school,
    FeedSortOption? sortOption,
  }) async {
    String? effectiveSchool = school;

    if (effectiveSchool == null) {
      final user = _authService.currentUser;
      if (user != null) {
        try {
          final userProfile = await _userRepository.getUserProfile(user.uid);
          effectiveSchool = userProfile?.school;
        } catch (e) {
          effectiveSchool = null;
        }
      }
    }
    
    await super.loadMorePosts(
      section: section,
      school: effectiveSchool,
      sortOption: sortOption,
    );
  }

  @override
  Future<void> updateSortOption(
    FeedSortOption option, {
    String? section,
    String? school,
  }) async {
    final targetSection = section ?? currentSection;

    if (targetSection != null) {
      await _preferencesService.saveSortOrder(targetSection, option);
    }

    await super.updateSortOption(
      option,
      section: section ?? currentSection,
      school: school ?? currentSchool,
    );
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