import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/auth_provider.dart';

class SocialAuthButtons extends ConsumerWidget {
  const SocialAuthButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final localizations = AppLocalizations.of(context);
    final authState = ref.watch(authStateProvider);
    final authNotifier = ref.read(authStateProvider.notifier);

    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
          _buildSocialButton(
            context,
            label: localizations?.authGoogleSignIn ?? 'Sign in with Google',
            icon: 'assets/icons/google.svg',
            onPressed: authState.isLoading
                ? null
                : () => _handleGoogleSignIn(context, ref),
            isLoading: authState.isLoading,
          ),
          const SizedBox(height: 16),
          _buildSocialButton(
            context,
            label: localizations?.authAnonymously ?? 'Continue Anonymously',
            icon: 'assets/icons/incognito.svg',
            onPressed: authState.isLoading
                ? null
                : () => _handleAnonymousSignIn(context, ref),
            isLoading: authState.isLoading,
          ),
          const SizedBox(height: 24),
          Divider(
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            localizations?.consentGDPR ?? 'Terms & Conditions',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton(
    BuildContext context, {
    required String label,
    required String icon,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Image.asset(
                icon,
                width: 20,
                height: 20,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(
                    label.contains('Google')
                        ? Icons.account_circle
                        : Icons.person,
                  );
                },
              ),
        label: Text(label),
      ),
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.signInWithGoogle();

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAnonymousSignIn(BuildContext context, WidgetRef ref) async {
    try {
      final authNotifier = ref.read(authStateProvider.notifier);
      await authNotifier.signInAnonymously();

      if (context.mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (context.mounted) {
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
