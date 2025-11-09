import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../data/models/comment.dart';
import '../providers/comments_provider.dart';
import 'comment_input_widget.dart';
import 'comment_widget.dart';

class CommentsListWidget extends ConsumerStatefulWidget {
  final String postId;
  final ValueChanged<int>? onCommentCountChanged;

  const CommentsListWidget({
    super.key,
    required this.postId,
    this.onCommentCountChanged,
  });

  @override
  ConsumerState<CommentsListWidget> createState() => _CommentsListWidgetState();
}

class _CommentsListWidgetState extends ConsumerState<CommentsListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _showComposer = false;
  String? _replyToCommentId;
  String? _replyToAuthorNickname;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentsProvider(widget.postId).notifier).loadComments();
    });

    ref.listen<AsyncValue<UserProfile?>>(userProfileProvider, (previous, next) {
      next.whenData((profile) {
        final selectedSchool = ref.read(selectedCommentSchoolProvider);
        final preferredSchool = profile?.school;
        if ((selectedSchool == null || selectedSchool.isEmpty) &&
            preferredSchool != null &&
            preferredSchool.isNotEmpty) {
          ref.read(selectedCommentSchoolProvider.notifier).state = preferredSchool;
        }
      });
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
      ref.read(commentsProvider(widget.postId).notifier).loadMoreComments();
    }
  }

  void _openComposer({String? replyToCommentId, String? replyToAuthor}) {
    setState(() {
      _showComposer = true;
      _replyToCommentId = replyToCommentId;
      _replyToAuthorNickname = replyToAuthor;
    });
  }

  void _closeComposer() {
    setState(() {
      _showComposer = false;
      _replyToCommentId = null;
      _replyToAuthorNickname = null;
    });
  }

  void _handleCommentPosted() {
    widget.onCommentCountChanged?.call(1);
    _closeComposer();
  }

  void _showAuthRequiredMessage() {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please sign in to interact with comments'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final commentsState = ref.watch(commentsProvider(widget.postId));
    final authState = ref.watch(authStateProvider);
    final profileAsync = ref.watch(userProfileProvider);
    final selectedSchool = ref.watch(selectedCommentSchoolProvider);
    final currentUserId = authState.user?.uid;

    return Column(
      children: [
        _buildHeader(
          theme: theme,
          commentCount: commentsState.comments.length,
          isComposerVisible: _showComposer,
          isAuthenticated: currentUserId != null,
          selectedSchool: selectedSchool,
        ),
        if (profileAsync is AsyncError)
          _buildProfileError(theme, profileAsync.error)
        else
          const SizedBox.shrink(),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(commentsProvider(widget.postId).notifier)
                  .loadComments(refresh: true);
            },
            child: _buildCommentsBody(theme, commentsState, currentUserId),
          ),
        ),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          transitionBuilder: (child, animation) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0, 0.1),
              end: Offset.zero,
            ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: slideAnimation,
                child: child,
              ),
            );
          },
          child: _showComposer
              ? CommentInputWidget(
                  key: ValueKey('comment-input-${_replyToCommentId ?? 'new'}'),
                  postId: widget.postId,
                  replyToCommentId: _replyToCommentId,
                  replyToAuthorNickname: _replyToAuthorNickname,
                  onCommentPosted: _handleCommentPosted,
                  onCancelReply: _closeComposer,
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildHeader({
    required ThemeData theme,
    required int commentCount,
    required bool isComposerVisible,
    required bool isAuthenticated,
    required String? selectedSchool,
  }) {
    final label = isComposerVisible ? 'Close' : 'Add Comment';
    final icon = isComposerVisible ? Icons.close : Icons.add_comment;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withOpacity(0.08),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.comment,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 8),
          Text(
            'Comments',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$commentCount',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (selectedSchool != null && selectedSchool.isNotEmpty) ...[
            const SizedBox(width: 8),
            Chip(
              label: Text(selectedSchool),
              visualDensity: VisualDensity.compact,
              side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2)),
            ),
          ],
          const Spacer(),
          TextButton.icon(
            onPressed: () {
              if (!isAuthenticated) {
                _showAuthRequiredMessage();
                return;
              }

              if (isComposerVisible && _replyToCommentId != null) {
                _closeComposer();
              } else if (isComposerVisible && _replyToCommentId == null) {
                _closeComposer();
              } else {
                _openComposer();
              }
            },
            icon: Icon(icon),
            label: Text(label),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileError(ThemeData theme, Object? error) {
    return Container(
      width: double.infinity,
      color: theme.colorScheme.errorContainer.withOpacity(0.2),
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        'Profile data could not be loaded: $error',
        style: theme.textTheme.bodySmall?.copyWith(
          color: theme.colorScheme.error,
        ),
      ),
    );
  }

  Widget _buildCommentsBody(
    ThemeData theme,
    CommentsState commentsState,
    String? currentUserId,
  ) {
    if (commentsState.isLoading && commentsState.comments.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (commentsState.error != null && commentsState.comments.isEmpty) {
      return _buildErrorState(theme, commentsState.error!);
    }

    if (commentsState.comments.isEmpty) {
      return _buildEmptyState(theme);
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(bottom: 16.0),
      itemCount: commentsState.comments.length +
          (commentsState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == commentsState.comments.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        final comment = commentsState.comments[index];
        return TweenAnimationBuilder<double>(
          key: ValueKey(comment.id),
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) => Opacity(
            opacity: value,
            child: Transform.translate(
              offset: Offset(0, (1 - value) * 12),
              child: child,
            ),
          ),
          child: CommentWidget(
            comment: comment,
            currentUserId: currentUserId ?? '',
            onReply: () {
              final nickname = comment.isAnonymous
                  ? 'Anonymous'
                  : comment.authorNickname;
              _openComposer(
                replyToCommentId: comment.id,
                replyToAuthor: nickname,
              );
            },
            onLike: () {
              if (currentUserId == null || currentUserId.isEmpty) {
                _showAuthRequiredMessage();
                return;
              }
              ref.read(commentsProvider(widget.postId).notifier).likeComment(
                    comment.id,
                    currentUserId,
                  );
            },
            onUnlike: () {
              if (currentUserId == null || currentUserId.isEmpty) {
                _showAuthRequiredMessage();
                return;
              }
              ref.read(commentsProvider(widget.postId).notifier).unlikeComment(
                    comment.id,
                    currentUserId,
                  );
            },
            onReport: () => _showReportDialog(comment),
          ),
        );
      },
    );
  }

  Widget _buildErrorState(ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              'Failed to load comments',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref
                    .read(commentsProvider(widget.postId).notifier)
                    .loadComments(refresh: true);
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 12),
            Text(
              'No comments yet',
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Be the first to share your thoughts!',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(Comment comment) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Report Comment'),
          content: const Text(
            'Are you sure you want to report this comment? This will flag it for moderation.',
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
                    content: Text('Comment reported for moderation'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              child: Text(
                'Report',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ],
        );
      },
    );
  }
}
