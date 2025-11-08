import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../comments/data/models/comment.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card_widget.dart';
import '../widgets/skeleton_loader_widget.dart';
import '../widgets/empty_state_widget.dart';

enum FeedSection {
  spotted('spotted', 'Spotted'),
  general('general', 'General');

  const FeedSection(this.value, this.label);
  final String value;
  final String label;
}

class FeedSectionsPage extends ConsumerStatefulWidget {
  const FeedSectionsPage({super.key});

  @override
  ConsumerState<FeedSectionsPage> createState() => _FeedSectionsPageState();
}

class _FeedSectionsPageState extends ConsumerState<FeedSectionsPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  String? _selectedPostId;
  bool _showComments = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: FeedSection.values.length, vsync: this);
    _scrollController.addListener(_onScroll);
    
    // Load initial posts for the default section (spotted)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(feedProvider(FeedSection.spotted.value).notifier).loadPosts(
            refresh: true,
            section: FeedSection.spotted.value,
          );
    });

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        final section = FeedSection.values[_tabController.index];
        ref.read(feedProvider(section.value).notifier).loadPosts(
              refresh: true,
              section: section.value,
            );
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final section = FeedSection.values[_tabController.index];
      ref.read(feedProvider(section.value).notifier).loadMorePosts();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('TeenTalk Feed'),
        bottom: TabBar(
          controller: _tabController,
          tabs: FeedSection.values
              .map((section) => Tab(text: section.label))
              .toList(),
          indicatorColor: theme.colorScheme.primary,
          labelColor: theme.colorScheme.primary,
          unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
        ),
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
          : TabBarView(
              controller: _tabController,
              children: FeedSection.values.map((section) {
                return _buildFeedView(section);
              }).toList(),
            ),
      floatingActionButton: _showComments
          ? null
          : FloatingActionButton(
              onPressed: () => _showCreatePostDialog(
                FeedSection.values[_tabController.index].value,
              ),
              child: const Icon(Icons.add),
            ),
    );
  }

  Widget _buildFeedView(FeedSection section) {
    final postsState = ref.watch(feedProvider(section.value));

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(feedProvider(section.value).notifier).loadPosts(
              refresh: true,
              section: section.value,
            );
      },
      child: postsState.isLoading && postsState.posts.isEmpty
          ? const SkeletonLoader()
          : postsState.error != null
              ? _buildErrorView(postsState.error!, section)
              : postsState.posts.isEmpty
                  ? EmptyStateWidget(section: section)
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
                        return PostCardWidget(
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
                            ref.read(feedProvider(section.value).notifier).likePost(
                                  post.id,
                                  'current_user_id', // TODO: Get from auth
                                );
                          },
                          onUnlike: () {
                            ref.read(feedProvider(section.value).notifier).unlikePost(
                                  post.id,
                                  'current_user_id', // TODO: Get from auth
                                );
                          },
                          onReport: () {
                            _showReportDialog(post, section);
                          },
                        );
                      },
                    ),
    );
  }

  Widget _buildErrorView(String error, FeedSection section) {
    final theme = Theme.of(context);
    return Center(
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
            'Failed to load ${section.label.toLowerCase()} posts',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.error,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.read(feedProvider(section.value).notifier).loadPosts(
                    refresh: true,
                    section: section.value,
                  );
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsView() {
    // TODO: Implement comments view
    return Container(); // Placeholder for now
  }

  void _showCreatePostDialog(String section) {
    final TextEditingController contentController = TextEditingController();
    bool isAnonymous = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
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
                          Text(
                            'Create Post in ${FeedSection.values.firstWhere((s) => s.value == section).label}',
                            style: const TextStyle(
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
                          controller: contentController,
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
                          Switch(
                            value: isAnonymous,
                            onChanged: (value) {
                              setState(() {
                                isAnonymous = value;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (contentController.text.trim().isNotEmpty) {
                              Navigator.of(context).pop();
                              await ref.read(feedProvider(section).notifier).addPost(
                                    authorId: 'current_user_id', // TODO: Get from auth
                                    authorNickname: 'CurrentUser', // TODO: Get from auth
                                    isAnonymous: isAnonymous,
                                    content: contentController.text.trim(),
                                    section: section,
                                  );
                            }
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
      },
    );
  }

  void _showReportDialog(Post post, FeedSection section) {
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