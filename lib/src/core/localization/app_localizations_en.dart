import 'app_localizations.dart';

class AppLocalizationsEN extends AppLocalizations {
  @override
  String get authSignIn => 'Sign In';
  @override
  String get authSignUp => 'Sign Up';
  @override
  String get authEmail => 'Email';
  @override
  String get authPassword => 'Password';
  @override
  String get authConfirmPassword => 'Confirm Password';
  @override
  String get authPhoneNumber => 'Phone Number';
  @override
  String get authOTP => 'One-Time Password';
  @override
  String get authVerifyOTP => 'Verify OTP';
  @override
  String get authResendOTP => 'Resend OTP';
  @override
  String get authGoogleSignIn => 'Sign in with Google';
  @override
  String get authPhoneOTP => 'Sign in with Phone Number';
  @override
  String get authAnonymously => 'Continue Anonymously';
  @override
  String get authAlreadyHaveAccount => 'Already have an account? Sign In';
  @override
  String get authNoAccount => "Don't have an account? Sign Up";
  @override
  String get authForgotPassword => 'Forgot Password?';
  @override
  String get authResetPassword => 'Reset Password';
  @override
  String get authBackToLogin => 'Back to Login';
  @override
  String get authVerifyEmail => 'Verify Email';
  @override
  String get authCheckEmail => 'Check your email';
  @override
  String get authEmailVerificationSent => 'Verification email sent to your inbox';
  @override
  String get authResendVerification => 'Resend verification email';
  @override
  String get authOTPSent => 'OTP sent to your phone';
  @override
  String get authEnterOTP => 'Enter the 6-digit code sent to your phone';
  @override
  String get authCodeExpired => 'Code expired. Please request a new one.';
  @override
  String get authResendCode => 'Resend Code';
  @override
  String get authInvalidOTP => 'Invalid OTP. Please try again.';
  @override
  String get authSigningIn => 'Signing in...';
  @override
  String get authCreatingAccount => 'Creating account...';
  @override
  String get authVerifying => 'Verifying...';
  @override
  String get authLinking => 'Linking account...';
  @override
  String get authLinkingCredentials => 'Linking authentication methods...';
  @override
  String get authAccountExists => 'This email is already associated with another account';
  @override
  String get authLinkAccountPrompt => 'Would you like to link this method to your existing account?';
  @override
  String get authCreateNewAccount => 'Create a new account';

  @override
  String get consentGDPR => 'GDPR Consent';
  @override
  String get consentGDPRDescription => 'I agree to the processing of my personal data as described in the Privacy Policy';
  @override
  String get consentParental => 'Parental Consent';
  @override
  String get consentParentalDescription => 'A parent or guardian has confirmed they authorize this account';
  @override
  String get consentTerms => 'I agree to the Terms of Service';
  @override
  String get consentPrivacy => 'I agree to the Privacy Policy';
  @override
  String get consentAccept => 'Accept';
  @override
  String get consentDecline => 'Decline';
  @override
  String get consentRequired => 'You must accept the terms to continue';
  @override
  String get consentParentalRequired => 'Parental consent is required for users under 18';

  @override
  String get errorEmailRequired => 'Email is required';
  @override
  String get errorEmailInvalid => 'Please enter a valid email address';
  @override
  String get errorPasswordRequired => 'Password is required';
  @override
  String get errorPasswordTooShort => 'Password must be at least 8 characters long';
  @override
  String get errorPasswordMismatch => 'Passwords do not match';
  @override
  String get errorPhoneRequired => 'Phone number is required';
  @override
  String get errorPhoneInvalid => 'Please enter a valid phone number';
  @override
  String get errorOTPRequired => 'OTP is required';
  @override
  String get errorOTPInvalid => 'Invalid or expired OTP';
  @override
  String get errorUserNotFound => 'No user found with this email or phone number';
  @override
  String get errorWrongPassword => 'Incorrect password';
  @override
  String get errorEmailExists => 'An account already exists with this email';
  @override
  String get errorWeakPassword => 'Password is too weak. Use at least 8 characters with a mix of uppercase, lowercase, and numbers';
  @override
  String get errorUserDisabled => 'This account has been disabled';
  @override
  String get errorTooManyRequests => 'Too many login attempts. Please try again later';
  @override
  String get errorNetworkError => 'Network error. Please check your connection';
  @override
  String get errorAuthError => 'Authentication failed';
  @override
  String get errorUnknownError => 'An unknown error occurred';
  @override
  String get errorAccountAlreadyExists => 'An account already exists with this phone number';
  @override
  String get errorCannotLinkAccounts => 'Cannot link this authentication method to your account';
  @override
  String get errorSessionExpired => 'Your session has expired. Please sign in again';
  @override
  String get errorOperationNotAllowed => 'This authentication method is not enabled';

