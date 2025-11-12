import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/models/auth_user.dart' as auth_models;
import '../features/auth/presentation/providers/auth_provider.dart';
import 'push_notifications_provider.dart';

class PushNotificationsListener extends ConsumerStatefulWidget {
  final Widget child;

  const PushNotificationsListener({
    required this.child,
    super.key,
  });

  @override
  ConsumerState<PushNotificationsListener> createState() =>
      _PushNotificationsListenerState();
}

class _PushNotificationsListenerState
    extends ConsumerState<PushNotificationsListener> {
  ProviderSubscription<auth_models.AuthState>? _authSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListeners();
    });
  }

  void _setupListeners() {
    final service = ref.read(pushNotificationsServiceProvider);

    _authSubscription = ref.listenManual(
      authStateProvider,
      (previous, next) {
        final previousUser = previous?.user;
        final currentUser = next.user;

        if (currentUser != null && next.isAuthenticated) {
          if (previousUser?.uid != currentUser.uid) {
            unawaited(service.onUserSignedIn(currentUser.uid));
          } else {
            unawaited(service.syncToken(forceRefresh: false));
          }
        } else if (previousUser != null &&
            (next.user == null || !next.isAuthenticated)) {
          unawaited(service.onUserSignedOut());
        }
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.close());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
