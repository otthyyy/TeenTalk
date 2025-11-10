import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../providers/user_profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom + 32;

    return Scaffold(
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return _buildEmptyState(context, ref);
          }

          return CustomScrollView(
            slivers: [
              _buildGradientHeader(context, profile, isDark),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildSpottedActivityCard(context, profile, isDark),
                      const SizedBox(height: 16),
                      _buildProfileInfoCard(context, profile, isDark),
                      const SizedBox(height: 16),
                      _buildPrivacySettingsCard(context, profile, isDark),
                      const SizedBox(height: 16),
                      _buildConsentCard(context, profile, isDark),
                      const SizedBox(height: 24),
                      _buildSignOutButton(context, ref),
                      SizedBox(height: bottomPadding),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading profile', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(error.toString(), style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 120, color: theme.colorScheme.primary.withOpacity(0.3)),
            const SizedBox(height: 24),
            Text(
              'No profile found',
              style: theme.textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Text(
              'Please complete your profile setup to continue',
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.push('/onboarding'),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Complete Profile'),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () async {
                await ref.read(firebaseAuthServiceProvider).signOut();
              },
              child: const Text('Sign Out'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientHeader(BuildContext context, dynamic profile, bool isDark) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      theme.colorScheme.primary.withOpacity(0.7),
                      theme.colorScheme.secondary.withOpacity(0.7),
                    ]
                  : [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Hero(
                  tag: 'profile-avatar',
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.white,
                      child: Text(
                        profile.nickname.isNotEmpty
                            ? profile.nickname[0].toUpperCase()
                            : '?',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.nickname.isNotEmpty ? profile.nickname : 'Anonymous',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (profile.nicknameVerified)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.verified, size: 16, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Verified',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.edit),
          onPressed: () {
            context.push('/profile/edit');
          },
        ),
      ],
    );
  }

  Widget _buildSpottedActivityCard(BuildContext context, dynamic profile, bool isDark) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      theme.colorScheme.primaryContainer,
                      theme.colorScheme.secondaryContainer,
                    ]
                  : [
                      theme.colorScheme.primary.withOpacity(0.1),
                      theme.colorScheme.secondary.withOpacity(0.1),
                    ],
            ),
          ),
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Icon(Icons.auto_awesome, 
                    size: 32, 
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Spotted Activity',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActivityStat(
                    context,
                    Icons.visibility_off,
                    'Anonymous Posts',
                    '${profile.anonymousPostsCount}',
                  ),
                  Container(
                    height: 40,
                    width: 1,
                    color: theme.dividerColor,
                  ),
                  _buildActivityStat(
                    context,
                    Icons.calendar_today,
                    'Member Since',
                    DateFormat('MMM yyyy').format(profile.createdAt),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityStat(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Icon(icon, size: 24, color: theme.colorScheme.primary),
        const SizedBox(height: 8),
        Text(
          value,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildProfileInfoCard(BuildContext context, dynamic profile, bool isDark) {
    final theme = Theme.of(context);
    final hasOptionalInfo = profile.gender != null || profile.school != null;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Profile Information',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (profile.gender != null)
              _buildInfoRow(
                context,
                Icons.person_outline,
                'Gender',
                _formatGender(profile.gender!),
              )
            else
              _buildEmptyInfoRow(
                context,
                Icons.person_outline,
                'Gender',
                'Add your gender in settings',
              ),
            const Divider(),
            if (profile.school != null)
              _buildInfoRow(
                context,
                Icons.school,
                'School',
                profile.school!,
              )
            else
              _buildEmptyInfoRow(
                context,
                Icons.school,
                'School',
                'Add your school in settings',
              ),
            if (!hasOptionalInfo) ...[
              const Divider(),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, 
                      size: 20, 
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Complete your profile to get the most out of Spotted',
                        style: theme.textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPrivacySettingsCard(BuildContext context, dynamic profile, bool isDark) {
    final theme = Theme.of(context);
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 500),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Privacy Settings',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _buildAnimatedSettingRow(
                context,
                Icons.visibility_off,
                'Anonymous Posts',
                profile.allowAnonymousPosts ? 'Enabled' : 'Disabled',
                profile.allowAnonymousPosts,
              ),
              const Divider(),
              _buildAnimatedSettingRow(
                context,
                Icons.person,
                'Profile Visibility',
                profile.profileVisible ? 'Visible' : 'Hidden',
                profile.profileVisible,
              ),
              const Divider(),
              _buildAnimatedSettingRow(
                context,
                Icons.bug_report,
                'Crash Reporting',
                profile.crashReportingEnabled ? 'Enabled' : 'Disabled',
                profile.crashReportingEnabled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsentCard(BuildContext context, dynamic profile, bool isDark) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Consent & Privacy',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoRow(
              context,
              Icons.verified_user,
              'Privacy Consent',
              profile.privacyConsentGiven ? 'Given' : 'Not given',
            ),
            const Divider(),
            _buildInfoRow(
              context,
              Icons.calendar_today,
              'Consent Date',
              DateFormat('MMM dd, yyyy').format(profile.privacyConsentTimestamp),
            ),
            if (profile.isMinor != null && profile.isMinor!) ...[
              const Divider(),
              _buildInfoRow(
                context,
                Icons.family_restroom,
                'Parental Consent',
                profile.parentalConsentGiven ?? false ? 'Given' : 'Not given',
              ),
              if (profile.guardianContact != null) ...[
                const Divider(),
                _buildInfoRow(
                  context,
                  Icons.contact_phone,
                  'Guardian Contact',
                  profile.guardianContact!,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyInfoRow(BuildContext context, IconData icon, String label, String hint) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Text(
            '$label:',
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              hint,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[400],
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedSettingRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
    bool enabled,
  ) {
    final theme = Theme.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: enabled
                  ? theme.colorScheme.primaryContainer
                  : Colors.grey[300],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 20,
              color: enabled ? theme.colorScheme.primary : Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: enabled
                  ? Colors.green.withOpacity(0.2)
                  : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: enabled ? Colors.green[700] : Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignOutButton(BuildContext context, WidgetRef ref) {
    return OutlinedButton.icon(
      onPressed: () async {
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sign Out'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await ref.read(firebaseAuthServiceProvider).signOut();
        }
      },
      icon: const Icon(Icons.logout),
      label: const Text('Sign Out'),
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        padding: const EdgeInsets.symmetric(vertical: 16),
        side: const BorderSide(color: Colors.red),
      ),
    );
  }

  String _formatGender(String gender) {
    switch (gender) {
      case 'male':
        return 'Male';
      case 'female':
        return 'Female';
      case 'non_binary':
        return 'Non-binary';
      case 'prefer_not_to_say':
        return 'Prefer not to say';
      default:
        return gender;
    }
  }
}
