import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../models/queued_action.dart';
import '../../services/sync_queue_service.dart';

class SyncQueuePage extends ConsumerWidget {
  const SyncQueuePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queuedActionsAsync = ref.watch(queuedActionsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Sync Queue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () => _showClearQueueDialog(context, ref),
            tooltip: 'Clear completed items',
          ),
        ],
      ),
      body: queuedActionsAsync.when(
        data: (actions) {
          if (actions.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.cloud_done,
                    size: 64,
                    color: theme.colorScheme.primary.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No queued items',
                    style: theme.textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Content will appear here when offline',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            );
          }

          final pending = actions.where((a) => a.isPending || a.isSyncing).toList();
          final failed = actions.where((a) => a.hasFailed).toList();
          final completed = actions.where((a) => a.isCompleted).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (pending.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Pending (${pending.length})',
                  Icons.schedule,
                  theme.colorScheme.primary,
                ),
                const SizedBox(height: 8),
                ...pending.map((action) => _buildQueueItem(context, ref, action, theme)),
                const SizedBox(height: 16),
              ],
              if (failed.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Failed (${failed.length})',
                  Icons.error_outline,
                  theme.colorScheme.error,
                ),
                const SizedBox(height: 8),
                ...failed.map((action) => _buildQueueItem(context, ref, action, theme)),
                const SizedBox(height: 16),
              ],
              if (completed.isNotEmpty) ...[
                _buildSectionHeader(
                  context,
                  'Completed (${completed.length})',
                  Icons.check_circle_outline,
                  theme.colorScheme.tertiary,
                ),
                const SizedBox(height: 8),
                ...completed.map((action) => _buildQueueItem(context, ref, action, theme)),
              ],
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading queue: $error'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQueueItem(
    BuildContext context,
    WidgetRef ref,
    QueuedAction action,
    ThemeData theme,
  ) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(action.status, theme).withOpacity(0.2),
          child: Icon(
            _getActionIcon(action.type),
            color: _getStatusColor(action.status, theme),
          ),
        ),
        title: Text(_getActionTitle(action)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              _getActionSubtitle(action),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  dateFormat.format(action.createdAt),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (action.retryCount > 0) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: Text(
                      'Retry ${action.retryCount}/3',
                      style: theme.textTheme.labelSmall,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ],
            ),
            if (action.errorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                action.errorMessage!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
        trailing: _buildActionButtons(context, ref, action),
      ),
    );
  }

  Widget? _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    QueuedAction action,
  ) {
    if (action.isCompleted) {
      return IconButton(
        icon: const Icon(Icons.delete_outline),
        onPressed: () => _removeAction(context, ref, action),
        tooltip: 'Remove',
      );
    }

    if (action.hasFailed && action.canRetry) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _retryAction(context, ref, action),
            tooltip: 'Retry',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _removeAction(context, ref, action),
            tooltip: 'Remove',
          ),
        ],
      );
    }

    if (action.isSyncing) {
      return const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }

    return null;
  }

  IconData _getActionIcon(QueuedActionType type) {
    switch (type) {
      case QueuedActionType.post:
        return Icons.article;
      case QueuedActionType.comment:
        return Icons.comment;
      case QueuedActionType.directMessage:
        return Icons.message;
    }
  }

  String _getActionTitle(QueuedAction action) {
    switch (action.type) {
      case QueuedActionType.post:
        return 'Post';
      case QueuedActionType.comment:
        return 'Comment';
      case QueuedActionType.directMessage:
        return 'Direct Message';
    }
  }

  String _getActionSubtitle(QueuedAction action) {
    final content = action.data['content'] as String? ?? action.data['text'] as String?;
    if (content != null && content.isNotEmpty) {
      return content;
    }
    return 'No content';
  }

  Color _getStatusColor(QueuedActionStatus status, ThemeData theme) {
    switch (status) {
      case QueuedActionStatus.pending:
        return theme.colorScheme.primary;
      case QueuedActionStatus.syncing:
        return theme.colorScheme.secondary;
      case QueuedActionStatus.failed:
        return theme.colorScheme.error;
      case QueuedActionStatus.completed:
        return theme.colorScheme.tertiary;
    }
  }

  Future<void> _retryAction(
    BuildContext context,
    WidgetRef ref,
    QueuedAction action,
  ) async {
    try {
      await ref.read(syncQueueServiceProvider).retryAction(action.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Retrying sync...')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to retry: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _removeAction(
    BuildContext context,
    WidgetRef ref,
    QueuedAction action,
  ) async {
    try {
      await ref.read(syncQueueServiceProvider).removeAction(action.id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Removed from queue')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to remove: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _showClearQueueDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Queue'),
        content: const Text(
          'This will remove all completed items from the queue. Pending and failed items will remain.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      try {
        final actions = await ref.read(queuedActionsProvider.future);
        final completedIds = actions
            .where((a) => a.isCompleted)
            .map((a) => a.id)
            .toList();

        for (final id in completedIds) {
          await ref.read(syncQueueServiceProvider).removeAction(id);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Removed ${completedIds.length} completed items')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to clear queue: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}
