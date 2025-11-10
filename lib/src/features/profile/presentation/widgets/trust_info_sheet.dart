import 'package:flutter/material.dart';
import '../../domain/models/trust_level.dart';
import '../../domain/models/trust_level_localizations.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../common/widgets/trust_badge.dart';

Future<void> showTrustInfoSheet({
  required BuildContext context,
  required TrustLevel trustLevel,
}) {
  final theme = Theme.of(context);
  final localization = AppLocalizations.of(context);
  final label = trustLevelLabel(trustLevel, localization);
  final description = trustLevelDescription(trustLevel, localization);
  final learnMore = localization?.trustInfoLearnMore ?? 'Learn more about trust levels';

  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                TrustBadge(
                  trustLevel: trustLevel,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              learnMore,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: () => Navigator.of(context).maybePop(),
                child: Text(MaterialLocalizations.of(context).okButtonLabel),
              ),
            ),
          ],
        ),
      );
    },
  );
}
