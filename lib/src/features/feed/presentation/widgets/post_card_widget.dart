import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../common/widgets/trust_badge.dart';
import '../../../../core/services/analytics_provider.dart';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../comments/data/models/comment.dart';
import '../../../../core/widgets/cached_image_widget.dart';
import '../../../profile/domain/models/user_profile.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';
import '../../../../common/widgets/trust_badge.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/analytics_provider.dart';
import 'liker_list_modal.dart';

class PostCardWidget extends ConsumerStatefulWidget {
  final Post post;
  final String? currentUserId;
  final VoidCallback onComments;
  final VoidCallback onLike;
  final VoidCallback onUnlike;
  final VoidCallback onReport;
  final bool isNew;

  const PostCardWidget({
    super.key,
    required this.post,
    this.currentUserId,
    required this.onComments,
    required this.onLike,
    required this.onUnlike,
    required this.onReport,
    this.isNew = false,
  });

  @override
  ConsumerState<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends ConsumerState<PostCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  bool _isLikeAnimating = false;

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    if (widget.isNew) {
      _shimmerController.repeat();
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          _shimmerController.stop();
        }
      });
    }
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _onLikeCountTap() {
    if (widget.post.likeCount == 0 || widget.post.likedBy.isEmpty) {
      return;
    }

    final analytics = ref.read(analyticsServiceProvider);
    unawaited(
      analytics.logEvent(
        name: 'like_count_tap',
        parameters: {
          'post_id': widget.post.id,
          'like_count': widget.post.likeCount,
        },
      ),
    );

    unawaited(
      LikerListModal.show(
        context: context,
        likerIds: widget.post.likedBy,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isLiked = widget.currentUserId != null &&
        widget.post.likedBy.contains(widget.currentUserId);

    return Semantics(
      container: true,
      explicitChildNodes: true,
      child: AnimatedBuilder(
        animation: _shimmerController,
        builder: (context, child) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: widget.isNew
                  ? LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        theme.colorScheme.primary.withOpacity(0.1),
                        theme.colorScheme.secondary.withOpacity(0.05),
                      ],
                      stops: [
                        _shimmerController.value - 0.3,
                        _shimmerController.value + 0.3,
                      ],
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: child,
          );
        },
        child: MergeSemantics(
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.surface,
                    theme.colorScheme.surface.withOpacity(0.95),
                  ],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, theme),
                    const SizedBox(height: 12),
                    _buildContent(theme),
                    if (widget.post.imageUrl != null) ...[
                      const SizedBox(height: 12),
                      _buildImage(theme),
                    ],
                    const SizedBox(height: 12),
                    _buildFooter(theme, isLiked),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final accentColor = _getUserAccentColor(theme);
    final isAnonymous = widget.post.isAnonymous;

    return Semantics(
      label:
          'Post by ${isAnonymous ? 'Anonymous' : widget.post.authorNickname}, ${_formatTimestamp(widget.post.createdAt)}',
      child: Row(
        children: [
          Semantics(
            label: isAnonymous
                ? 'Anonymous user avatar'
                : '${widget.post.authorNickname} avatar',
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    accentColor,
                    accentColor.withOpacity(0.7),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: Colors.transparent,
                child: isAnonymous
                    ? Icon(
                        Icons.person_outline,
                        color: theme.colorScheme.onPrimary,
                      )
                    : Text(
                        widget.post.authorNickname.isNotEmpty
                            ? widget.post.authorNickname[0].toUpperCase()
                            : 'A',
                        style: TextStyle(
                          color: theme.colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
                    if (isAnonymous)
                      Text(
                        'Anonymous',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      Semantics(
                        button: true,
                        link: true,
                        label: 'View profile of ${widget.post.authorNickname}',
                        child: InkWell(
                          onTap: () {
                            context.push('/users/${widget.post.authorId}');
                          },
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 2,
                            ),
                            child: Text(
                              widget.post.authorNickname,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (!isAnonymous) ...[
                      const SizedBox(width: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          final authorProfileAsync =
                              ref.watch(userProfileByIdProvider(widget.post.authorId));
                          return authorProfileAsync.when(
                            data: (authorProfile) {
                              if (authorProfile == null) {
                                return const SizedBox.shrink();
                              }
                              return TrustBadge(
                                trustLevel: authorProfile.trustLevel,
                                showLabel: false,
                                size: 16,
                                onTap: () {
                                  ref.read(analyticsServiceProvider).logTrustBadgeTap(
                                        authorProfile.trustLevel.name,
                                        'post_card',
                                      );
                                },
                              );
                            },
                            loading: () => const SizedBox.shrink(),
                            error: (_, __) => const SizedBox.shrink(),
                          );
                        },
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTimestamp(widget.post.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Semantics(
            label: 'More options',
            button: true,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'report') {
                  widget.onReport();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'report',
                  child: Row(
                    children: [
                      Icon(Icons.flag_outlined),
                      SizedBox(width: 8),
                      Text('Report'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    return Semantics(
      label: 'Post content: ${widget.post.content}',
      child: Text(
        widget.post.content,
        style: theme.textTheme.bodyMedium?.copyWith(
          height: 1.4,
        ),
      ),
    );
  }

  Widget _buildImage(ThemeData theme) {
    return Semantics(
      label: 'Post image',
      image: true,
      child: CachedImageWidget(
        imageUrl: widget.post.imageUrl!,
        width: double.infinity,
        height: 200,
        fit: BoxFit.cover,
        borderRadius: BorderRadius.circular(12),
        errorWidget: Container(
          height: 200,
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceVariant,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              size: 48,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        enableInstrumentation: true,
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, bool isLiked) {
    return Semantics(
      label: '${widget.post.likeCount} likes, ${widget.post.commentCount} comments, section: ${widget.post.section}',
      child: Row(
        children: [
          Semantics(
            button: true,
            label: isLiked
                ? 'Unlike post, view ${widget.post.likeCount} likes'
                : 'Like post, view ${widget.post.likeCount} likes',
            excludeSemantics: true,
            child: AnimatedScale(
              scale: _isLikeAnimating ? 1.2 : 1.0,
              duration: const Duration(milliseconds: 150),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _isLikeAnimating = true;
                  });
                  Future.delayed(const Duration(milliseconds: 150), () {
                    if (mounted) {
                      setState(() {
                        _isLikeAnimating = false;
                      });
                    }
                  });

                  if (isLiked) {
                    widget.onUnlike();
                  } else {
                    widget.onLike();
                  }
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                  decoration: BoxDecoration(
                    gradient: isLiked
                        ? LinearGradient(
                            colors: [
                              theme.colorScheme.error,
                              theme.colorScheme.error.withOpacity(0.8),
                            ],
                          )
                        : null,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: isLiked
                            ? Colors.white
                            : theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 4),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: widget.post.likeCount > 0 ? _onLikeCountTap : null,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Text(
                            widget.post.likeCount.toString(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: isLiked
                                  ? Colors.white
                                  : theme.colorScheme.onSurfaceVariant,
                              fontWeight:
                                  widget.post.likeCount > 0 ? FontWeight.w600 : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Semantics(
            button: true,
            label: 'View comments, ${widget.post.commentCount} comments',
            excludeSemantics: true,
            child: InkWell(
              onTap: widget.onComments,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.comment_outlined,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      widget.post.commentCount.toString(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Semantics(
            label: 'Section: ${widget.post.section}',
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.2),
                    theme.colorScheme.secondary.withOpacity(0.2),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.post.section.toUpperCase(),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getUserAccentColor(ThemeData theme) {
    if (widget.post.isAnonymous) {
      return theme.colorScheme.secondary;
    }

    final hash = widget.post.authorId.hashCode;
    final colors = [
      theme.colorScheme.primary,
      theme.colorScheme.secondary,
      theme.colorScheme.tertiary,
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
      const Color(0xFF3B82F6),
    ];

    return colors[hash.abs() % colors.length];
  }

  String _formatTimestamp(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