  @override
  String get onboardingCompleteProfile => 'Complete Your Profile';
  @override
  String get onboardingCreateProfile => 'Create Your Profile';
  @override
  String get onboardingFirstName => 'First Name';
  @override
  String get onboardingLastName => 'Last Name';
  @override
  String get onboardingDateOfBirth => 'Date of Birth';
  @override
  String get onboardingAge => 'Age';
  @override
  String get onboardingContinue => 'Continue';
  @override
  String get onboardingSkip => 'Skip';
  @override
  String get onboardingGetStarted => 'Get Started';
  @override
  String get onboardingProfilePicture => 'Profile Picture';
  @override
  String get onboardingUploadPhoto => 'Upload Photo';
  @override
  String get onboardingMinorWarning => 'You indicated you are under 18. A parent or guardian will need to verify this account.';
  @override
  String get onboardingParentalConsent => 'Waiting for parental consent...';

  @override
  String get navLogout => 'Logout';
  @override
  String get navSettings => 'Settings';
  @override
  String get navProfile => 'Profile';

  @override
  String get moderationReport => 'Report';
  @override
  String get moderationReportContent => 'Report Content';
  @override
  String get moderationReported => 'Reported';
  @override
  String get moderationAlreadyReported => 'Already reported';
  @override
  String get moderationReportReason => 'Reason for report';
  @override
  String get moderationReasonSpam => 'Spam or misleading';
  @override
  String get moderationReasonHarassment => 'Harassment or bullying';
  @override
  String get moderationReasonHateSpeech => 'Hate speech';
  @override
  String get moderationReasonViolence => 'Violence or dangerous content';
  @override
  String get moderationReasonSexualContent => 'Sexual content';
  @override
  String get moderationReasonMisinformation => 'Misinformation';
  @override
  String get moderationReasonSelfHarm => 'Self-harm or suicide';
  @override
  String get moderationReasonOther => 'Other';
  @override
  String get moderationAdditionalDetails => 'Additional details (optional)';
  @override
  String get moderationSubmit => 'Submit Report';
  @override
  String get moderationCancel => 'Cancel';
  @override
  String get moderationSuccess => 'Report Submitted';
  @override
  String get moderationSuccessMessage => 'Report submitted successfully. Thank you for helping keep our community safe.';
  @override
  String get moderationRateLimit => 'Report Limit Reached';
  @override
  String get moderationRateLimitMessage => 'You have reached the maximum number of reports allowed per day. Please try again tomorrow.';
  @override
  String get moderationWarning => 'Report Warning';
  @override
  String get moderationWarningMessage => 'Please ensure you are reporting genuine violations of our community guidelines.';
  @override
  String get moderationGuidelinesTitle => 'Community Guidelines';
  @override
  String get moderationGuidelinesAgree => 'I have read and understand the community guidelines';
  @override
  String get moderationQueue => 'Moderation Queue';
  @override
  String get moderationQueueEmpty => 'No items in moderation queue';
  @override
  String get moderationNoReports => 'No reports found';
  @override
  String get moderationViewDetails => 'View Details';
  @override
  String get moderationTakeAction => 'Take Action';
  @override
  String get moderationKeepActive => 'Keep Active';
  @override
  String get moderationKeepHidden => 'Keep Hidden';
  @override
  String get moderationRemoveContent => 'Remove Content';
  @override
  String get moderationContentHidden => 'This content has been hidden by moderators';

  @override
  String get trustBadgeNewcomerLabel => 'Newcomer';
  @override
  String get trustBadgeMemberLabel => 'Member';
  @override
  String get trustBadgeTrustedLabel => 'Trusted';
  @override
  String get trustBadgeVeteranLabel => 'Veteran';
  @override
  String get trustBadgeNewcomerDescription => 'New to the community';
  @override
  String get trustBadgeMemberDescription => 'Active community member';
  @override
  String get trustBadgeTrustedDescription => 'Trusted community member';
  @override
  String get trustBadgeVeteranDescription => 'Long-standing community member';
  @override
  String get trustInfoLearnMore => 'Learn more about trust levels';
  @override
  String get trustBadgeTooltip => 'Trust badge indicates community standing';
  @override
  String get trustLowTrustWarningTitle => 'New User';
  @override
  String get trustLowTrustWarningDescription => 'This user is new to the community. Please be cautious when interacting.';
  @override
  String get trustLowTrustWarningProceed => 'Continue';
  @override
  String get trustLowTrustWarningCancel => 'Cancel';
}
