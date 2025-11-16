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
  
  int retryAttempt = 0;

  Stream<UserProfile?> profileStream() async* {
    while (true) {
      final attemptNumber = retryAttempt + 1;
      debugPrint('👤 USER PROFILE PROVIDER: Starting profile stream (attempt $attemptNumber)');
      try {
        final stream = userRepository.watchUserProfile(uid).timeout(
          const Duration(seconds: 20),
          onTimeout: (sink) {
            debugPrint('👤 USER PROFILE PROVIDER: ⚠️ Timeout after 20 seconds (attempt $attemptNumber)');
            sink.addError(
              TimeoutException('Failed to load user profile: timeout after 20 seconds'),
            );
          },
        );

        await for (final profile in stream) {
          retryAttempt = 0;
          debugPrint('👤 USER PROFILE PROVIDER: Stream emitted profile:');
          debugPrint('   - hasProfile: ${profile != null}');
          debugPrint('   - onboardingComplete: ${profile?.onboardingComplete}');
          debugPrint('   - school: ${profile?.school}');
          debugPrint('   - interests: ${profile?.interests}');
          yield profile;
        }

        // Stream completed normally, stop retrying
        break;
      } on TimeoutException {
        retryAttempt += 1;
        final delaySeconds = retryAttempt >= 4 ? 20 : retryAttempt * 5;
        debugPrint('👤 USER PROFILE PROVIDER: 🔁 Retrying in ${delaySeconds}s (retry #$retryAttempt)');
        await Future.delayed(Duration(seconds: delaySeconds));
      } catch (error, stackTrace) {
        debugPrint('👤 USER PROFILE PROVIDER: ❌ Unexpected error: $error');
        Error.throwWithStackTrace(error, stackTrace);
      }
    }
  }

  return profileStream();
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
