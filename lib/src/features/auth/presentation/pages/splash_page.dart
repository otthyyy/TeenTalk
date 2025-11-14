import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/providers/connectivity_provider.dart';
import '../../../../core/widgets/splash_screen.dart';
import '../../presentation/providers/auth_provider.dart';
import '../../../profile/presentation/providers/user_profile_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  Timer? _timeoutTimer;
  bool _timedOut = false;

  void _restartTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = Timer(const Duration(seconds: 10), () {
      if (!mounted) return;
      final authState = ref.read(authStateProvider);
      final profileState = ref.read(userProfileProvider);
      if (authState.isLoading || profileState.isLoading) {
        setState(() {
          _timedOut = true;
        });
      }
    });
  }

  void _cancelTimeout() {
    _timeoutTimer?.cancel();
    _timeoutTimer = null;
  }

  void _retry() {
    _cancelTimeout();
    setState(() {
      _timedOut = false;
    });
    ref.read(authStateProvider.notifier).clearError();
    ref.invalidate(userProfileProvider);
    ref.invalidate(authStateProvider);
    _restartTimeout();
  }

  @override
  void dispose() {
    _cancelTimeout();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final profileState = ref.watch(userProfileProvider);
    final connectivityState = ref.watch(connectivityStatusProvider);

    final isLoading = authState.isLoading || profileState.isLoading;
    final isOffline = connectivityState.when(
      data: (connected) => !connected,
      loading: () => false,
      error: (_, __) => false,
    );

    if (isLoading && !_timedOut) {
      // Start timeout when entering loading state
      if (_timeoutTimer == null || !(_timeoutTimer?.isActive ?? false)) {
        _restartTimeout();
      }
    } else {
      _cancelTimeout();
      if (_timedOut && !isLoading) {
        // Reset timeout flag once loading completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _timedOut = false;
            });
          }
        });
      }
    }

    String message;
    if (isOffline) {
      message = 'You are offline. Waiting for connection...';
    } else if (authState.isLoading) {
      message = 'Verifying your account...';
    } else if (profileState.isLoading) {
      message = 'Loading your TeenTalk profile...';
    } else if (profileState.hasError || authState.error != null) {
      message = 'We had trouble loading your profile.';
    } else if (_timedOut) {
      message = 'This is taking longer than expected.';
    } else {
      message = 'Preparing TeenTalk...';
    }

    final showRetryButton = _timedOut || profileState.hasError || authState.error != null;

    return SplashScreen(
      message: message,
      showRetryButton: showRetryButton,
      onRetry: showRetryButton ? _retry : null,
    );
  }
}
