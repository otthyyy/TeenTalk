import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class PhoneAuthForm extends ConsumerStatefulWidget {
  const PhoneAuthForm({super.key});

  @override
  ConsumerState<PhoneAuthForm> createState() => _PhoneAuthFormState();
}

class _PhoneAuthFormState extends ConsumerState<PhoneAuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  String? _verificationId;
  bool _showOTPField = false;
  int _otpResendCount = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final authState = ref.watch(authStateProvider);

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            if (!_showOTPField)
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: localizations?.authPhoneNumber ?? 'Phone Number',
                  hintText: '+1 (555) 000-0000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return localizations?.errorPhoneRequired ?? 'Phone number is required';
                  }
                  if (!RegExp(r'^\+?1?\d{9,15}$').hasMatch(value.replaceAll(RegExp(r'[^\d+]'), ''))) {
                    return localizations?.errorPhoneInvalid ?? 'Invalid phone number';
                  }
                  return null;
                },
              )
            else
              Column(
                children: [
                  TextFormField(
                    controller: _otpController,
                    decoration: InputDecoration(
                      labelText: localizations?.authOTP ?? 'Enter OTP',
                      hintText: '000000',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                      counterText: '',
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return localizations?.errorOTPRequired ?? 'OTP is required';
                      }
                      if (value.length != 6) {
                        return localizations?.errorOTPInvalid ?? 'OTP must be 6 digits';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_otpResendCount > 0)
                    Text(
                      '${localizations?.authResendOTP ?? 'Resend OTP'} in 30s',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                ],
              ),
            const SizedBox(height: 24),
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
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        _showOTPField
                            ? (localizations?.authVerifyOTP ?? 'Verify OTP')
                            : 'Send OTP',
                      ),
              ),
            ),
            if (_showOTPField) const SizedBox(height: 16),
            if (_showOTPField)
              TextButton(
                onPressed: _otpResendCount == 0 ? _resendOTP : null,
                child: Text(localizations?.authResendOTP ?? 'Resend OTP'),
              ),
            if (_showOTPField) const SizedBox(height: 16),
            if (_showOTPField)
              TextButton(
                onPressed: () {
                  setState(() {
                    _showOTPField = false;
                    _otpController.clear();
                    _verificationId = null;
                  });
                },
                child: const Text('Change Phone Number'),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authStateProvider.notifier);
    final localizations = AppLocalizations.of(context);

    try {
      if (!_showOTPField) {
        await authNotifier.verifyPhoneNumber(
          phoneNumber: _phoneController.text.trim(),
          onCodeSent: (verificationId) {
            setState(() {
              _verificationId = verificationId;
              _showOTPField = true;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  localizations?.authOTPSent ?? 'OTP sent to your phone',
                ),
                duration: const Duration(seconds: 2),
              ),
            );
          },
          onError: (error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(error),
                backgroundColor: Colors.red,
              ),
            );
          },
        );
      } else {
        if (_verificationId == null) {
          throw Exception('Verification ID not found');
        }

        await authNotifier.signInWithPhoneOTP(
          verificationId: _verificationId!,
          otp: _otpController.text.trim(),
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      // Error is handled by state
    }
  }

  Future<void> _resendOTP() async {
    final authNotifier = ref.read(authStateProvider.notifier);
    final localizations = AppLocalizations.of(context);

    try {
      _otpResendCount++;
      await authNotifier.verifyPhoneNumber(
        phoneNumber: _phoneController.text.trim(),
        onCodeSent: (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _otpResendCount = 0;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                localizations?.authOTPSent ?? 'OTP sent to your phone',
              ),
              duration: const Duration(seconds: 2),
            ),
          );
        },
        onError: (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
            ),
          );
        },
      );
    } catch (e) {
      // Error handling
    }
  }
}
