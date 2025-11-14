import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:teen_talk_app/src/core/localization/app_localizations.dart';
import '../providers/auth_provider.dart';
import '../models/auth_form_state.dart';

class EmailAuthForm extends ConsumerStatefulWidget {

  const EmailAuthForm({
    super.key,
    required this.isSignUp,
  });
  final bool isSignUp;

  @override
  ConsumerState<EmailAuthForm> createState() => _EmailAuthFormState();
}

class _EmailAuthFormState extends ConsumerState<EmailAuthForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _displayNameController = TextEditingController();
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _displayNameController.dispose();
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
            if (widget.isSignUp)
              TextFormField(
                controller: _displayNameController,
                decoration: InputDecoration(
                  labelText: localizations?.onboardingFirstName ?? 'Display Name',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (widget.isSignUp && (value == null || value.isEmpty)) {
                    return localizations?.errorEmailRequired ?? 'Name is required';
                  }
                  return null;
                },
              ),
            if (widget.isSignUp) const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: localizations?.authEmail ?? 'Email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.email_outlined),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations?.errorEmailRequired ?? 'Email is required';
                }
                if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                    .hasMatch(value)) {
                  return localizations?.errorEmailInvalid ?? 'Invalid email';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: localizations?.authPassword ?? 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.lock_outlined),
                suffixIcon: IconButton(
                  icon: Icon(_showPassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
              ),
              obscureText: !_showPassword,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return localizations?.errorPasswordRequired ?? 'Password is required';
                }
                if (value.length < 8) {
                  return localizations?.errorPasswordTooShort ?? 'Password must be at least 8 characters';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            if (widget.isSignUp)
              TextFormField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: localizations?.authConfirmPassword ?? 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.lock_outlined),
                  suffixIcon: IconButton(
                    icon: Icon(_showConfirmPassword
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined),
                    onPressed: () {
                      setState(() {
                        _showConfirmPassword = !_showConfirmPassword;
                      });
                    },
                  ),
                ),
                obscureText: !_showConfirmPassword,
                validator: (value) {
                  if (widget.isSignUp && (value == null || value.isEmpty)) {
                    return localizations?.errorPasswordRequired ?? 'Confirm password is required';
                  }
                  if (widget.isSignUp &&
                      value != _passwordController.text) {
                    return localizations?.errorPasswordMismatch ?? 'Passwords do not match';
                  }
                  return null;
                },
              ),
            if (widget.isSignUp) const SizedBox(height: 24),
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
                        widget.isSignUp
                            ? (localizations?.authSignUp ?? 'Sign Up')
                            : (localizations?.authSignIn ?? 'Sign In'),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                if (widget.isSignUp) {
                  context.go('/auth');
                } else {
                  context.go('/auth/signup');
                }
              },
              child: Text(
                widget.isSignUp
                    ? (localizations?.authAlreadyHaveAccount ?? 'Already have an account?')
                    : (localizations?.authNoAccount ?? "Don't have an account?"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final authNotifier = ref.read(authStateProvider.notifier);

    try {
      if (widget.isSignUp) {
        await authNotifier.signUpWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          displayName: _displayNameController.text.trim(),
        );

        if (!mounted) return;
        context.go('/onboarding');
      } else {
        await authNotifier.signInWithEmail(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        if (!mounted) return;
        context.go('/feed');
      }
    } catch (e) {
      // Error is handled by state
    }
  }
}
