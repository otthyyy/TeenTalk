import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/data/models/auth_user.dart' as auth_models;
import '../features/auth/presentation/providers/auth_provider.dart';
import 'push_notifications_provider.dart';

/// Provider that wires push notifications service to authentication events
final pushNotificationsControllerProvider = Provider<void>((ref) {
  final service = ref.watch(pushNotificationsServiceProvider);

  ref.listen<auth_models.AuthState>(authStateProvider, (previous, next) {
    final previousUser = previous?.user;
    final currentUser = next.user;

    if (currentUser != null && next.isAuthenticated) {
      if (previousUser?.uid != currentUser.uid) {
        unawaited(service.onUserSignedIn(currentUser.uid));
      } else {
        unawaited(service.syncToken(forceRefresh: false));
      }
    } else if (previousUser != null && (next.user == null || !next.isAuthenticated)) {
      unawaited(service.onUserSignedOut());
    }
  });

  return null;
});
