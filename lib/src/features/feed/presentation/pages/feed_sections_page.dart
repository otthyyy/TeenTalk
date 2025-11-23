import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../../profile/presentation/widgets/incomplete_profile_banner.dart';
import '../../../comments/data/models/comment.dart';
import '../../../comments/presentation/widgets/comments_list_widget.dart';
import '../../../notifications/presentation/widgets/notification_badge.dart';
import '../../../../core/providers/image_cache_provider.dart';
import '../../../../core/layout/bottom_nav_metrics.dart';
import '../../../../core/motion/motion_presets.dart';
import '../../../../core/theme/design_tokens.dart';
import '../../../tutorial/presentation/providers/tutorial_provider.dart';
import '../../../tutorial/presentation/widgets/app_tutorial.dart';
import '../providers/feed_provider.dart';
import '../providers/single_post_provider.dart';
import '../widgets/post_card_widget.dart';
import '../widgets/skeleton_loader_widget.dart';
import '../widgets/empty_state_widget.dart';
import '../widgets/segmented_control.dart';
import '../widgets/post_search_delegate.dart';
import '../widgets/feed_filter_chips.dart';
import '../widgets/offline_banner.dart';
import '../widgets/animated_header.dart';
import '../widgets/trending_posts_section.dart';
import '../../domain/models/feed_sort_option.dart';

enum FeedSection {
  spotted('spotted', 'Spotted'),
  general('general', 'General');

  const FeedSection(this.value, this.label);
  final String value;
  final String label;
}

class FeedSectionsPage extends ConsumerStatefulWidget {
  
  const FeedSectionsPage({
    super.key,
    this.openCommentsForPost,
  });
  final String? openCommentsForPost;

  @override
  ConsumerState<FeedSectionsPage> createState() => _FeedSectionsPageState();
}

class _FeedSectionsPageState extends ConsumerState<FeedSectionsPage> {
  late ScrollController _scrollController;
  FeedSection _selectedSection = FeedSection.spotted;
  String? _selectedPostId;
  bool _showComments = false;
  String? _lastHandledDeepLinkPostId;
  bool _isProcessingDeepLink = false;
  late final TutorialAnchors _tutorialAnchors;
  bool _tutorialActive = false;
  int _tutorialCheckAttempts = 0;

