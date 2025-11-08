import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/moderation_item.dart';
import '../../data/models/content_report.dart';
import '../providers/moderation_provider.dart';

class ModerationQueuePage extends ConsumerWidget {
  const ModerationQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final moderationQueueAsync = ref.watch(moderationQueueProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Moderation Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
            tooltip: 'Help',
          ),
        ],
      ),
      body: moderationQueueAsync.when(
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 64,
                    color: Colors.green,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No items in moderation queue',
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'All reported content has been reviewed',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final item = items[index];
              return _ModerationItemCard(item: item);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading moderation queue: $error'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(moderationQueueProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Moderation Queue'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'This queue shows all content that has been reported by users or automatically flagged.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Text('• Items are sorted by report count (highest first)'),
              Text('• Content with 3+ reports is automatically hidden'),
              Text('• Review each item and take appropriate action'),
              SizedBox(height: 12),
              Text(
                'Actions:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text('• Keep Active: Content is fine, dismiss reports'),
              Text('• Keep Hidden: Content stays hidden pending further review'),
              Text('• Remove: Permanently remove content'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

class _ModerationItemCard extends ConsumerWidget {
  final ModerationItem item;

  const _ModerationItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reportsAsync = ref.watch(contentReportsProvider(item.contentId));

    Color statusColor = theme.colorScheme.primary;
    IconData statusIcon = Icons.visibility;

    switch (item.status) {
      case ModerationStatus.hidden:
        statusColor = Colors.orange;
        statusIcon = Icons.visibility_off;
        break;
      case ModerationStatus.removed:
        statusColor = Colors.red;
        statusIcon = Icons.delete;
        break;
      case ModerationStatus.active:
        statusColor = Colors.green;
        statusIcon = Icons.visibility;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(statusIcon, color: statusColor, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${item.contentType.value.toUpperCase()} - ${item.contentId.substring(0, 8)}...',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: item.reportCount >= 3 ? Colors.red : Colors.orange,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${item.reportCount} reports',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _InfoChip(
                  icon: Icons.person,
                  label: 'Author: ${item.authorId.substring(0, 8)}...',
                ),
                const SizedBox(width: 8),
                if (item.isAnonymous)
                  const _InfoChip(
                    icon: Icons.privacy_tip,
                    label: 'Anonymous',
                    color: Colors.purple,
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Status: ${item.status.value}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Created: ${_formatDate(item.createdAt)}',
              style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
            if (item.hiddenAt != null)
              Text(
                'Hidden: ${_formatDate(item.hiddenAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
              ),
            const Divider(height: 24),
            reportsAsync.when(
              data: (reports) {
                if (reports.isEmpty) {
                  return const Text('No reports found');
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Reports:',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    ...reports.take(3).map((report) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                Icons.flag,
                                size: 14,
                                color: theme.colorScheme.error,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  report.reason.displayName,
                                  style: theme.textTheme.bodySmall,
                                ),
                              ),
                              Text(
                                _formatDate(report.createdAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: Colors.grey,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        )),
                    if (reports.length > 3)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '+ ${reports.length - 3} more reports',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ],
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (_, __) => const Text('Error loading reports'),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () => _viewDetails(context, item),
                  icon: const Icon(Icons.visibility, size: 16),
                  label: const Text('View Details'),
                ),
                const SizedBox(width: 8),
                if (item.status != ModerationStatus.removed)
                  FilledButton.icon(
                    onPressed: () => _showActionMenu(context, ref, item),
                    icon: const Icon(Icons.admin_panel_settings, size: 16),
                    label: const Text('Take Action'),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes}m ago';
    if (difference.inHours < 24) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${date.day}/${date.month}/${date.year}';
  }

  void _viewDetails(BuildContext context, ModerationItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Content Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _DetailRow('Content ID:', item.contentId),
              _DetailRow('Type:', item.contentType.value),
              _DetailRow('Author ID:', item.authorId),
              _DetailRow('Report Count:', item.reportCount.toString()),
              _DetailRow('Status:', item.status.value),
              _DetailRow('Anonymous:', item.isAnonymous ? 'Yes' : 'No'),
              _DetailRow('Created:', item.createdAt.toString()),
              if (item.hiddenAt != null)
                _DetailRow('Hidden At:', item.hiddenAt.toString()),
              if (item.reviewedAt != null)
                _DetailRow('Reviewed At:', item.reviewedAt.toString()),
              if (item.reviewedBy != null)
                _DetailRow('Reviewed By:', item.reviewedBy!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showActionMenu(BuildContext context, WidgetRef ref, ModerationItem item) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility, color: Colors.green),
              title: const Text('Keep Active'),
              subtitle: const Text('Content is fine, dismiss reports'),
              onTap: () {
                Navigator.pop(context);
                _showConfirmAction(
                  context,
                  ref,
                  item,
                  ModerationStatus.active,
                  'Keep this content active?',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.visibility_off, color: Colors.orange),
              title: const Text('Keep Hidden'),
              subtitle: const Text('Content stays hidden pending review'),
              onTap: () {
                Navigator.pop(context);
                _showConfirmAction(
                  context,
                  ref,
                  item,
                  ModerationStatus.hidden,
                  'Keep this content hidden?',
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Remove Content'),
              subtitle: const Text('Permanently remove this content'),
              onTap: () {
                Navigator.pop(context);
                _showConfirmAction(
                  context,
                  ref,
                  item,
                  ModerationStatus.removed,
                  'Permanently remove this content?',
                );
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _showConfirmAction(
    BuildContext context,
    WidgetRef ref,
    ModerationItem item,
    ModerationStatus newStatus,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              try {
                final service = ref.read(moderationServiceProvider);
                await service.updateModerationStatus(
                  contentId: item.contentId,
                  newStatus: newStatus,
                  adminId: 'current_admin_id',
                );
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Action completed successfully')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({
    required this.icon,
    required this.label,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (color ?? Colors.blue).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (color ?? Colors.blue).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color ?? Colors.blue),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color ?? Colors.blue,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }
}
