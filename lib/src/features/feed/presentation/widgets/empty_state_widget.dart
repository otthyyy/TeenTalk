import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/core/constants/tt_assets.dart';
import 'package:teen_talk_app/src/core/providers/animation_preferences_provider.dart';
import 'package:teen_talk_app/src/core/widgets/lazy_lottie.dart';
import '../pages/feed_sections_page.dart';

class EmptyStateWidget extends ConsumerWidget {

  const EmptyStateWidget({
    super.key,
    required this.section,
  });
  final FeedSection section;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final motionEnabledAsync = ref.watch(isMotionEnabledProvider);
    final shouldAnimate = motionEnabledAsync.when(
      data: (enabled) => enabled,
      loading: () => false,
      error: (_, __) => false,
    );
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LazyLottie(
            assetPath: TTAssets.lottieEmptyState,
            shouldAnimate: shouldAnimate,
            width: 200,
            height: 200,
            fallbackIcon: _getSectionIcon(),
          ),
          const SizedBox(height: 16),
          Text(
            'No ${section.label.toLowerCase()} posts yet',
            style: theme.textTheme.titleLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getSectionMessage(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          Icon(
            Icons.add_circle_outline,
            size: 48,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to post in ${section.label}!',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSectionIcon() {
    switch (section) {
      case FeedSection.spotted:
        return Icons.visibility_outlined;
      case FeedSection.general:
        return Icons.chat_bubble_outline;
    }
  }

  String _getSectionMessage() {
    switch (section) {
      case FeedSection.spotted:
        return 'Share what you\'ve spotted around campus or town';
      case FeedSection.general:
        return 'Share your thoughts, questions, or general updates';
    }
  }
}