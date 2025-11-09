import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/notifications_provider.dart';

class NotificationBadge extends ConsumerWidget {
  final VoidCallback onTap;

  const NotificationBadge({
    super.key,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(unreadNotificationCountProvider);

    return IconButton(
      onPressed: onTap,
      icon: Badge(
        isLabelVisible: unreadCount > 0,
        label: Text(
          unreadCount > 99 ? '99+' : unreadCount.toString(),
        ),
        child: const Icon(Icons.notifications_outlined),
      ),
    );
  }
}
