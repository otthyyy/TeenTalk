import 'package:flutter/material.dart';
import '../../core/localization/app_localizations.dart';
import '../../features/profile/domain/models/trust_level.dart';

class TrustBadge extends StatelessWidget {

  const TrustBadge({
    super.key,
    required this.trustLevel,
    this.showLabel = true,
    this.size = 20,
    this.onTap,
  });
  final TrustLevel trustLevel;
  final bool showLabel;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = _getBadgeColor();
    final icon = _getBadgeIcon();
    final localization = AppLocalizations.of(context);
    final label = _getBadgeLabel(localization);
    final description = _getBadgeDescription(localization);

    final badge = Container(
      padding: EdgeInsets.symmetric(
        horizontal: showLabel ? 8 : 4,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: size,
            color: badgeColor,
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: badgeColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );

    final tooltip = Tooltip(
      message: '$label — $description',
      child: badge,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: tooltip,
      );
    }

    return tooltip;
  }

  Color _getBadgeColor() {
    switch (trustLevel) {
      case TrustLevel.newcomer:
        return const Color(0xFF9E9E9E);
      case TrustLevel.member:
        return const Color(0xFF3B82F6);
      case TrustLevel.trusted:
        return const Color(0xFF10B981);
      case TrustLevel.veteran:
        return const Color(0xFFF59E0B);
    }
  }

  IconData _getBadgeIcon() {
    switch (trustLevel) {
      case TrustLevel.newcomer:
        return Icons.person_add_outlined;
      case TrustLevel.member:
        return Icons.person;
      case TrustLevel.trusted:
        return Icons.verified_user;
      case TrustLevel.veteran:
        return Icons.military_tech;
    }
  }

  String _getBadgeLabel(AppLocalizations? localization) {
    switch (trustLevel) {
      case TrustLevel.newcomer:
        return localization?.trustBadgeNewcomerLabel ?? 'Newcomer';
      case TrustLevel.member:
        return localization?.trustBadgeMemberLabel ?? 'Member';
      case TrustLevel.trusted:
        return localization?.trustBadgeTrustedLabel ?? 'Trusted';
      case TrustLevel.veteran:
        return localization?.trustBadgeVeteranLabel ?? 'Veteran';
    }
  }

  String _getBadgeDescription(AppLocalizations? localization) {
    switch (trustLevel) {
      case TrustLevel.newcomer:
        return localization?.trustBadgeNewcomerDescription ?? 'New to the community';
      case TrustLevel.member:
        return localization?.trustBadgeMemberDescription ?? 'Active community member';
      case TrustLevel.trusted:
        return localization?.trustBadgeTrustedDescription ?? 'Trusted community member';
      case TrustLevel.veteran:
        return localization?.trustBadgeVeteranDescription ?? 'Long-standing community member';
    }
  }
}
