import '../../data/models/auth_user.dart';

class AuthFormState {

  const AuthFormState({
    this.email = '',
    this.password = '',
    this.confirmPassword = '',
    this.phoneNumber = '',
    this.otp = '',
    this.isSubmitting = false,
    this.error,
    this.showPassword = false,
    this.showConfirmPassword = false,
    this.displayName,
  });
  final String email;
  final String password;
  final String confirmPassword;
  final String phoneNumber;
  final String otp;
  final bool isSubmitting;
  final String? error;
  final bool showPassword;
  final bool showConfirmPassword;
  final String? displayName;

  AuthFormState copyWith({
    String? email,
    String? password,
    String? confirmPassword,
    String? phoneNumber,
    String? otp,
    bool? isSubmitting,
    String? error,
    bool? showPassword,
    bool? showConfirmPassword,
    String? displayName,
  }) {
    return AuthFormState(
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      otp: otp ?? this.otp,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      showPassword: showPassword ?? this.showPassword,
      showConfirmPassword: showConfirmPassword ?? this.showConfirmPassword,
      displayName: displayName ?? this.displayName,
    );
  }
}

class ConsentState {

  const ConsentState({
    this.gdprConsent = false,
    this.termsConsent = false,
    this.parentalConsent = false,
  }) : allConsentsProvided = gdprConsent && termsConsent;
  final bool gdprConsent;
  final bool termsConsent;
  final bool parentalConsent;
  final bool allConsentsProvided;

  ConsentState copyWith({
    bool? gdprConsent,
    bool? termsConsent,
    bool? parentalConsent,
  }) {
    return ConsentState(
      gdprConsent: gdprConsent ?? this.gdprConsent,
      termsConsent: termsConsent ?? this.termsConsent,
      parentalConsent: parentalConsent ?? this.parentalConsent,
    );
  }
}
