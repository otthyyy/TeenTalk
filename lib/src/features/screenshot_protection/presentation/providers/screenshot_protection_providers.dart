import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/core/services/analytics_provider.dart';
import 'package:teen_talk_app/src/core/services/analytics_service.dart';
import 'package:teen_talk_app/src/features/profile/data/repositories/user_repository.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/user_profile.dart';
import 'package:teen_talk_app/src/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:teen_talk_app/src/features/screenshot_protection/services/screenshot_protection_service.dart';

final screenshotProtectionServiceProvider = Provider<ScreenshotProtectionService>((ref) {
  final service = ScreenshotProtectionService();
  ref.onDispose(service.dispose);
  return service;
});

final screenshotProtectionStateProvider = StateNotifierProvider<ScreenshotProtectionStateNotifier, ScreenshotProtectionState>((ref) {
  final service = ref.read(screenshotProtectionServiceProvider);
  final analytics = ref.read(analyticsServiceProvider);
  final userProfile = ref.watch(userProfileProvider).value;
  return ScreenshotProtectionStateNotifier(service: service, analyticsService: analytics, userProfile: userProfile);
});

class ScreenshotProtectionState {
  ScreenshotProtectionState({
    required this.isEnabled,
    required this.isIosCaptureActive,
    this.showWarning = false,
  });

  final bool isEnabled;
  final bool isIosCaptureActive;
  final bool showWarning;

  ScreenshotProtectionState copyWith({
    bool? isEnabled,
    bool? isIosCaptureActive,
    bool? showWarning,
  }) {
    return ScreenshotProtectionState(
      isEnabled: isEnabled ?? this.isEnabled,
      isIosCaptureActive: isIosCaptureActive ?? this.isIosCaptureActive,
      showWarning: showWarning ?? this.showWarning,
    );
  }
}

class ScreenshotProtectionStateNotifier extends StateNotifier<ScreenshotProtectionState> {
  ScreenshotProtectionStateNotifier({
    required this.service,
    required this.analyticsService,
    required this.userProfile,
  }) : super(ScreenshotProtectionState(isEnabled: userProfile?.screenshotProtectionEnabled ?? true, isIosCaptureActive: false)) {
    _init();
  }

  final ScreenshotProtectionService service;
  final AnalyticsService analyticsService;
  final UserProfile? userProfile;
  StreamSubscription<bool>? _captureStatusSubscription;
  StreamSubscription<bool>? _screenshotDetectedSubscription;

  Future<void> _init() async {
    await service.initialize();

    final isEnabled = userProfile?.screenshotProtectionEnabled ?? true;
    if (isEnabled) {
      await service.enableProtection();
    }
    
    _captureStatusSubscription = service.screenCaptureStatus.listen((isCaptured) {
      state = state.copyWith(isIosCaptureActive: isCaptured);
      analyticsService.logEvent(name: 'screen_capture_detected', parameters: {
        'platform': 'ios',
        'is_captured': isCaptured,
      });
    });

    _screenshotDetectedSubscription = service.screenshotDetected.listen((_) {
      state = state.copyWith(showWarning: true);
      analyticsService.logEvent(name: 'screenshot_attempt_detected');
    });
  }

  Future<void> toggleProtection(bool enable, WidgetRef ref) async {
    if (enable) {
      await service.enableProtection();
      analyticsService.logEvent(name: 'screenshot_protection_enabled');
    } else {
      await service.disableProtection();
      analyticsService.logEvent(name: 'screenshot_protection_disabled');
    }
    state = state.copyWith(isEnabled: enable);

    await _savePreference(enable, ref);
  }

  Future<void> _savePreference(bool enable, WidgetRef ref) async {
    final repo = ref.read(userRepositoryProvider);
    if (userProfile == null) return;

    await repo.updateUserProfile(userProfile!.uid, {'screenshotProtectionEnabled': enable});
  }

  void dismissWarning() {
    state = state.copyWith(showWarning: false);
  }

  @override
  void dispose() {
    _captureStatusSubscription?.cancel();
    _screenshotDetectedSubscription?.cancel();
    service.dispose();
    super.dispose();
  }
}
