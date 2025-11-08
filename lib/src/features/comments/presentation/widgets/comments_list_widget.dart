import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/comment.dart';
import '../providers/comments_provider.dart';
import 'comment_widget.dart';
import 'comment_input_widget.dart';

class CommentsListWidget extends ConsumerStatefulWidget {
  final String postId;
  final String currentUserId;
  final String currentUserNickname;
  final bool currentUserIsAnonymous;

  const CommentsListWidget({
    super.key,
    required this.postId,
    required this.currentUserId,
    required this.currentUserNickname,
    required this.currentUserIsAnonymous,
  });

  @override
  ConsumerState<CommentsListWidget> createState() => _CommentsListWidgetState();
}

class _CommentsListWidgetState extends ConsumerState<CommentsListWidget> {
  final ScrollController _scrollController = ScrollController();
  bool _showInput = false;
  String? _replyToCommentId;
  String? _replyToAuthorNickname;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentsProvider(widget.postId).notifier).loadComments();
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

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsProvider(widget.postId));
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16.0),
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
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _showInput = !_showInput;
                    _replyToCommentId = null;
                    _replyToAuthorNickname = null;
                  });
                },
                icon: Icon(
                  _showInput ? Icons.close : Icons.add_comment,
                ),
                label: Text(_showInput ? 'Cancel' : 'Add Comment'),
              ),
            ],
          ),
        ),
        if (_showInput)
          CommentInputWidget(
            postId: widget.postId,
            currentUserId: widget.currentUserId,
            currentUserNickname: widget.currentUserNickname,
            currentUserIsAnonymous: widget.currentUserIsAnonymous,
            onCommentPosted: () {
              setState(() {
                _showInput = false;
                _replyToCommentId = null;
                _replyToAuthorNickname = null;
              });
            },
          ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(commentsProvider(widget.postId).notifier).loadComments(refresh: true);
            },
            child: commentsState.isLoading && commentsState.comments.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : commentsState.error != null
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
                              'Failed to load comments',
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              commentsState.error!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                ref.read(commentsProvider(widget.postId).notifier).loadComments();
                              },
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      )
                    : commentsState.comments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 48,
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No comments yet',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Be the first to share your thoughts!',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.only(bottom: 16.0),
                            itemCount: commentsState.comments.length + (commentsState.isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == commentsState.comments.length) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Center(
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }

                              final comment = commentsState.comments[index];
                              return CommentWidget(
                                key: ValueKey(comment.id),
                                comment: comment,
                                currentUserId: widget.currentUserId,
                                onReply: () {
                                  setState(() {
                                    _showInput = true;
                                    _replyToCommentId = comment.id;
                                    _replyToAuthorNickname = comment.isAnonymous
                                        ? 'Anonymous'
                                        : comment.authorNickname;
                                  });
                                },
                                onLike: () {
                                  ref.read(commentsProvider(widget.postId).notifier).likeComment(
                                        comment.id,
                                        widget.currentUserId,
                                      );
                                },
                                onUnlike: () {
                                  ref.read(commentsProvider(widget.postId).notifier).unlikeComment(
                                        comment.id,
                                        widget.currentUserId,
                                      );
                                },
                                onReport: () {
                                  _showReportDialog(comment);
                                },
                              );
                            },
                          ),
          ),
        ),
        if (_replyToCommentId != null && _showInput)
          CommentInputWidget(
            postId: widget.postId,
            currentUserId: widget.currentUserId,
            currentUserNickname: widget.currentUserNickname,
            currentUserIsAnonymous: widget.currentUserIsAnonymous,
            replyToCommentId: _replyToCommentId,
            replyToAuthorNickname: _replyToAuthorNickname,
            onCommentPosted: () {
              setState(() {
                _showInput = false;
                _replyToCommentId = null;
                _replyToAuthorNickname = null;
              });
            },
          ),
      ],
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
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  // In a real implementation, this would call a report method
                  // For now, we'll just show a success message
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Comment reported for moderation'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to report comment: $e'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
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