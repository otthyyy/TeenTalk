import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/content_report.dart';
import '../providers/moderation_provider.dart';
import 'report_button.dart';

/// Example widget showing how to integrate moderation features with content display
/// This can be used as a reference for implementing moderation in post/comment widgets
class ContentWithModeration extends ConsumerWidget {
  final String contentId;
  final String contentAuthorId;
  final String contentText;
  final ContentType contentType;
  final Widget? authorWidget;
  final Widget? timestampWidget;

  const ContentWithModeration({
    super.key,
    required this.contentId,
    required this.contentAuthorId,
    required this.contentText,
    required this.contentType,
    this.authorWidget,
    this.timestampWidget,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isHiddenAsync = ref.watch(isContentHiddenProvider(contentId));

    return isHiddenAsync.when(
      data: (isHidden) {
        if (isHidden) {
          return _buildHiddenContent(context);
        }
        return _buildVisibleContent(context);
      },
      loading: () => _buildLoadingContent(context),
      error: (_, __) => _buildVisibleContent(context),
    );
  }

  Widget _buildHiddenContent(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.visibility_off,
                  color: theme.colorScheme.error,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Content Hidden',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'This content has been hidden by moderators due to community reports. '
              'It is under review and may be restored if found to comply with community guidelines.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingContent(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (authorWidget != null) authorWidget!,
                const Spacer(),
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 16,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibleContent(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (authorWidget != null) ...[
                  authorWidget!,
                  const SizedBox(width: 8),
                ],
                if (timestampWidget != null) ...[
                  timestampWidget!,
                ],
                const Spacer(),
                ReportButton(
                  contentId: contentId,
                  contentType: contentType,
                  contentAuthorId: contentAuthorId,
                  isIconButton: true,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              contentText,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.thumb_up_outlined, size: 16),
                  label: const Text('Like'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.comment_outlined, size: 16),
                  label: const Text('Comment'),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.share_outlined, size: 16),
                  label: const Text('Share'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Example of how to display a simple post with moderation
class SimplePostExample extends StatelessWidget {
  const SimplePostExample({super.key});

  @override
  Widget build(BuildContext context) {
    return ContentWithModeration(
      contentId: 'post_123',
      contentAuthorId: 'user_456',
      contentType: ContentType.post,
      contentText: 'This is an example post with moderation features enabled.',
      authorWidget: const Row(
        children: [
          CircleAvatar(
            radius: 16,
            child: Icon(Icons.person, size: 16),
          ),
          SizedBox(width: 8),
          Text(
            'John Doe',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      timestampWidget: const Text(
        '2 hours ago',
        style: TextStyle(color: Colors.grey, fontSize: 12),
      ),
    );
  }
}
