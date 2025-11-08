import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/comment.dart';
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
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TeenTalk Feed'),
        actions: [
          IconButton(
            onPressed: () {
              // Show notifications
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: _showComments && _selectedPostId != null
          ? _buildCommentsView()
          : _buildFeedView(postsState, theme),
      floatingActionButton: _showComments
          ? null
          : FloatingActionButton(
              onPressed: _showCreatePostDialog,
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildFeedView(PostsState postsState, ThemeData theme) {
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
                      padding: const EdgeInsets.only(bottom: 80.0),
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
                          currentUserId: 'current_user_id', // TODO: Get from auth
                          onComments: () {
                            setState(() {
                              _selectedPostId = post.id;
                              _showComments = true;
                            });
                          },
                          onLike: () {
                            ref.read(postsProvider.notifier).likePost(
                                  post.id,
                                  'current_user_id', // TODO: Get from auth
                                );
                          },
                          onUnlike: () {
                            ref.read(postsProvider.notifier).unlikePost(
                                  post.id,
                                  'current_user_id', // TODO: Get from auth
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
    return CommentsListWidget(
      postId: _selectedPostId!,
      currentUserId: 'current_user_id', // TODO: Get from auth
      currentUserNickname: 'CurrentUser', // TODO: Get from auth
      currentUserIsAnonymous: false, // TODO: Get from auth
    );
  }

  void _showCreatePostDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Create Post',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.close),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TextField(
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'What\'s on your mind?',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Post anonymously'),
                      const Spacer(),
                      Switch(value: false, onChanged: (value) {}),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // TODO: Implement post creation
                      },
                      child: const Text('Post'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
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