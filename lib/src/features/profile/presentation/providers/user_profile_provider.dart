import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/user_profile.dart';

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final uid = ref.watch(authStateProvider.select((state) => state.user?.uid));
  final userRepository = ref.watch(userRepositoryProvider);

  if (uid == null) {
    debugPrint('👤 USER PROFILE PROVIDER: No auth user, returning null stream');
    return Stream.value(null);
  }
  
  debugPrint('👤 USER PROFILE PROVIDER: Watching profile for uid=$uid');
  
  // Add timeout to prevent indefinite loading
  return userRepository.watchUserProfile(uid).map((profile) {
    debugPrint('👤 USER PROFILE PROVIDER: Stream emitted profile:');
    debugPrint('   - hasProfile: ${profile != null}');
    debugPrint('   - onboardingComplete: ${profile?.onboardingComplete}');
    debugPrint('   - school: ${profile?.school}');
    debugPrint('   - interests: ${profile?.interests}');
    return profile;
  }).timeout(
    const Duration(seconds: 10),
    onTimeout: (sink) {
      debugPrint('👤 USER PROFILE PROVIDER: ⚠️ Timeout after 10 seconds');
      sink.addError(Exception('Failed to load user profile: timeout after 10 seconds'));
    },
  );
});

final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  final profile = userProfile.value;
  return profile != null;
});

final userProfileByIdProvider = StreamProvider.family<UserProfile?, String>((ref, userId) {
  final userRepository = ref.watch(userRepositoryProvider);
  return userRepository.watchUserProfile(userId);
});
