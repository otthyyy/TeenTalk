import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ConsentStep extends StatefulWidget {
  final bool? isMinor;
  final String? guardianContact;
  final bool parentalConsentGiven;
  final bool privacyConsentGiven;
  final Function(bool?) onIsMinorChanged;
  final Function(String?) onGuardianContactChanged;
  final Function(bool) onParentalConsentChanged;
  final Function(bool) onPrivacyConsentChanged;
  final VoidCallback onNext;
  final VoidCallback onBack;

  const ConsentStep({
    super.key,
    required this.isMinor,
    required this.guardianContact,
    required this.parentalConsentGiven,
    required this.privacyConsentGiven,
    required this.onIsMinorChanged,
    required this.onGuardianContactChanged,
    required this.onParentalConsentChanged,
    required this.onPrivacyConsentChanged,
    required this.onNext,
    required this.onBack,
  });

  @override
  State<ConsentStep> createState() => _ConsentStepState();
}

class _ConsentStepState extends State<ConsentStep> {
  final _formKey = GlobalKey<FormState>();
  final _guardianContactController = TextEditingController();
  bool? _isMinor;
  bool _parentalConsent = false;
  bool _privacyConsent = false;

  @override
  void initState() {
    super.initState();
    _isMinor = widget.isMinor;
    _parentalConsent = widget.parentalConsentGiven;
    _privacyConsent = widget.privacyConsentGiven;
    _guardianContactController.text = widget.guardianContact ?? '';
  }

  @override
  void dispose() {
    _guardianContactController.dispose();
    super.dispose();
  }

  bool _canProceed() {
    if (_isMinor == null) return false;
    if (!_privacyConsent) return false;
    if (_isMinor == true) {
      return _parentalConsent &&
          _guardianContactController.text.trim().isNotEmpty;
    }
    return true;
  }

  void _handleNext() {
    if (_formKey.currentState!.validate() && _canProceed()) {
      widget.onIsMinorChanged(_isMinor);
      widget.onGuardianContactChanged(_guardianContactController.text.trim());
      widget.onParentalConsentChanged(_parentalConsent);
      widget.onPrivacyConsentChanged(_privacyConsent);
      widget.onNext();
    }
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'TeenTalk Privacy Policy\n\n'
            '1. Data Collection\n'
            'We collect and process your personal data including nickname, gender, school, and usage data.\n\n'
            '2. Data Usage\n'
            'Your data is used to provide and improve our services, ensure platform safety, and comply with legal obligations.\n\n'
            '3. Data Storage\n'
            'Data is stored securely using industry-standard encryption and security practices.\n\n'
            '4. Your Rights\n'
            'Under GDPR, you have the right to access, correct, delete, and port your data. You can also withdraw consent at any time.\n\n'
            '5. Contact\n'
            'For privacy concerns, contact us at privacy@teentalk.app',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'TeenTalk Terms of Service\n\n'
            '1. Acceptance of Terms\n'
            'By using TeenTalk, you agree to these terms.\n\n'
            '2. User Conduct\n'
            'Users must respect others, not share inappropriate content, and follow community guidelines.\n\n'
            '3. Content Moderation\n'
            'We reserve the right to moderate and remove content that violates our policies.\n\n'
            '4. Account Termination\n'
            'We may suspend or terminate accounts that violate these terms.\n\n'
            '5. Disclaimer\n'
            'The service is provided "as is" without warranties.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            const Icon(
              Icons.verified_user_outlined,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            Text(
              'Privacy & Consent',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Your safety and privacy are important to us',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Age Confirmation',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text('Are you under 18 years old?'),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('Yes'),
                                    value: true,
                                    groupValue: _isMinor,
                                    onChanged: (value) {
                                      setState(() => _isMinor = value);
                                    },
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<bool>(
                                    title: const Text('No'),
                                    value: false,
                                    groupValue: _isMinor,
                                    onChanged: (value) {
                                      setState(() => _isMinor = value);
                                    },
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    if (_isMinor == true) ...[
                      const SizedBox(height: 16),
                      Card(
                        color: Colors.orange.shade50,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(Icons.family_restroom,
                                      color: Colors.orange),
                                  SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Parental Consent Required',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              TextFormField(
                                controller: _guardianContactController,
                                decoration: const InputDecoration(
                                  labelText: 'Parent/Guardian Email',
                                  hintText: 'parent@example.com',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.email),
                                  filled: true,
                                  fillColor: Colors.white,
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (_isMinor == true &&
                                      (value == null || value.trim().isEmpty)) {
                                    return 'Guardian contact is required';
                                  }
                                  if (value != null &&
                                      value.trim().isNotEmpty &&
                                      !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                          .hasMatch(value)) {
                                    return 'Please enter a valid email';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              CheckboxListTile(
                                value: _parentalConsent,
                                onChanged: (value) {
                                  setState(
                                      () => _parentalConsent = value ?? false);
                                },
                                title: const Text(
                                  'I confirm that my parent/guardian has given consent for me to use TeenTalk',
                                ),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Privacy Consent (Required)',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            CheckboxListTile(
                              value: _privacyConsent,
                              onChanged: (value) {
                                setState(() => _privacyConsent = value ?? false);
                              },
                              title: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    const TextSpan(
                                      text: 'I agree to the ',
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = _showPrivacyPolicy,
                                    ),
                                    const TextSpan(text: ' and '),
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: const TextStyle(
                                        color: Colors.blue,
                                        decoration: TextDecoration.underline,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = _showTermsOfService,
                                    ),
                                  ],
                                ),
                              ),
                              contentPadding: EdgeInsets.zero,
                              controlAffinity: ListTileControlAffinity.leading,
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Your GDPR Rights:',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  SizedBox(height: 4),
                                  Text('• Access your data at any time'),
                                  Text('• Request data correction or deletion'),
                                  Text('• Withdraw consent'),
                                  Text('• Data portability'),
                                ],
                              ),
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
                    onPressed: widget.onBack,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _canProceed() ? _handleNext : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Next'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
