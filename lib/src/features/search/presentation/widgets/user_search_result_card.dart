import 'package:flutter/material.dart';

import '../../../profile/domain/models/user_profile.dart';

class UserSearchResultCard extends StatelessWidget {
  const UserSearchResultCard({
    super.key,
    required this.profile,
    required this.onTap,
  });

  final UserProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(
            profile.nickname.isNotEmpty
                ? profile.nickname[0].toUpperCase()
                : '?',
          ),
        ),
        title: Text(
          profile.nickname,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (profile.school != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.school, size: 14),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      profile.school!,
                      style: Theme.of(context).textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (profile.schoolYear != null) ...[
              const SizedBox(height: 2),
              Row(
                children: [
                  const Icon(Icons.grade, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Year ${profile.schoolYear}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            if (profile.interests.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                children: profile.interests.take(3).map((interest) {
                  return Chip(
                    label: Text(
                      interest,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (profile.trustLevel > 0) ...[
              const Icon(Icons.verified, size: 16),
              const SizedBox(width: 4),
              Text(
                profile.trustLevel.toStringAsFixed(0),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}
