import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/user_profile.dart';

/// Banner that shows when user's profile is incomplete
/// Encourages them to complete it without blocking functionality
class IncompleteProfileBanner extends StatelessWidget {
  final UserProfile profile;

  const IncompleteProfileBanner({
    super.key,
    required this.profile,
  });

  List<String> _getMissingFields() {
    final missing = <String>[];

    if (profile.schoolYear == null || profile.schoolYear!.trim().isEmpty) {
      missing.add('School Year');
    }
    if (profile.school == null || profile.school!.trim().isEmpty) {
      missing.add('School');
    }
    if (profile.gender == null || profile.gender!.trim().isEmpty) {
      missing.add('Gender');
    }
    if (profile.interests.isEmpty) {
      missing.add('Interests');
    }

    return missing;
  }

  @override
  Widget build(BuildContext context) {
    if (profile.isProfileComplete) {
      return const SizedBox.shrink();
    }

    final missingFields = _getMissingFields();
    if (missingFields.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: theme.colorScheme.onPrimaryContainer,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Complete Your Profile',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Add ${missingFields.join(', ')} to help others discover you',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          TextButton(
            onPressed: () => context.push('/profile/edit'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.onPrimaryContainer,
              backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
            ),
            child: const Text('Complete'),
          ),
        ],
      ),
    );
  }
}
