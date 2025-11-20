import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/profile/domain/models/user_profile.dart';
import '../../features/profile/presentation/providers/user_profile_provider.dart';
import '../providers/motion_preferences_provider.dart';

class MotionListener extends ConsumerStatefulWidget {
  const MotionListener({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<MotionListener> createState() => _MotionListenerState();
}

class _MotionListenerState extends ConsumerState<MotionListener> {
  ProviderSubscription<AsyncValue<UserProfile?>>? _profileSubscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _setupListeners();
    });
  }

  void _setupListeners() {
    final service = ref.read(motionPreferencesServiceProvider);

    _profileSubscription = ref.listenManual(
      userProfileProvider,
      (previous, next) {
        next.whenData((profile) {
          if (profile == null) return;

          unawaited(service.syncWithUserProfile(
            prefersReducedMotion: profile.prefersReducedMotion,
            prefersHighContrast: profile.prefersHighContrast,
            allowHeavyAnimations: profile.allowHeavyAnimations,
          ));
        });
      },
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _profileSubscription?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
