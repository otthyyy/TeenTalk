import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../common/widgets/trust_badge.dart';
import '../../../../core/services/analytics_provider.dart';
import '../../../comments/data/models/comment.dart';
import '../../../comments/data/repositories/posts_repository.dart';
import '../../../comments/presentation/providers/comments_provider.dart';
import '../../../feed/presentation/widgets/post_card_widget.dart';
import '../../../messages/data/repositories/direct_messages_repository.dart';
import '../../../messages/presentation/providers/direct_messages_provider.dart' as dm_provider;
import '../../domain/models/trust_level_localizations.dart';

final userPostsProvider = StateNotifierProvider.family<UserPostsNotifier, UserPostsState, String>(
  (ref, userId) => UserPostsNotifier(ref, userId),
);

class UserPostsState {

  const UserPostsState({
    this.posts = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.lastDocument,
    this.hasMore = true,
  });
  final List<Post> posts;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  UserPostsState copyWith({
    List<Post>? posts,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    bool clearError = false,
    DocumentSnapshot? lastDocument,
    bool clearLastDocument = false,
    bool? hasMore,
  }) {
    return UserPostsState(
      posts: posts ?? this.posts,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      lastDocument: clearLastDocument ? null : (lastDocument ?? this.lastDocument),
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class UserPostsNotifier extends StateNotifier<UserPostsState> {

  UserPostsNotifier(this.ref, this.userId) : super(const UserPostsState());
  final Ref ref;
  final String userId;

  Future<void> loadPosts({bool refresh = false}) async {
    if (refresh) {
      state = const UserPostsState(isLoading: true);
    } else if (state.isLoadingMore || !state.hasMore) {
      return;
    } else {
      state = state.copyWith(isLoadingMore: true);
    }

    try {
      final postsRepository = ref.read(postsRepositoryProvider);
      final currentUserProfile = ref.read(userProfileProvider).value;
      final school = currentUserProfile?.school;

      final (posts, lastDoc) = await postsRepository.getPostsByAuthor(
        authorId: userId,
        school: school,
        lastDocument: refresh ? null : state.lastDocument,
        limit: 20,
      );

      if (refresh) {
        state = UserPostsState(
          posts: posts,
          lastDocument: lastDoc,
          hasMore: posts.length >= 20,
        );
      } else {
        state = UserPostsState(
          posts: [...state.posts, ...posts],
          lastDocument: lastDoc,
          hasMore: posts.length >= 20,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: e.toString(),
      );
    }
  }
}

final blockedStatusProvider = FutureProvider.family<({bool isBlocked, bool hasBlocked}), String>(
  (ref, otherUserId) async {
    final currentUserId = ref.watch(authStateProvider).user?.uid;
    if (currentUserId == null) {
      return (isBlocked: false, hasBlocked: false);
    }

    final repository = ref.read(directMessagesRepositoryProvider);
    final isBlocked = await repository.isUserBlocked(otherUserId, currentUserId);
    final hasBlocked = await repository.isUserBlocked(currentUserId, otherUserId);

    return (isBlocked: isBlocked, hasBlocked: hasBlocked);
  },
);

class PublicProfilePage extends ConsumerStatefulWidget {

  const PublicProfilePage({
    super.key,
    required this.userId,
  });
  final String userId;

  @override
  ConsumerState<PublicProfilePage> createState() => _PublicProfilePageState();
}

class _PublicProfilePageState extends ConsumerState<PublicProfilePage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(userPostsProvider(widget.userId).notifier).loadPosts(refresh: true);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      ref.read(userPostsProvider(widget.userId).notifier).loadPosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProfileAsync = ref.watch(userProfileByIdProvider(widget.userId));
    final blockedStatusAsync = ref.watch(blockedStatusProvider(widget.userId));
    final currentUserId = ref.watch(authStateProvider).user?.uid;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
      ),
      body: userProfileAsync.when(
        data: (userProfile) {
          if (userProfile == null) {
            return _buildErrorState(
              context,
              'User not found',
              Icons.person_off_outlined,
            );
          }

          return blockedStatusAsync.when(
            data: (blockedStatus) {
              if (blockedStatus.isBlocked) {
                return _buildBlockedState(
                  context,
                  'This user has blocked you',
                  'You cannot view their profile.',
                );
              }

              if (blockedStatus.hasBlocked) {
                return _buildBlockedState(
                  context,
                  'You have blocked this user',
                  'Unblock them to view their profile.',
                );
              }

              return _buildProfileContent(context, userProfile, currentUserId);
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => _buildErrorState(
              context,
              'Error checking block status',
              Icons.error_outline,
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => _buildErrorState(
          context,
          'Error loading profile',
          Icons.error_outline,
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message, IconData icon) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: theme.colorScheme.error.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text(
              message,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlockedState(BuildContext context, String title, String subtitle) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.block,
              size: 64,
              color: theme.colorScheme.error.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileContent(
    BuildContext context,
    UserProfile userProfile,
    String? currentUserId,
  ) {
    final theme = Theme.of(context);
    final userPostsState = ref.watch(userPostsProvider(widget.userId));

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(userPostsProvider(widget.userId).notifier).loadPosts(refresh: true);
      },
      child: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverToBoxAdapter(
            child: _buildHeader(context, userProfile),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: _buildActionButtons(context, userProfile),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Posts',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (userPostsState.isLoading)
            const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator()),
            )
          else if (userPostsState.error != null)
            SliverFillRemaining(
              child: Center(
                child: Text(
                  'Error: ${userPostsState.error}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ),
            )
          else if (userPostsState.posts.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.post_add_outlined,
                        size: 64,
                        color: theme.colorScheme.primary.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No posts yet',
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'This user hasn\'t posted anything yet.',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index < userPostsState.posts.length) {
                    final post = userPostsState.posts[index];
                    return PostCardWidget(
                      key: ValueKey(post.id),
                      post: post,
                      currentUserId: currentUserId,
                      onComments: () {
                        // Navigate to comments
                      },
                      onLike: () async {
                        final postsRepository = ref.read(postsRepositoryProvider);
                        if (currentUserId != null) {
                          await postsRepository.likePost(post.id, currentUserId);
                        }
                      },
                      onUnlike: () async {
                        final postsRepository = ref.read(postsRepositoryProvider);
                        if (currentUserId != null) {
                          await postsRepository.unlikePost(post.id, currentUserId);
                        }
                      },
                      onReport: () {
                        _showReportDialog(context, post.id);
                      },
                    );
                  } else if (userPostsState.isLoadingMore) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  return null;
                },
                childCount: userPostsState.posts.length + (userPostsState.isLoadingMore ? 1 : 0),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserProfile userProfile) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary.withOpacity(0.1),
            theme.colorScheme.secondary.withOpacity(0.05),
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.transparent,
                  child: Text(
                    userProfile.nickname.isNotEmpty
                        ? userProfile.nickname[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    userProfile.nickname,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  TrustBadge(
                    trustLevel: userProfile.trustLevel,
                    showLabel: false,
                    size: 20,
                    onTap: () {
                      ref.read(analyticsServiceProvider).logTrustBadgeTap(
                            userProfile.trustLevel.name,
                            'public_profile',
                          );
                    },
                  ),
                ],
              ),
              if (userProfile.school != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 16,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      userProfile.school!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ],
              if (userProfile.schoolYear != null) ...[
                const SizedBox(height: 4),
                Text(
                  'Year ${userProfile.schoolYear}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, UserProfile userProfile) {
    final theme = Theme.of(context);
    final currentUserId = ref.watch(authStateProvider).user?.uid;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _handleMessage(context, userProfile, currentUserId),
            icon: const Icon(Icons.message_outlined),
            label: const Text('Message'),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () => _handleBlock(context, userProfile, currentUserId),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
          child: const Icon(Icons.block),
        ),
        const SizedBox(width: 8),
        OutlinedButton(
          onPressed: () => _handleReport(context, userProfile),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
          child: const Icon(Icons.flag_outlined),
        ),
      ],
    );
  }

  void _handleMessage(BuildContext context, UserProfile userProfile, String? currentUserId) {
    if (currentUserId == null) return;

    final conversationId = _generateConversationId(currentUserId, widget.userId);
    context.push(
      '/messages/chat/$conversationId/${widget.userId}?displayName=${Uri.encodeComponent(userProfile.nickname)}',
    );
  }

  String _generateConversationId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  void _handleBlock(BuildContext context, UserProfile userProfile, String? currentUserId) {
    if (currentUserId == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.block, size: 48),
        title: const Text('Block User'),
        content: Text(
          'Are you sure you want to block ${userProfile.nickname}? You will no longer see their posts or messages.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(directMessagesRepositoryProvider).blockUser(
                    currentUserId,
                    widget.userId,
                  );
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('${userProfile.nickname} has been blocked')),
                );
                context.pop();
              }
            },
            child: const Text('Block'),
          ),
        ],
      ),
    );
  }

  void _handleReport(BuildContext context, UserProfile userProfile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.flag_outlined, size: 48),
        title: const Text('Report User'),
        content: Text(
          'Are you sure you want to report ${userProfile.nickname}? This will be reviewed by moderators.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User reported to moderators')),
              );
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog(BuildContext context, String postId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Post'),
        content: const Text('Are you sure you want to report this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final postsRepository = ref.read(postsRepositoryProvider);
              await postsRepository.reportPost(postId, 'Inappropriate content');
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post reported')),
                );
              }
            },
            child: const Text('Report'),
          ),
        ],
      ),
    );
  }
}
