import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../../comments/data/models/comment.dart';
import '../../../comments/presentation/widgets/comments_list_widget.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';
import '../../../../core/providers/image_cache_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card_widget.dart';
import '../widgets/skeleton_loader_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/segmented_control.dart';
import '../widgets/feed_filter_chips.dart';
import '../../domain/models/feed_sort_option.dart';

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
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _headerAnimationController;
  FeedSection _selectedSection = FeedSection.spotted;
  String? _selectedPostId;
  bool _showComments = false;
  Timer? _trendingTimer;
  int _trendingIndex = 0;
  List<Post> _trendingPosts = [];
  ProviderSubscription<FeedState>? _trendingSubscription;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    _headerAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _trendingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _trendingPosts.length < 2) return;
      setState(() {
        _trendingIndex = (_trendingIndex + 1) % _trendingPosts.length;
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _trendingSubscription = ref.listenManual<FeedState>(
        schoolAwareFeedProvider(FeedSection.spotted.value),
        (previous, next) {
          final sortedPosts = [...next.posts]
            ..sort((a, b) {
              final engagementComparison =
                  b.engagementScore.compareTo(a.engagementScore);
              if (engagementComparison != 0) return engagementComparison;

              final likeComparison = b.likeCount.compareTo(a.likeCount);
              if (likeComparison != 0) return likeComparison;

              return b.createdAt.compareTo(a.createdAt);
            });
          final spotlightCandidates = sortedPosts.take(5).toList();

          if (!mounted) {
            return;
          }

          if (!_trendingListsEqual(_trendingPosts, spotlightCandidates)) {
            setState(() {
              _trendingPosts = spotlightCandidates;
              if (_trendingPosts.isEmpty) {
                _trendingIndex = 0;
              } else {
                _trendingIndex = _trendingIndex % _trendingPosts.length;
              }
            });
          }
        },
        fireImmediately: true,
      );

      ref
          .read(schoolAwareFeedProvider(_selectedSection.value).notifier)
          .loadPosts(
            refresh: true,
            section: _selectedSection.value,
          );
    });
  }

  @override
  void dispose() {
    _trendingTimer?.cancel();
    _trendingSubscription?.close();
    _scrollController.dispose();
    _headerAnimationController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref
          .read(schoolAwareFeedProvider(_selectedSection.value).notifier)
          .loadMorePosts();
    }

    // Prefetch images for upcoming posts
    _prefetchUpcomingImages();
  }

  void _prefetchUpcomingImages() {
    final postsState = ref.read(schoolAwareFeedProvider(_selectedSection.value));
    if (postsState.posts.isEmpty) return;

    final scrollOffset = _scrollController.offset;
    const averagePostHeight = 400.0; // Approximate height of a post card
    var currentIndex = (scrollOffset / averagePostHeight).floor();
    if (currentIndex < 0) currentIndex = 0;
    if (currentIndex >= postsState.posts.length) {
      currentIndex = postsState.posts.length - 1;
    }

    final prefetchService = ref.read(imagePrefetchServiceProvider);
    prefetchService.prefetchPostImages(
      posts: postsState.posts,
      currentIndex: currentIndex,
      lookAhead: 5,
    );
  }

  void _prefetchInitialImages(List<Post> posts) {
    if (posts.isEmpty) return;
    final prefetchService = ref.read(imagePrefetchServiceProvider);
    prefetchService.batchPrefetch(posts.take(6).toList());
  }

  void _prefetchAroundIndex(int index, List<Post> posts) {
    if (posts.isEmpty) return;
    final prefetchService = ref.read(imagePrefetchServiceProvider);
    prefetchService.prefetchPostImages(
      posts: posts,
      currentIndex: index,
      lookAhead: 3,
    );
  }

  void _resetPrefetchTracking() {
    ref.read(imagePrefetchServiceProvider).clearPrefetchTracking();
  }

  bool _trendingListsEqual(List<Post> a, List<Post> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  void _onSectionChanged(FeedSection section) {
    setState(() {
      _selectedSection = section;
    });
    _resetPrefetchTracking();
    ref.read(schoolAwareFeedProvider(section.value).notifier).loadPosts(
          refresh: true,
          section: section.value,
        );
  }

  void _onSortOptionSelected(FeedSortOption option) {
    _resetPrefetchTracking();
    final notifier =
        ref.read(schoolAwareFeedProvider(_selectedSection.value).notifier);
    unawaited(
      notifier.updateSortOption(
        option,
        section: _selectedSection.value,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final provider = schoolAwareFeedProvider(_selectedSection.value);
    final fabBottomPadding = MediaQuery.of(context).padding.bottom + 16;

    ref.listen<FeedState>(provider, (previous, next) {
      if (next.error != null && next.error!.isNotEmpty && previous?.error != next.error) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(next.error!),
              behavior: SnackBarBehavior.floating,
            ),
          );
        ref.read(provider.notifier).clearError();
      }
    });

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _showComments && _selectedPostId != null
            ? _buildCommentsView()
            : _buildFeedView(theme),
      ),
      floatingActionButton: _showComments
          ? null
          : Padding(
              padding: EdgeInsets.only(bottom: fabBottomPadding),
              child: FloatingActionButton.extended(
                onPressed: _showCreatePostDialog,
                icon: const Icon(Icons.add),
                label: const Text('Post'),
              ),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFeedView(ThemeData theme) {
    final postsState = ref.watch(schoolAwareFeedProvider(_selectedSection.value));
    final authState = ref.watch(authStateProvider);
    final userProfile = ref.watch(userProfileProvider).value;
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(schoolAwareFeedProvider(_selectedSection.value).notifier)
            .loadPosts(
              refresh: true,
              section: _selectedSection.value,
            );
      },
      child: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            stretch: true,
            automaticallyImplyLeading: false,
            backgroundColor: theme.colorScheme.surface,
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroHeader(
                theme,
                userProfile,
                postsState.sortOption,
              ),
              collapseMode: CollapseMode.parallax,
            ),
            actions: [
              NotificationBadge(
                onTap: () {
                  context.push('/notifications');
                },
              ),
            ],
      child: Semantics(
        container: true,
        explicitChildNodes: true,
        label: '${_selectedSection.label} feed posts list',
        child: CustomScrollView(
          controller: _scrollController,
          physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          slivers: [
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              stretch: true,
              automaticallyImplyLeading: false,
              backgroundColor: theme.colorScheme.surface,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeroHeader(theme, userProfile),
                collapseMode: CollapseMode.parallax,
              ),
              actions: [
                NotificationBadge(
                  onTap: () {
                    context.push('/notifications');
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sort by',
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FeedFilterChips(
                    selectedOption: postsState.sortOption,
                    onOptionSelected: _onSortOptionSelected,
                  ),
                ],
              ),
            ),
          ),
          if (postsState.isLoading && postsState.posts.isEmpty)
            const SliverToBoxAdapter(
              child: SkeletonLoader(),
            )
          else if (postsState.error != null)
            SliverToBoxAdapter(
              child: _buildErrorView(postsState.error!, theme),
            )
          else if (postsState.posts.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: SegmentedControl<FeedSection>(
                  values: FeedSection.values,
                  selectedValue: _selectedSection,
                  onChanged: _onSectionChanged,
                  labelBuilder: (section) => section.label,
                ),
              ),
            ),
            if (postsState.isLoading && postsState.posts.isEmpty)
              const SliverToBoxAdapter(
                child: SkeletonLoader(),
              )
            else if (postsState.error != null)
              SliverToBoxAdapter(
                child: _buildErrorView(postsState.error!, theme),
              )
            else if (postsState.posts.isEmpty)
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 400,
                  child: EmptyStateWidget(section: _selectedSection),
                ),
              )
            else
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index == postsState.posts.length) {
                      return postsState.isLoadingMore
                          ? const Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Center(
                                child: CircularProgressIndicator(),
                              ),
                            )
                          : const SizedBox.shrink();
                    }

                    final post = postsState.posts[index];
                    final isNew =
                        DateTime.now().difference(post.createdAt).inMinutes < 5;

                    return PostCardWidget(
                      key: ValueKey(post.id),
                      post: post,
                      currentUserId: authState.user?.uid,
                      isNew: isNew,
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
                        ref
                            .read(schoolAwareFeedProvider(_selectedSection.value)
                                .notifier)
                            .likePost(
                              post.id,
                              authState.user!.uid,
                            );
                      },
                      onUnlike: () {
                        if (authState.user == null) {
                          _showAuthRequiredDialog();
                          return;
                        }
                        ref
                            .read(schoolAwareFeedProvider(_selectedSection.value)
                                .notifier)
                            .unlikePost(
                              post.id,
                              authState.user!.uid,
                            );
                      },
                      onReport: () {
                        _showReportDialog(post);
                      },
                    );
                  },
                  childCount:
                      postsState.posts.length + (postsState.isLoadingMore ? 1 : 0),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: 120 + bottomInset),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader(
    ThemeData theme,
    UserProfile? userProfile,
    FeedSortOption sortOption,
  ) {
    return AnimatedBuilder(
      animation: _headerAnimationController,
      builder: (context, child) {
        IconData badgeIcon;
        String badgeText;

        switch (sortOption) {
          case FeedSortOption.newest:
            badgeIcon = Icons.access_time;
            badgeText = 'Latest';
            break;
          case FeedSortOption.mostLiked:
            badgeIcon = Icons.favorite;
            badgeText = 'Most Liked';
            break;
          case FeedSortOption.trending:
            badgeIcon = Icons.trending_up;
            badgeText = 'Trending Now';
            break;
        }

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                theme.colorScheme.tertiary,
              ],
              stops: [
                0.0,
                _headerAnimationController.value,
                1.0,
              ],
            ),
          ),
          child: Stack(
            children: [
              Positioned(
                top: 100 + (_headerAnimationController.value * 20),
                right: 30 - (_headerAnimationController.value * 30),
                child: Opacity(
                  opacity: 0.1,
                  child: Icon(
                    Icons.visibility,
                    size: 120,
                    color: Colors.white,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '👀 Spotted',
                        style: theme.textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Share what you\'ve spotted around campus',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                      if (userProfile?.school != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.school,
                                size: 16,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                userProfile!.school ?? '',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  badgeIcon,
                                  size: 16,
                                  color: theme.colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  badgeText,
                                  style: theme.textTheme.labelMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildErrorView(String error, ThemeData theme) {
    return Container(
      height: 400,
      child: Center(
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
              'Failed to load ${_selectedSection.label.toLowerCase()} posts',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Text(
                error,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(schoolAwareFeedProvider(_selectedSection.value).notifier)
                    .loadPosts(
                      refresh: true,
                      section: _selectedSection.value,
                    );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentsView() {
    final authState = ref.watch(authStateProvider);
    final userProfile = ref.watch(userProfileProvider).value;

    if (authState.user == null || userProfile == null) {
      return _buildAuthRequiredView();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            setState(() {
              _showComments = false;
              _selectedPostId = null;
            });
          },
        ),
      ),
      body: CommentsListWidget(
        postId: _selectedPostId!,
      ),
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

  void _showCreatePostDialog() {
    final authState = ref.read(authStateProvider);
    final userProfile = ref.read(userProfileProvider).value;

    if (authState.user == null) {
      _showAuthRequiredDialog();
      return;
    }

    if (userProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your profile first'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    context.push('/feed/compose').then((result) {
      if (result == true && mounted) {
        ref
            .read(schoolAwareFeedProvider(_selectedSection.value).notifier)
            .loadPosts(
              refresh: true,
              section: _selectedSection.value,
            );
      }
    });
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Post reported for moderation'),
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
