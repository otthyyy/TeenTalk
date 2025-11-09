import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/comments_provider.dart';
import 'comments_list_widget.dart';

class CommentsBottomSheet extends ConsumerStatefulWidget {
  final String postId;
  final int initialCommentCount;
  final ValueChanged<int>? onCommentCountChanged;

  const CommentsBottomSheet({
    super.key,
    required this.postId,
    required this.initialCommentCount,
    this.onCommentCountChanged,
  });

  @override
  ConsumerState<CommentsBottomSheet> createState() => _CommentsBottomSheetState();

  static Future<void> show({
    required BuildContext context,
    required String postId,
    required int initialCommentCount,
    ValueChanged<int>? onCommentCountChanged,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CommentsBottomSheet(
        postId: postId,
        initialCommentCount: initialCommentCount,
        onCommentCountChanged: onCommentCountChanged,
      ),
    );
  }
}

class _CommentsBottomSheetState extends ConsumerState<CommentsBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late int _commentCount;

  @override
  void initState() {
    super.initState();
    _commentCount = widget.initialCommentCount;

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();

    // Preload comments when the sheet opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(commentsProvider(widget.postId).notifier).loadComments();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleCommentCountChanged(int delta) {
    setState(() {
      _commentCount = (_commentCount + delta).clamp(0, 1 << 30);
    });
    widget.onCommentCountChanged?.call(delta);
  }

  Future<void> _closeWithAnimation() async {
    await _animationController.reverse();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          height: MediaQuery.of(context).size.height * 0.9,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 16,
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: theme.colorScheme.outline.withOpacity(0.08),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _closeWithAnimation,
                      icon: const Icon(Icons.close),
                      tooltip: 'Close',
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.comment,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Comments',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$_commentCount',
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: theme.colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      width: 36,
                      height: 4,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.outline.withOpacity(0.35),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CommentsListWidget(
                  postId: widget.postId,
                  onCommentCountChanged: _handleCommentCountChanged,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
