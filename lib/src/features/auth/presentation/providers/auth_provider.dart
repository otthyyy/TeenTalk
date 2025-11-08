import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/auth_form_state.dart';
import '../../data/models/auth_user.dart';
import '../../data/services/firebase_auth_service.dart';

final firebaseAuthServiceProvider = Provider((ref) {
  return FirebaseAuthService();
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(firebaseAuthServiceProvider).authStateChanges;
});

final currentAuthUserProvider = FutureProvider<AuthUser?>((ref) async {
  return ref.watch(firebaseAuthServiceProvider).getCurrentAuthUser();
});

final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((ref) {
  final authService = ref.watch(firebaseAuthServiceProvider);
  return AuthStateNotifier(authService);
});

class AuthStateNotifier extends StateNotifier<AuthState> {
  final FirebaseAuthService _authService;

  AuthStateNotifier(this._authService) : super(AuthState.initial()) {
    _init();
  }

  void _init() {
    _authService.authStateChanges.listen((user) {
      if (user != null) {
        state = state.copyWith(
          isAuthenticated: true,
          user: AuthUser(
            uid: user.uid,
            email: user.email,
            phoneNumber: user.phoneNumber,
            displayName: user.displayName,
            photoURL: user.photoURL,
            emailVerified: user.emailVerified,
            isAnonymous: user.isAnonymous,
            createdAt: user.metadata.creationTime ?? DateTime.now(),
            authMethods: user.providerData.map((p) => p.providerId).toList(),
          ),
        );
      } else {
        state = AuthState.initial();
      }
    });
  }

  Future<void> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        requiresOnboarding: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signInWithGoogle();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        requiresOnboarding: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId) onCodeSent,
    required Function(String error) onError,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        onCodeSent: onCodeSent,
        onError: (error) {
          onError(error.message ?? 'Phone verification failed');
        },
        onVerificationComplete: (credential) {
          // Handled in sign in with phone OTP
        },
      );
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signInWithPhoneOTP({
    required String verificationId,
    required String otp,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signInWithPhoneOTP(
        verificationId: verificationId,
        otp: otp,
      );
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        requiresOnboarding: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signInAnonymously() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.signInAnonymously();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        requiresOnboarding: true,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> linkWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _authService.linkWithGoogle();
      state = state.copyWith(
        isLoading: false,
        user: user,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> recordConsent({
    required bool gdprConsent,
    required bool termsConsent,
    required bool parentalConsent,
  }) async {
    final uid = state.user?.uid;
    if (uid == null) return;

    state = state.copyWith(isLoading: true);
    try {
      await _authService.recordConsent(
        uid: uid,
        gdprConsent: gdprConsent,
        termsConsent: termsConsent,
        parentalConsent: parentalConsent,
      );

      if (state.user != null) {
        final updatedUser = state.user!.copyWith(
          gdprConsentProvided: gdprConsent,
          termsAccepted: termsConsent,
          parentalConsentProvided: parentalConsent,
        );
        state = state.copyWith(
          isLoading: false,
          user: updatedUser,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> sendEmailVerification() async {
    try {
      await _authService.sendEmailVerification();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.sendPasswordResetEmail(email);
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _authService.signOut();
      state = AuthState.initial();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      rethrow;
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}
