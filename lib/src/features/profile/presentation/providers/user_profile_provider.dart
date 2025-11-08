import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/auth_service.dart';
import '../../data/repositories/user_repository.dart';
import '../../domain/models/user_profile.dart';

final userProfileProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);
  final userRepository = ref.watch(userRepositoryProvider);

  return authState.when(
    data: (user) {
      if (user == null) {
        return Stream.value(null);
      }
      return userRepository.watchUserProfile(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

final hasCompletedOnboardingProvider = Provider<bool>((ref) {
  final userProfile = ref.watch(userProfileProvider);
  return userProfile.maybeWhen(
    data: (profile) => profile != null,
    orElse: () => false,
  );
});
