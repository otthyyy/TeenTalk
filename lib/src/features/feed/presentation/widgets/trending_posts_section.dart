import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../comments/data/models/comment.dart';
import '../providers/feed_provider.dart';

class TrendingPostsSection extends ConsumerStatefulWidget {
  const TrendingPostsSection({
    super.key,
    required this.section,
    this.onPostSelected,
  });

  final String section;
  final ValueChanged<Post>? onPostSelected;

  @override
  ConsumerState<TrendingPostsSection> createState() => _TrendingPostsSectionState();
}

class _TrendingPostsSectionState extends ConsumerState<TrendingPostsSection> {
  Timer? _trendingTimer;
  Timer? _trendingDebounce;
  int _trendingIndex = 0;
  List<Post> _trendingPosts = [];
  ProviderSubscription<FeedState>? _trendingSubscription;
  String? _error;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _startAutoRotate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _subscribeToSection(widget.section);
    });
  }

  @override
  void didUpdateWidget(covariant TrendingPostsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.section != oldWidget.section) {
      _subscribeToSection(widget.section);
    }
  }

  @override
  void dispose() {
    _trendingTimer?.cancel();
    _trendingDebounce?.cancel();
    _trendingSubscription?.close();
    super.dispose();
  }

  void _startAutoRotate() {
    _trendingTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!mounted || _trendingPosts.length < 2) return;
      setState(() {
        _trendingIndex = (_trendingIndex + 1) % _trendingPosts.length;
      });
    });
  }

  void _subscribeToSection(String section) {
    _trendingSubscription?.close();
    _trendingDebounce?.cancel();

    setState(() {
      _trendingPosts = [];
      _trendingIndex = 0;
      _error = null;
      _isLoading = true;
    });

    final provider = schoolAwareFeedProvider(section);

    _trendingSubscription = ref.listenManual<FeedState>(
      provider,
      (previous, next) {
        _trendingDebounce?.cancel();
        _trendingDebounce = Timer(const Duration(milliseconds: 500), () {
          if (!mounted) return;

          final spotlightCandidates = _extractTrendingCandidates(next.posts);

          setState(() {
            _isLoading = next.isLoading && spotlightCandidates.isEmpty;
            _error = next.error;
          });

          if (!_trendingListsEqual(_trendingPosts, spotlightCandidates)) {
            setState(() {
              _trendingPosts = spotlightCandidates;
              _trendingIndex = _trendingPosts.isEmpty
                  ? 0
                  : _trendingIndex % _trendingPosts.length;
            });
          }
        });
      },
      fireImmediately: true,
    );
  }

  List<Post> _extractTrendingCandidates(List<Post> posts) {
    final sortedPosts = [...posts]
      ..sort((a, b) {
        final engagementComparison =
            b.engagementScore.compareTo(a.engagementScore);
        if (engagementComparison != 0) return engagementComparison;

        final likeComparison = b.likeCount.compareTo(a.likeCount);
        if (likeComparison != 0) return likeComparison;

        return b.createdAt.compareTo(a.createdAt);
      });

    return sortedPosts.take(5).toList();
  }

  bool _trendingListsEqual(List<Post> a, List<Post> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Trending posts section',
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.trending_up,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Trending now',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                IconButton(
                  tooltip: 'Refresh trending posts',
                  onPressed: () {
                    ref.read(schoolAwareFeedProvider(widget.section).notifier)
                      ..loadPosts(
                        refresh: true,
                        section: widget.section,
                      );
                  },
                  icon: const Icon(Icons.refresh),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(
                      theme.colorScheme.primary,
                    ),
                  ),
                ),
              )
            else if (_error != null && _trendingPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  _error!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              )
            else if (_trendingPosts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'No trending posts yet. Check back soon!',
                  style: theme.textTheme.bodyMedium,
                ),
              )
            else
              _TrendingPostCard(
                post: _trendingPosts[_trendingIndex],
                onTap: widget.onPostSelected,
              ),
          ],
        ),
      ),
    );
  }
}

class _TrendingPostCard extends StatelessWidget {
  const _TrendingPostCard({
    required this.post,
    this.onTap,
  });

  final Post post;
  final ValueChanged<Post>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: GestureDetector(
        key: ValueKey(post.id),
        onTap: () => onTap?.call(post),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    child: Text(
                      post.authorNickname.substring(0, 1).toUpperCase(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      post.authorNickname,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 4),
                        Text('${post.likeCount}'),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                post.content,
                style: theme.textTheme.bodyLarge,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 4),
                  Text('${post.commentCount} comments'),
                  const Spacer(),
                  TextButton(
                    onPressed: () => onTap?.call(post),
                    child: const Text('View Post'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
