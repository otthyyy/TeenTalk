import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/user_profile.dart';
import '../providers/user_profile_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../legal/presentation/pages/legal_document_page.dart';
import '../../../tutorial/presentation/providers/tutorial_provider.dart';
import '../../../../common/widgets/trust_badge.dart';
import '../../../../core/localization/app_localizations.dart';
import '../../../../core/services/analytics_provider.dart';
import '../../domain/models/trust_level_localizations.dart';

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
                      _buildTutorialCard(context, ref, isDark),
                      const SizedBox(height: 16),
                      _buildConsentCard(context, profile, isDark),
                      const SizedBox(height: 16),
                      _buildBetaProgramCard(context, ref, profile, isDark),
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
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (profile.nicknameVerified) ...[
                      const Icon(Icons.verified, size: 16, color: Colors.white),
                      const SizedBox(width: 4),
                      const Text(
                        'Verified',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                      const SizedBox(width: 8),
                    ],
                    TrustBadge(
                      trustLevel: profile.trustLevel,
                      showLabel: true,
                      size: 16,
                      onTap: () {
                        ref.read(analyticsServiceProvider).logTrustBadgeTap(
                              profile.uid,
                              profile.trustLevel.name,
                            );
                      },
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
              const Divider(),
              _buildAnimatedSettingRow(
                context,
                Icons.no_photography,
                'Screenshot Protection',
                profile.screenshotProtectionEnabled ? 'Enabled' : 'Disabled',
                profile.screenshotProtectionEnabled,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsentCard(BuildContext context, dynamic profile, bool isDark) {
    final theme = Theme.of(context);
    final localizations = AppLocalizations.of(context);
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
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.privacy_tip_outlined, color: theme.colorScheme.primary),
              title: Text(localizations?.legalViewPrivacy ?? 'View Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openLegalDocument(context, LegalDocumentType.privacyPolicy),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.gavel_outlined, color: theme.colorScheme.primary),
              title: Text(localizations?.legalViewTerms ?? 'View Terms of Service'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _openLegalDocument(context, LegalDocumentType.termsOfService),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBetaProgramCard(BuildContext context, WidgetRef ref, UserProfile profile, bool isDark) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.science_outlined,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Beta Program',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Get early access to TeenTalk features and help us ship a better experience by sharing your feedback.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile.adaptive(
              value: profile.isBetaTester,
              contentPadding: EdgeInsets.zero,
              onChanged: (value) async => _handleBetaToggle(context, ref, profile, value),
              activeColor: theme.colorScheme.primary,
              title: const Text('Join TeenTalk Beta'),
              subtitle: const Text(
                'Receive testing builds via Firebase App Distribution and share feedback directly from the app.',
              ),
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(
                profile.betaConsentGiven == true
                    ? Icons.verified_user
                    : Icons.privacy_tip_outlined,
                color: theme.colorScheme.primary,
              ),
              title: Text(
                profile.betaConsentGiven == true ? 'Consent captured' : 'Consent required',
                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                profile.betaConsentGiven == true && profile.betaConsentTimestamp != null
                    ? 'Accepted on ${DateFormat('MMM dd, yyyy').format(profile.betaConsentTimestamp!)}. You can opt-out at any time.'
                    : 'Review and accept the beta consent notice before participating. Guardians must approve minors.',
              ),
            ),
            if (profile.isBetaTester) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.push('/beta-feedback'),
                    icon: const Icon(Icons.feedback_outlined),
                    label: const Text('Send Feedback'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => _showBetaInstructionsSheet(context),
                    icon: const Icon(Icons.menu_book_outlined),
                    label: const Text('View Tester Guide'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(isDark ? 0.15 : 0.35),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Beta builds are distributed through Firebase App Distribution to the "Internal" and "School Ambassadors" groups. Ensure your invitation email stays active to keep receiving builds.',
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

  Future<void> _handleBetaToggle(
    BuildContext context,
    WidgetRef ref,
    UserProfile profile,
    bool enable,
  ) async {
    final userRepository = ref.read(userRepositoryProvider);

    if (enable && profile.betaConsentGiven != true) {
      final accepted = await _showBetaConsentDialog(context);
      if (!accepted) {
        return;
      }
    }

    final updates = <String, dynamic>{
      'isBetaTester': enable,
    };

    if (enable && profile.betaConsentGiven != true) {
      updates['betaConsentGiven'] = true;
      updates['betaConsentTimestamp'] = Timestamp.fromDate(DateTime.now());
    }

    try {
      await userRepository.updateUserProfile(profile.uid, updates);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  enable
                      ? "You're now part of the TeenTalk beta program!"
                      : 'You have left the beta program.',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              const Expanded(
                child: Text('Unable to update beta status. Please try again.'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<bool> _showBetaConsentDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            bool consentChecked = false;
            return StatefulBuilder(
              builder: (context, setState) {
                return AlertDialog(
                  title: const Text('Beta Testing Consent'),
                  content: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Thanks for volunteering to test TeenTalk. Please review the key points before opting in.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 16),
                        _buildInstructionItem(
                          context,
                          Icons.warning_amber_rounded,
                          'Pre-release software',
                          'Beta builds may contain bugs or incomplete features. Provide detailed feedback when something breaks.',
                        ),
                        _buildInstructionItem(
                          context,
                          Icons.privacy_tip_outlined,
                          'Privacy promise',
                          'Feedback is stored securely in Firestore and only used to improve TeenTalk beta quality.',
                        ),
                        _buildInstructionItem(
                          context,
                          Icons.family_restroom,
                          'Guardian approval',
                          'If you are under 18, confirm that your guardian agrees to your participation in the beta program.',
                        ),
                        CheckboxListTile(
                          value: consentChecked,
                          onChanged: (value) => setState(() => consentChecked = value ?? false),
                          contentPadding: EdgeInsets.zero,
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text('I consent to participate in the TeenTalk beta program.'),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogContext).pop(false),
                      child: const Text('Cancel'),
                    ),
                    FilledButton(
                      onPressed: consentChecked
                          ? () => Navigator.of(dialogContext).pop(true)
                          : null,
                      child: const Text('Accept & Join'),
                    ),
                  ],
                );
              },
            );
          },
        ) ??
        false;
  }

  Future<void> _showBetaInstructionsSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        final theme = Theme.of(bottomSheetContext);
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: MediaQuery.of(bottomSheetContext).padding.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'TeenTalk Beta Tester Guide',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'A detailed handbook lives in docs/beta/tester-guide.md. Use this quick overview to get started.',
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 20),
                Text(
                  'Getting set up',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildInstructionItem(
                  bottomSheetContext,
                  Icons.mail_outline,
                  'Accept the invitation',
                  'Open the Firebase App Distribution invite email and log in with the same email tied to your TeenTalk profile.',
                ),
                _buildInstructionItem(
                  bottomSheetContext,
                  Icons.download_rounded,
                  'Install the tester app',
                  'Use Firebase App Tester (Android) or TestFlight (iOS) to download the latest TeenTalk beta build.',
                ),
                _buildInstructionItem(
                  bottomSheetContext,
                  Icons.assignment_turned_in_outlined,
                  'Complete the dry run',
                  'Run through the smoke checklist (login, posting, messaging, notifications) and note any issues.',
                ),
                const SizedBox(height: 20),
                Text(
                  'Sharing feedback',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                _buildInstructionItem(
                  bottomSheetContext,
                  Icons.feedback_outlined,
                  'Use the in-app form',
                  'Tap “Send Feedback” to report bugs or suggestions. Include device details, screenshots, and steps to reproduce.',
                ),
                _buildInstructionItem(
                  bottomSheetContext,
                  Icons.archive_outlined,
                  'Track responses',
                  'All submissions are stored in the betaFeedback Firestore collection. Our team responds via the app or email.',
                ),
                _buildInstructionItem(
                  bottomSheetContext,
                  Icons.privacy_tip,
                  'Manage consent',
                  'Opt-out at any time from the profile beta card. This stops new distributions to your tester email.',
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => Navigator.of(bottomSheetContext).pop(),
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Got it'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInstructionItem(
    BuildContext context,
    IconData icon,
    String title,
    String description,
  ) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
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

  Widget _buildTutorialCard(BuildContext context, WidgetRef ref, bool isDark) {
    final theme = Theme.of(context);
    final tutorialState = ref.watch(tutorialControllerProvider);
    
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.help_outline,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Tutorial dell\'App',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              tutorialState.hasCompleted
                  ? 'Hai completato il tutorial! Puoi riavviarlo per rivedere le funzionalità principali.'
                  : 'Scopri come utilizzare l\'app con una guida interattiva.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(tutorialControllerProvider.notifier).reset();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Tutorial riavviato! Torna alla home per iniziare.'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                icon: const Icon(Icons.replay),
                label: Text(
                  tutorialState.hasCompleted ? 'Riavvia Tutorial' : 'Avvia Tutorial',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
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

  void _openLegalDocument(BuildContext context, LegalDocumentType type) {
    context.push('/legal/${type.routeSegment}');
  }
}

