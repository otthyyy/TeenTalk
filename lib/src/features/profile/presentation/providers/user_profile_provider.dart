import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/user_profile.dart';

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  if (authState.user == null) {
    print('👤 USER PROFILE PROVIDER: No auth user, returning null');
    return Stream.value(null);
  }
  
  print('👤 USER PROFILE PROVIDER: Watching profile for uid=${authState.user!.uid}');
  
  // Add timeout to prevent indefinite loading
  return userRepository.watchUserProfile(authState.user!.uid).map((profile) {
    print('👤 USER PROFILE PROVIDER: Stream emitted profile:');
    print('   - hasProfile: ${profile != null}');
    print('   - onboardingComplete: ${profile?.onboardingComplete}');
    print('   - school: ${profile?.school}');
    print('   - interests: ${profile?.interests}');
    return profile;
  }).timeout(
    const Duration(seconds: 10),
    onTimeout: (sink) {
      print('👤 USER PROFILE PROVIDER: ⚠️ Timeout after 10 seconds');
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
