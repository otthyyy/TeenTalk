import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

abstract class AppLocalizations {
  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  // Auth Screen Strings
  String get authSignIn;
  String get authSignUp;
  String get authEmail;
  String get authPassword;
  String get authConfirmPassword;
  String get authPhoneNumber;
  String get authOTP;
  String get authVerifyOTP;
  String get authResendOTP;
  String get authGoogleSignIn;
  String get authPhoneOTP;
  String get authAnonymously;
  String get authAlreadyHaveAccount;
  String get authNoAccount;
  String get authForgotPassword;
  String get authResetPassword;
  String get authBackToLogin;
  String get authVerifyEmail;
  String get authCheckEmail;
  String get authEmailVerificationSent;
  String get authResendVerification;
  String get authOTPSent;
  String get authEnterOTP;
  String get authCodeExpired;
  String get authResendCode;
  String get authInvalidOTP;
  String get authSigningIn;
  String get authCreatingAccount;
  String get authVerifying;
  String get authLinking;
  String get authLinkingCredentials;
  String get authAccountExists;
  String get authLinkAccountPrompt;
  String get authCreateNewAccount;

  // Consent Strings
  String get consentGDPR;
  String get consentGDPRDescription;
  String get consentParental;
  String get consentParentalDescription;
  String get consentTerms;
  String get consentPrivacy;
  String get consentAccept;
  String get consentDecline;
  String get consentRequired;
  String get consentParentalRequired;

  // Error Messages
  String get errorEmailRequired;
  String get errorEmailInvalid;
  String get errorPasswordRequired;
  String get errorPasswordTooShort;
  String get errorPasswordMismatch;
  String get errorPhoneRequired;
  String get errorPhoneInvalid;
  String get errorOTPRequired;
  String get errorOTPInvalid;
  String get errorUserNotFound;
  String get errorWrongPassword;
  String get errorEmailExists;
  String get errorWeakPassword;
  String get errorUserDisabled;
  String get errorTooManyRequests;
  String get errorNetworkError;
  String get errorAuthError;
  String get errorUnknownError;
  String get errorAccountAlreadyExists;
  String get errorCannotLinkAccounts;
  String get errorSessionExpired;
  String get errorOperationNotAllowed;

  // Onboarding Strings
  String get onboardingCompleteProfile;
  String get onboardingCreateProfile;
  String get onboardingFirstName;
  String get onboardingLastName;
  String get onboardingDateOfBirth;
  String get onboardingAge;
  String get onboardingContinue;
  String get onboardingSkip;
  String get onboardingGetStarted;
  String get onboardingProfilePicture;
  String get onboardingUploadPhoto;
  String get onboardingMinorWarning;
  String get onboardingParentalConsent;

  // Navigation
  String get navLogout;
  String get navSettings;
  String get navProfile;

  // Moderation Strings
  String get moderationReport;
  String get moderationReportContent;
  String get moderationReported;
  String get moderationAlreadyReported;
  String get moderationReportReason;
  String get moderationReasonSpam;
  String get moderationReasonHarassment;
  String get moderationReasonHateSpeech;
  String get moderationReasonViolence;
  String get moderationReasonSexualContent;
  String get moderationReasonMisinformation;
  String get moderationReasonSelfHarm;
  String get moderationReasonOther;
  String get moderationAdditionalDetails;
  String get moderationSubmit;
  String get moderationCancel;
  String get moderationSuccess;
  String get moderationSuccessMessage;
  String get moderationRateLimit;
  String get moderationRateLimitMessage;
  String get moderationWarning;
  String get moderationWarningMessage;
  String get moderationGuidelinesTitle;
  String get moderationGuidelinesAgree;
  String get moderationQueue;
  String get moderationQueueEmpty;
  String get moderationNoReports;
  String get moderationViewDetails;
  String get moderationTakeAction;
  String get moderationKeepActive;
  String get moderationKeepHidden;
  String get moderationRemoveContent;
  String get moderationContentHidden;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'es'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) {
    return _load(locale);
  }

  Future<AppLocalizations> _load(Locale locale) async {
    switch (locale.languageCode) {
      case 'es':
        return AppLocalizationsES();
      case 'en':
      default:
        return AppLocalizationsEN();
    }
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
