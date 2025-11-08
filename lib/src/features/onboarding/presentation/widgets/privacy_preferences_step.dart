import 'package:flutter/material.dart';

class PrivacyPreferencesStep extends StatefulWidget {
  final bool allowAnonymousPosts;
  final bool profileVisible;
  final Function(bool) onAllowAnonymousPostsChanged;
  final Function(bool) onProfileVisibleChanged;
  final VoidCallback onComplete;
  final VoidCallback onBack;
  final bool isSubmitting;

  const PrivacyPreferencesStep({
    super.key,
    required this.allowAnonymousPosts,
    required this.profileVisible,
    required this.onAllowAnonymousPostsChanged,
    required this.onProfileVisibleChanged,
    required this.onComplete,
    required this.onBack,
    required this.isSubmitting,
  });

  @override
  State<PrivacyPreferencesStep> createState() => _PrivacyPreferencesStepState();
}

class _PrivacyPreferencesStepState extends State<PrivacyPreferencesStep> {
  late bool _allowAnonymousPosts;
  late bool _profileVisible;

  @override
  void initState() {
    super.initState();
    _allowAnonymousPosts = widget.allowAnonymousPosts;
    _profileVisible = widget.profileVisible;
  }

  void _handleComplete() {
    widget.onAllowAnonymousPostsChanged(_allowAnonymousPosts);
    widget.onProfileVisibleChanged(_profileVisible);
    widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
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