  @override
  void initState() {
    super.initState();
    _tutorialAnchors = ref.read(tutorialAnchorsProvider);
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(schoolAwareFeedProvider(_selectedSection.value).notifier)
          .loadPosts(
            refresh: true,
            section: _selectedSection.value,
          );
      
      if (widget.openCommentsForPost != null && 
          _lastHandledDeepLinkPostId != widget.openCommentsForPost) {
        _handleDeepLinkToPost(widget.openCommentsForPost!);
      }
    });
  }
  
  @override
  void didUpdateWidget(covariant FeedSectionsPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.openCommentsForPost != null &&
        widget.openCommentsForPost != oldWidget.openCommentsForPost &&
        widget.openCommentsForPost != _lastHandledDeepLinkPostId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleDeepLinkToPost(widget.openCommentsForPost!);
      });
    }
  }
  
  Future<void> _handleDeepLinkToPost(String postId) async {
    if (_isProcessingDeepLink) return;
    
    setState(() {
      _isProcessingDeepLink = true;
      _lastHandledDeepLinkPostId = postId;

      _checkAndShowTutorial();
    });
    
    try {
      final result = await ref.read(singlePostWithSchoolCheckProvider(postId).future);
      
      if (!mounted) return;
      
      if (result.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error!),
            behavior: SnackBarBehavior.floating,
            action: SnackBarAction(
              label: 'Dismiss',
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
              },
            ),
          ),
        );
        return;
      }
      
      if (result.post != null) {
        setState(() {
          _selectedPostId = postId;
          _showComments = true;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load post: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessingDeepLink = false;
        });
      }
    }
  }

  void _checkAndShowTutorial() {
    if (!mounted || _tutorialActive) return;

    final shouldShowTutorial = ref.read(shouldShowTutorialProvider);
    if (shouldShowTutorial) {
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (!mounted || _tutorialActive) return;
        
        if (_tutorialCheckAttempts < 3 && !_areKeysRendered()) {
          _tutorialCheckAttempts++;
          Future.delayed(const Duration(milliseconds: 500), _checkAndShowTutorial);
          return;
        }
        
        _showTutorial();
      });
    }
  }

  bool _areKeysRendered() {
    return _tutorialAnchors.feedKey.currentContext != null &&
        _tutorialAnchors.createPostKey.currentContext != null &&
        _tutorialAnchors.searchKey.currentContext != null &&
        _tutorialAnchors.messagesNavKey.currentContext != null &&
        _tutorialAnchors.profileNavKey.currentContext != null;
  }

  void _showTutorial() {
    if (!mounted || _tutorialActive) return;
    setState(() => _tutorialActive = true);
    
    final tutorial = AppTutorial(
      context: context,
      targets: TutorialTargets(
        feedKey: _tutorialAnchors.feedKey,
        createPostKey: _tutorialAnchors.createPostKey,
        searchKey: _tutorialAnchors.searchKey,
        messagesNavKey: _tutorialAnchors.messagesNavKey,
        profileNavKey: _tutorialAnchors.profileNavKey,
        safetyKey: _tutorialAnchors.safetyKey,
      ),
      onFinish: () {
        ref.read(tutorialControllerProvider.notifier).markCompleted();
        if (mounted) {
          setState(() => _tutorialActive = false);
        }
      },
      onSkip: () {
        ref.read(tutorialControllerProvider.notifier).markSkipped();
        if (mounted) {
          setState(() => _tutorialActive = false);
        }
      },
    );

    tutorial.show();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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

  void _openSearch(List<Post> posts) {
    showSearch(
      context: context,
      delegate: PostSearchDelegate(posts),
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
              padding: EdgeInsets.only(
                bottom: BottomNavMetrics.fabPadding(margin: 16.0),
              ),
              child: FloatingActionButton.extended(
                key: _tutorialAnchors.createPostKey,
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

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
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
              background: AnimatedHeader(
                userProfile: userProfile,
                sortOption: postsState.sortOption,
              ),
              collapseMode: CollapseMode.parallax,
            ),
            actions: [
              Semantics(
                label: 'Cerca nel feed',
                button: true,
                child: IconButton(
                  key: _tutorialAnchors.searchKey,
                  icon: const Icon(Icons.search),
                  tooltip: 'Cerca',
                  onPressed: () => _openSearch(postsState.posts),
                ),
              ),
              NotificationBadge(
                onTap: () {
                  context.push('/notifications');
                },
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: OfflineBanner(
              lastSyncedAt: postsState.lastSyncedAt,
            ),
          ),
          if (userProfile != null && !userProfile.isProfileComplete)
            SliverToBoxAdapter(
              child: IncompleteProfileBanner(profile: userProfile),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Semantics(
                label: 'Navigazione tra le sezioni del feed',
                child: Container(
                  key: _tutorialAnchors.feedKey,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SegmentedControl<FeedSection>(
                    values: FeedSection.values,
                    selectedValue: _selectedSection,
                    onChanged: _onSectionChanged,
                    labelBuilder: (section) => section.label,
                  ),
                ),
              ),
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
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: _buildSafetyBanner(theme),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: TrendingPostsSection(
                section: _selectedSection.value,
                onPostSelected: (post) {
                  if (authState.user == null) {
                    _showAuthRequiredDialog();
                    return;
                  }
                  setState(() {
                    _selectedPostId = post.id;
                    _showComments = true;
                  });
                },
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
                    ).staggeredListItem(index);
                  },
                  childCount:
                      postsState.posts.length + (postsState.isLoadingMore ? 1 : 0),
                ),
              ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: context.scrollPaddingAboveBottomNav(extra: 36),
            ),
          ),
        ],
      ),
    ),
  );
  }

  Widget _buildSafetyBanner(ThemeData theme) {
    return Semantics(
      container: true,
      label: 'Consiglio di sicurezza',
      child: Container(
        key: _tutorialAnchors.safetyKey,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.primary.withOpacity(0.12),
              theme.colorScheme.secondary.withOpacity(0.12),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: theme.colorScheme.primary.withOpacity(0.2),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.shield_outlined,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sicurezza prima di tutto',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Se noti contenuti che ti fanno sentire a disagio, apri il menu del post '
                    'e seleziona "Segnala". Il nostro team lo esaminerà rapidamente.',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String error, ThemeData theme) {
    return SizedBox(
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
