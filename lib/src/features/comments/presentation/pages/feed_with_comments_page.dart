import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/comment.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';
import '../../../../core/layout/bottom_nav_metrics.dart';
import '../providers/comments_provider.dart';
import '../widgets/post_widget.dart';
import '../widgets/comments_list_widget.dart';
import '../widgets/comment_input_widget.dart';

class FeedWithCommentsPage extends ConsumerStatefulWidget {
  const FeedWithCommentsPage({super.key});

  @override
  ConsumerState<FeedWithCommentsPage> createState() => _FeedWithCommentsPageState();
}

class _FeedWithCommentsPageState extends ConsumerState<FeedWithCommentsPage> {
  final ScrollController _scrollController = ScrollController();
  String? _selectedPostId;
  bool _showComments = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(postsProvider.notifier).loadPosts();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(postsProvider.notifier).loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final postsState = ref.watch(postsProvider);
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TeenTalk Feed'),
        actions: [
          NotificationBadge(
            onTap: () {
              context.push('/notifications');
            },
          ),
        ],
      ),
      body: _showComments && _selectedPostId != null
          ? _buildCommentsView()
          : _buildFeedView(postsState, theme, authState),
      floatingActionButton: _showComments
          ? null
          : Padding(
              padding: EdgeInsets.only(
                bottom: BottomNavMetrics.fabPadding(margin: 16.0),
              ),
              child: FloatingActionButton(
                onPressed: _navigateToPostComposer,
                child: const Icon(Icons.add),
              ),
            ),
    );
  }

  Widget _buildFeedView(PostsState postsState, ThemeData theme, dynamic authState) {
    final currentUserId = authState.user?.uid ?? '';
    
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(postsProvider.notifier).loadPosts(refresh: true);
      },
      child: postsState.isLoading && postsState.posts.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : postsState.error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: theme.colorScheme.error,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Failed to load posts',
                        style: theme.textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        postsState.error!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          ref.read(postsProvider.notifier).loadPosts();
                        },
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : postsState.posts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.feed_outlined,
                            size: 48,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No posts yet',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Be the first to share something!',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                     controller: _scrollController,
                     padding: EdgeInsets.only(
                       bottom: BottomNavMetrics.scrollBottomPadding(context, extra: 16),
                     ),
                     itemCount: postsState.posts.length + (postsState.isLoadingMore ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == postsState.posts.length) {
                          return const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final post = postsState.posts[index];
                        return PostWidget(
                          key: ValueKey(post.id),
                          post: post,
                          currentUserId: currentUserId,
                          onComments: () {
                            if (authState.user == null) {
                              _showAuthRequiredDialog();
                              return;
                            }
                            setState(() {
                              _selectedPostId = post.id;
                              _showComments = true;
                            });
                          },
                          onLike: () {
                            if (authState.user == null) {
                              _showAuthRequiredDialog();
                              return;
                            }
                            ref.read(postsProvider.notifier).likePost(
                                  post.id,
                                  authState.user!.uid,
                                );
                          },
                          onUnlike: () {
                            if (authState.user == null) {
                              _showAuthRequiredDialog();
                              return;
                            }
                            ref.read(postsProvider.notifier).unlikePost(
                                  post.id,
                                  authState.user!.uid,
                                );
                          },
                          onReport: () {
                            _showReportDialog(post);
                          },
                        );
                      },
                    ),
    );
  }

  Widget _buildCommentsView() {
    final authState = ref.watch(authStateProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    
    if (authState.user == null || userProfile == null) {
      return _buildAuthRequiredView();
    }
    
    return CommentsListWidget(
      postId: _selectedPostId!,
      currentUserId: authState.user!.uid,
      currentUserNickname: userProfile.nickname,
      currentUserIsAnonymous: false,
    );
  }
  
  Widget _buildAuthRequiredView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.lock_outlined,
            size: 64,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Sign in required',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Please sign in to view comments',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _showComments = false;
                _selectedPostId = null;
              });
            },
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }
  
  void _showAuthRequiredDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(
                Icons.lock_outlined,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 8),
              const Text('Sign In Required'),
            ],
          ),
          content: const Text(
            'You need to sign in to interact with posts and comments. Sign in to like posts, comment, and create your own content!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Sign In'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _navigateToPostComposer() async {
    final result = await context.push<bool>('/feed/compose');
    
    // Refresh posts if user successfully created a post
    if (result == true && mounted) {
      ref.read(postsProvider.notifier).loadPosts(refresh: true);
    }
  }

  void _showReportDialog(Post post) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Post'),
          content: const Text(
            'Are you sure you want to report this post? This will flag it for moderation.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // TODO: Implement post reporting
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post reported'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Report',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}