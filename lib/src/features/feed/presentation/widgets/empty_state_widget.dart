import 'package:flutter/material.dart';
import '../pages/feed_sections_page.dart';

class EmptyStateWidget extends StatelessWidget {
  final FeedSection section;

  const EmptyStateWidget({
    super.key,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getSectionIcon(),
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
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