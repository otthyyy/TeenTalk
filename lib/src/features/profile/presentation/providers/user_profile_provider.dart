import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/user_profile.dart';

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  if (authState.user == null) {
    return Stream.value(null);
  }
  
  // Add timeout to prevent indefinite loading
  return userRepository.watchUserProfile(authState.user!.uid).timeout(
    const Duration(seconds: 10),
    onTimeout: (sink) {
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
