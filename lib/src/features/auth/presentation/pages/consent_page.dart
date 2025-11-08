import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../models/auth_form_state.dart';
import '../../data/models/auth_user.dart';

class ConsentPage extends ConsumerStatefulWidget {
  final AuthUser user;
  final VoidCallback onConsentComplete;

  const ConsentPage({
    super.key,
    required this.user,
    required this.onConsentComplete,
  });

  @override
  ConsumerState<ConsentPage> createState() => _ConsentPageState();
}

class _ConsentPageState extends ConsumerState<ConsentPage> {
  late ConsentState _consentState;

  @override
  void initState() {
    super.initState();
    _consentState = ConsentState(
      parentalConsent: widget.user.isMinor,
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final authState = ref.watch(authStateProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations?.consentGDPR ?? 'Consent'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations?.consentTerms ?? 'Terms & Conditions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 16),
              _buildConsentSection(
                context,
                title: localizations?.consentGDPR ?? 'GDPR Consent',
                description: localizations?.consentGDPRDescription ?? 'I agree to the processing of my personal data',
                value: _consentState.gdprConsent,
                onChanged: (value) {
                  setState(() {
                    _consentState = _consentState.copyWith(gdprConsent: value);
                  });
                },
              ),
              const SizedBox(height: 24),
              _buildConsentSection(
                context,
                title: localizations?.consentPrivacy ?? 'Privacy Policy',
                description: localizations?.consentTerms ?? 'I agree to the Terms of Service',
                value: _consentState.termsConsent,
                onChanged: (value) {
                  setState(() {
                    _consentState = _consentState.copyWith(termsConsent: value);
                  });
                },
              ),
              if (widget.user.isMinor) const SizedBox(height: 24),
              if (widget.user.isMinor)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    border: Border.all(color: Colors.orange.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              localizations?.onboardingMinorWarning ?? 'You are under 18',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildConsentSection(
                        context,
                        title: localizations?.consentParental ?? 'Parental Consent',
                        description: localizations?.consentParentalDescription ?? 'A parent or guardian authorizes',
                        value: _consentState.parentalConsent,
                        onChanged: (value) {
                          setState(() {
                            _consentState = _consentState.copyWith(parentalConsent: value);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              if (authState.error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    border: Border.all(color: Colors.red.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          authState.error!,
                          style: TextStyle(color: Colors.red.shade800),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: authState.isLoading ? null : _handleSubmit,
                  child: authState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(localizations?.consentAccept ?? 'Accept'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: authState.isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text(localizations?.consentDecline ?? 'Decline'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConsentSection(
    BuildContext context, {
    required String title,
    required String description,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CheckboxListTile(
          value: value,
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          title: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        Padding(
          padding: const EdgeInsets.only(left: 40),
          child: Text(
            description,
            style: Theme.of(context).textTheme.bodySmall,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Future<void> _handleSubmit() async {
    final localizations = AppLocalizations.of(context);

    if (!_consentState.gdprConsent || !_consentState.termsConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.consentRequired ?? 'You must accept the terms',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (widget.user.isMinor && !_consentState.parentalConsent) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localizations?.consentParentalRequired ?? 'Parental consent required',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.recordConsent(
        gdprConsent: _consentState.gdprConsent,
        termsConsent: _consentState.termsConsent,
        parentalConsent: _consentState.parentalConsent || !widget.user.isMinor,
      );

      if (mounted) {
        widget.onConsentComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
