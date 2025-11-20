import 'package:flutter/material.dart';

class PrivacyPreferencesStep extends StatefulWidget {

  const PrivacyPreferencesStep({
    super.key,
    required this.allowAnonymousPosts,
    required this.profileVisible,
    this.analyticsEnabled = true,
    this.prefersReducedMotion = false,
    this.prefersHighContrast = false,
    this.allowHeavyAnimations = false,
    required this.onAllowAnonymousPostsChanged,
    required this.onProfileVisibleChanged,
    required this.onAnalyticsEnabledChanged,
    required this.onPrefersReducedMotionChanged,
    required this.onPrefersHighContrastChanged,
    required this.onAllowHeavyAnimationsChanged,
    required this.onComplete,
    required this.onBack,
    required this.isSubmitting,
  });
  final bool allowAnonymousPosts;
  final bool profileVisible;
  final bool analyticsEnabled;
  final bool prefersReducedMotion;
  final bool prefersHighContrast;
  final bool allowHeavyAnimations;
  final Function(bool) onAllowAnonymousPostsChanged;
  final Function(bool) onProfileVisibleChanged;
  final Function(bool) onAnalyticsEnabledChanged;
  final Function(bool) onPrefersReducedMotionChanged;
  final Function(bool) onPrefersHighContrastChanged;
  final Function(bool) onAllowHeavyAnimationsChanged;
  final VoidCallback onComplete;
  final VoidCallback onBack;
  final bool isSubmitting;

  @override
  State<PrivacyPreferencesStep> createState() => _PrivacyPreferencesStepState();
}

class _PrivacyPreferencesStepState extends State<PrivacyPreferencesStep> {
  late bool _allowAnonymousPosts;
  late bool _profileVisible;
  late bool _analyticsEnabled;
  late bool _prefersReducedMotion;
  late bool _prefersHighContrast;
  late bool _allowHeavyAnimations;

  @override
  void initState() {
    super.initState();
    _allowAnonymousPosts = widget.allowAnonymousPosts;
    _profileVisible = widget.profileVisible;
    _analyticsEnabled = widget.analyticsEnabled;
    _prefersReducedMotion = widget.prefersReducedMotion;
    _prefersHighContrast = widget.prefersHighContrast;
    _allowHeavyAnimations = widget.allowHeavyAnimations;
  }

  void _handleComplete() {
    widget.onAllowAnonymousPostsChanged(_allowAnonymousPosts);
    widget.onProfileVisibleChanged(_profileVisible);
    widget.onAnalyticsEnabledChanged(_analyticsEnabled);
    widget.onPrefersReducedMotionChanged(_prefersReducedMotion);
    widget.onPrefersHighContrastChanged(_prefersHighContrast);
    widget.onAllowHeavyAnimationsChanged(_allowHeavyAnimations);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 32),
          const Icon(
            Icons.privacy_tip_outlined,
            size: 80,
            color: Colors.blue,
          ),
          const SizedBox(height: 24),
          Text(
            'Privacy Preferences',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Customize how you interact on TeenTalk',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Card(
                    child: SwitchListTile(
                      value: _allowAnonymousPosts,
                      onChanged: (value) {
                        setState(() => _allowAnonymousPosts = value);
                      },
                      title: const Text('Allow Anonymous Posts'),
                      subtitle: const Text(
                        'You can create posts without revealing your nickname',
                      ),
                      secondary: const Icon(Icons.visibility_off),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_allowAnonymousPosts)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'All your posts will show your nickname',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Card(
                    child: SwitchListTile(
                      value: _profileVisible,
                      onChanged: (value) {
                        setState(() => _profileVisible = value);
                      },
                      title: const Text('Profile Visible'),
                      subtitle: const Text(
                        'Other users can view your profile',
                      ),
                      secondary: const Icon(Icons.person),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_profileVisible)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Your profile will be hidden from other users',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  Card(
                    child: SwitchListTile(
                      value: _analyticsEnabled,
                      onChanged: (value) {
                        setState(() => _analyticsEnabled = value);
                      },
                      title: const Text('Allow Analytics'),
                      subtitle: const Text(
                        'Share anonymized usage analytics to help improve TeenTalk',
                      ),
                      secondary: const Icon(Icons.analytics_outlined),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!_analyticsEnabled)
                    Container(
                      padding: const EdgeInsets.all(12),
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.privacy_tip_outlined, color: Colors.orange),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Analytics help us understand feature usage. Turning this off means fewer insights for improvements.',
                              style: TextStyle(color: Colors.orange),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 2),
                  const SizedBox(height: 8),
                  Text(
                    'Accessibility',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: SwitchListTile(
                      value: _prefersReducedMotion,
                      onChanged: (value) {
                        setState(() => _prefersReducedMotion = value);
                      },
                      title: const Text('Reduced Motion'),
                      subtitle: const Text(
                        'Minimize animations and transitions',
                      ),
                      secondary: const Icon(Icons.motion_photos_off),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: SwitchListTile(
                      value: _prefersHighContrast,
                      onChanged: (value) {
                        setState(() => _prefersHighContrast = value);
                      },
                      title: const Text('High Contrast'),
                      subtitle: const Text(
                        'Increase visual contrast for better readability',
                      ),
                      secondary: const Icon(Icons.contrast),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Divider(thickness: 2),
                  const SizedBox(height: 8),
                  Text(
                    'Developer Options',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    child: SwitchListTile(
                      value: _allowHeavyAnimations,
                      onChanged: (value) {
                        setState(() => _allowHeavyAnimations = value);
                      },
                      title: const Text('Heavy Animations (Beta)'),
                      subtitle: const Text(
                        'Enable experimental animations and visual effects',
                      ),
                      secondary: const Icon(Icons.animation),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: Colors.blue.shade50,
                    child: const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.settings, color: Colors.blue),
                              SizedBox(width: 8),
                              Text(
                                'You can change these settings',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Text(
                            'These preferences can be updated anytime from your profile settings.',
                            style: TextStyle(color: Colors.blue),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.isSubmitting ? null : widget.onBack,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: widget.isSubmitting ? null : _handleComplete,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: widget.isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Complete'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
