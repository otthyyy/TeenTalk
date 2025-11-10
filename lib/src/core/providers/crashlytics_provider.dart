import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/data/models/auth_user.dart' as auth_models;
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/profile/presentation/providers/user_profile_provider.dart';
import '../services/crashlytics_service.dart';

final crashlyticsServiceProvider = Provider<CrashlyticsService>((ref) {
  throw UnimplementedError(
    'crashlyticsServiceProvider must be overridden in main.dart',
  );
});

final crashlyticsSyncProvider = Provider<void>((ref) {
  final service = ref.watch(crashlyticsServiceProvider);

  ref.listen<auth_models.AuthState>(authStateProvider, (previous, next) {
    final user = next.user;
    if (user != null) {
      unawaited(service.setUserId(user.uid));
    } else {
      unawaited(service.clearUserId());
    }
  });

  ref.listen(userProfileProvider, (previous, next) {
    next.whenData((profile) {
      if (profile == null) {
        unawaited(service.setCollectionEnabled(false));
        return;
      }

      unawaited(service.setCollectionEnabled(profile.crashReportingEnabled));

      if (profile.crashReportingEnabled) {
        if (profile.school != null && profile.school!.isNotEmpty) {
          unawaited(service.setCustomKey('school', profile.school!));
        } else {
          unawaited(service.setCustomKey('school', 'unknown'));
        }
        unawaited(service.setCustomKey('is_minor', profile.isMinor ?? false));
        unawaited(
          service.setCustomKey('onboarding_complete', profile.onboardingComplete),
        );
      }
    });
  });
});
