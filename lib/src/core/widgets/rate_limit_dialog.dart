import 'package:flutter/material.dart';
import '../localization/app_localizations.dart';

class RateLimitDialog extends StatelessWidget {
  final String contentType;
  final Duration? cooldownDuration;
  final VoidCallback onDismiss;
  final VoidCallback? onViewGuidelines;

  const RateLimitDialog({
    super.key,
    required this.contentType,
    this.cooldownDuration,
    required this.onDismiss,
    this.onViewGuidelines,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    
    return AlertDialog(
      title: Row(
        children: [
          Icon(
            Icons.timer_off,
            color: theme.colorScheme.error,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(l10n?.rateLimitTitle ?? 'Rate Limit Reached'),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            contentType == 'post'
                ? (l10n?.rateLimitPostsExceeded ?? 'Too many posts')
                : (l10n?.rateLimitCommentsExceeded ?? 'Too many comments'),
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 20,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.rateLimitCooldownMessage ?? 'Cooldown period active',
                    style: theme.textTheme.bodySmall,
                  ),
                ),
              ],
            ),
          ),
          if (cooldownDuration != null) ...[
            const SizedBox(height: 16),
            Center(
              child: Chip(
                avatar: const Icon(Icons.access_time),
                label: Text(
                  l10n?.cooldownTimer(cooldownDuration!.inSeconds) ?? 
                      'Wait ${cooldownDuration!.inSeconds}s',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          if (onViewGuidelines != null) ...[
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                onViewGuidelines?.call();
              },
              icon: const Icon(Icons.info_outline),
              label: Text(l10n?.rateLimitViewGuidelines ?? 'View Guidelines'),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onDismiss();
          },
          child: Text(l10n?.rateLimitOkay ?? 'Okay'),
        ),
      ],
    );
  }

  static void show(
    BuildContext context, {
    required String contentType,
    Duration? cooldownDuration,
    VoidCallback? onDismiss,
    VoidCallback? onViewGuidelines,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => RateLimitDialog(
        contentType: contentType,
        cooldownDuration: cooldownDuration,
        onDismiss: onDismiss ?? () {},
        onViewGuidelines: onViewGuidelines,
      ),
    );
  }
}
