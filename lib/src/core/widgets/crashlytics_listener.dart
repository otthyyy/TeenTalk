import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/models/auth_user.dart' as auth_models;
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/domain/models/user_profile.dart';
import '../../features/profile/presentation/providers/user_profile_provider.dart';
import '../providers/crashlytics_provider.dart';

class CrashlyticsListener extends ConsumerStatefulWidget {
  final Widget child;

  const CrashlyticsListener({
    required this.child,
    super.key,
  });

  @override
  ConsumerState<CrashlyticsListener> createState() =>
      _CrashlyticsListenerState();
}

class _CrashlyticsListenerState extends ConsumerState<CrashlyticsListener> {
  ProviderSubscription<auth_models.AuthState>? _authSubscription;
  ProviderSubscription<AsyncValue<UserProfile?>>? _profileSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListeners();
    });
  }

  void _setupListeners() {
    final service = ref.read(crashlyticsServiceProvider);

    _authSubscription = ref.listenManual(
      authStateProvider,
      (previous, next) {
        final user = next.user;
        if (user != null) {
          unawaited(service.setUserId(user.uid));
        } else {
          unawaited(service.clearUserId());
        }
      },
      fireImmediately: true,
    );

    _profileSubscription = ref.listenManual(
      userProfileProvider,
      (previous, next) {
        next.whenData((profile) {
          if (profile == null) {
            unawaited(service.setCollectionEnabled(false));
            return;
          }

          unawaited(
              service.setCollectionEnabled(profile.crashReportingEnabled));

          if (profile.crashReportingEnabled) {
            if (profile.school != null && profile.school!.isNotEmpty) {
              unawaited(service.setCustomKey('school', profile.school!));
            } else {
              unawaited(service.setCustomKey('school', 'unknown'));
            }
            unawaited(
                service.setCustomKey('is_minor', profile.isMinor ?? false));
            unawaited(service.setCustomKey(
                'onboarding_complete', profile.onboardingComplete));
          }
        });
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _authSubscription?.close();
    _profileSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
