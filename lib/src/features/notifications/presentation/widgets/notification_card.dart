import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/models/app_notification.dart';
import '../providers/notifications_provider.dart';

class NotificationCard extends ConsumerWidget {
  final AppNotification notification;

  const NotificationCard({
    super.key,
    required this.notification,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Dismissible(
      key: ValueKey(notification.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        if (!notification.read) {
          await ref.read(notificationsActionsProvider).markAsRead(notification.id);
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Marked as read'),
                duration: Duration(seconds: 1),
              ),
            );
          }
        }
        return false;
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20.0),
        color: theme.colorScheme.primary,
        child: Icon(
          Icons.check,
          color: theme.colorScheme.onPrimary,
        ),
      ),
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        elevation: notification.read ? 0 : 2,
        child: InkWell(
          onTap: () => _handleNotificationTap(context, ref),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIcon(theme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: notification.read ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                          ),
                          if (!notification.read)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.body,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: notification.read 
                              ? theme.colorScheme.onSurfaceVariant
                              : theme.colorScheme.onSurface,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatTimestamp(notification.createdAt),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    IconData iconData;
    Color? iconColor;
    
    switch (notification.type) {
      case NotificationType.commentMention:
        iconData = Icons.alternate_email;
        iconColor = theme.colorScheme.primary;
        break;
      case NotificationType.commentReply:
        iconData = Icons.reply;
        iconColor = theme.colorScheme.secondary;
        break;
      case NotificationType.postMention:
        iconData = Icons.person_pin;
        iconColor = theme.colorScheme.tertiary;
        break;
      case NotificationType.general:
        iconData = Icons.notifications;
        iconColor = theme.colorScheme.onSurfaceVariant;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor?.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        size: 24,
        color: iconColor,
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      return '$minutes ${minutes == 1 ? 'minute' : 'minutes'} ago';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      return '$hours ${hours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days ${days == 1 ? 'day' : 'days'} ago';
    } else {
      return DateFormat('MMM d, y').format(timestamp);
    }
  }

  void _handleNotificationTap(BuildContext context, WidgetRef ref) async {
    if (!notification.read) {
      await ref.read(notificationsActionsProvider).markAsRead(notification.id);
    }

    final postId = notification.postId;
    if (postId != null && context.mounted) {
      context.pop();
    }
  }
}
