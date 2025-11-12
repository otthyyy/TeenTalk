import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../data/models/comment.dart';
import '../providers/comments_provider.dart';
import '../../../friends/presentation/providers/friends_provider.dart';
import '../../../friends/data/models/friendship_status.dart';
import '../../../friends/data/repositories/friends_repository.dart';

class PostWidget extends ConsumerWidget {
  final Post post;
  final String currentUserId;
  final VoidCallback? onComments;
  final VoidCallback? onLike;
  final VoidCallback? onUnlike;
  final VoidCallback? onReport;

  const PostWidget({
    super.key,
    required this.post,
    required this.currentUserId,
    this.onComments,
    this.onLike,
    this.onUnlike,
    this.onReport,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLiked = post.likedBy.contains(currentUserId);
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: theme.colorScheme.primary,
                  child: post.isAnonymous
                      ? Icon(
                          Icons.person_off,
                          size: 24,
                          color: theme.colorScheme.onPrimary,
                        )
                      : Text(
                          post.authorNickname.isNotEmpty
                              ? post.authorNickname[0].toUpperCase()
                              : 'A',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            post.isAnonymous ? 'Anonymous' : post.authorNickname,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              post.section,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _formatTimestamp(post.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!post.isAnonymous && post.authorId != currentUserId)
                  _buildFriendActionButton(context, ref),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'report':
                        onReport?.call();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'report',
                      child: Row(
                        children: [
                          Icon(Icons.flag, size: 16),
                          SizedBox(width: 8),
                          Text('Report'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              post.content,
              style: theme.textTheme.bodyLarge,
            ),
            if (post.imageUrl != null) ...[
              const SizedBox(height: 12),
              CachedImageWidget(
                imageUrl: post.imageUrl!,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(12),
              ),
            ],
            if (post.mentionedUserIds.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 4,
                children: post.mentionedUserIds.map((userId) {
                  return Chip(
                    label: Text('@$userId'),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: theme.colorScheme.onPrimaryContainer,
                      fontSize: 12,
                    ),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                InkWell(
                  onTap: isLiked ? onUnlike : onLike,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: isLiked ? theme.colorScheme.error : theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.likeCount.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: onComments,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.comment_outlined,
                          size: 20,
                          color: theme.colorScheme.onSurface,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          post.commentCount.toString(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () {
                    // Share functionality
                  },
                  icon: Icon(
                    Icons.share_outlined,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendActionButton(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    if (currentUserId.isEmpty) {
      return IconButton(
        icon: Icon(
          Icons.person_add_alt_1,
          size: 20,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        tooltip: 'Sign in to add friends',
        onPressed: () => _showAuthPrompt(context),
      );
    }

    final friendshipStatusAsync = ref.watch(friendshipStatusProvider(post.authorId));

    return friendshipStatusAsync.when(
      data: (status) {
        switch (status) {
          case FriendshipStatus.none:
            return IconButton(
              icon: Icon(
                Icons.person_add_alt,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              tooltip: 'Send friend request',
              onPressed: () => _handleSendFriendRequest(context, ref),
            );
          case FriendshipStatus.pendingSent:
            return IconButton(
              icon: Icon(
                Icons.hourglass_top_rounded,
                size: 20,
                color: theme.colorScheme.secondary,
              ),
              tooltip: 'Cancel friend request',
              onPressed: () => _handleCancelFriendRequest(context, ref),
            );
          case FriendshipStatus.pendingReceived:
            return IconButton(
              icon: Icon(
                Icons.how_to_reg,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              tooltip: 'Respond to friend request',
              onPressed: () => _handleAcceptFriendRequest(context, ref),
            );
          case FriendshipStatus.friends:
            return IconButton(
              icon: Icon(
                Icons.chat_bubble_rounded,
                size: 20,
                color: theme.colorScheme.primary,
              ),
              tooltip: 'Open chat',
              onPressed: () => _handleOpenChat(context, ref),
            );
        }
      },
      loading: () => const SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
      error: (_, __) => IconButton(
        icon: Icon(
          Icons.error_outline,
          size: 20,
          color: theme.colorScheme.error,
        ),
        tooltip: 'Unable to load friend status',
        onPressed: () => _showErrorSnackBar(context, 'Unable to load friend status'),
      ),
    );
  }

  Future<void> _handleSendFriendRequest(BuildContext context, WidgetRef ref) async {
    if (currentUserId.isEmpty) {
      _showAuthPrompt(context);
      return;
    }

    try {
      final notifier = ref.read(sendFriendRequestProvider.notifier);
      await notifier.sendRequest(post.authorId);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Friend request sent to ${post.authorNickname}')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send friend request: ${_formatError(e)}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleCancelFriendRequest(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(friendsRepositoryProvider);
      final requestId = await repository.getPendingRequestId(currentUserId, post.authorId);
      
      if (requestId != null) {
        final notifier = ref.read(sendFriendRequestProvider.notifier);
        await notifier.cancelRequest(requestId, post.authorId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Friend request cancelled')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to cancel friend request: ${_formatError(e)}');
      }
    }
  }

  Future<void> _handleAcceptFriendRequest(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(friendsRepositoryProvider);
      final requestId = await repository.getPendingRequestId(currentUserId, post.authorId);
      
      if (requestId != null) {
        final notifier = ref.read(respondToFriendRequestProvider.notifier);
        await notifier.accept(requestId, post.authorId);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('You are now friends with ${post.authorNickname}')),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to accept friend request: ${_formatError(e)}');
      }
    }
  }

  Future<void> _handleOpenChat(BuildContext context, WidgetRef ref) async {
    try {
      final repository = ref.read(friendsRepositoryProvider);
      final conversationId = await repository.getConversationId(
        currentUserId,
        post.authorId,
      );

      if (conversationId != null && context.mounted) {
        context.push('/chat/$conversationId/${post.authorId}');
      } else if (context.mounted) {
        _showErrorSnackBar(context, 'Conversation not found');
      }
    } catch (e) {
      if (context.mounted) {
        _showErrorSnackBar(context, 'Failed to open chat: ${_formatError(e)}');
      }
    }
  }

  void _showAuthPrompt(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please sign in to connect with friends'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _formatError(dynamic error) {
    return error.toString().replaceFirst('Exception: ', '');
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.day}/${timestamp.month}/${timestamp.year}';
    }
  }
}