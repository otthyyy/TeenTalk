import 'app_localizations.dart';

class AppLocalizationsIT extends AppLocalizations {
  @override
  String get authSignIn => 'Accedi';
  @override
  String get authSignUp => 'Registrati';
  @override
  String get authEmail => 'Email';
  @override
  String get authPassword => 'Password';
  @override
  String get authConfirmPassword => 'Conferma Password';
  @override
  String get authPhoneNumber => 'Numero di Telefono';
  @override
  String get authOTP => 'Password Monouso';
  @override
  String get authVerifyOTP => 'Verifica OTP';
  @override
  String get authResendOTP => 'Invia di nuovo OTP';
  @override
  String get authGoogleSignIn => 'Accedi con Google';
  @override
  String get authPhoneOTP => 'Accedi con Numero di Telefono';
  @override
  String get authAnonymously => 'Continua in Anonimo';
  @override
  String get authAlreadyHaveAccount => 'Hai già un account? Accedi';
  @override
  String get authNoAccount => "Non hai un account? Registrati";
  @override
  String get authForgotPassword => 'Password Dimenticata?';
  @override
  String get authResetPassword => 'Reimposta Password';
  @override
  String get authBackToLogin => 'Torna al Login';
  @override
  String get authVerifyEmail => 'Verifica Email';
  @override
  String get authCheckEmail => 'Controlla la tua email';
  @override
  String get authEmailVerificationSent => 'Email di verifica inviata alla tua casella di posta';
  @override
  String get authResendVerification => 'Invia di nuovo email di verifica';
  @override
  String get authOTPSent => 'OTP inviato al tuo telefono';
  @override
  String get authEnterOTP => 'Inserisci il codice a 6 cifre inviato al tuo telefono';
  @override
  String get authCodeExpired => 'Codice scaduto';
  @override
  String get authResendCode => 'Invia di nuovo il codice';
  @override
  String get authInvalidOTP => 'OTP non valido';
  @override
  String get authSigningIn => 'Accesso in corso...';
  @override
  String get authCreatingAccount => 'Creazione account in corso...';
  @override
  String get authVerifying => 'Verifica in corso...';
  @override
  String get authLinking => 'Collegamento in corso...';
  @override
  String get authLinkingCredentials => 'Collegamento credenziali...';
  @override
  String get authAccountExists => 'Account esistente';
  @override
  String get authLinkAccountPrompt => 'Vuoi collegare questo account?';
  @override
  String get authCreateNewAccount => 'Crea nuovo account';

  // Consent Strings
  @override
  String get consentGDPR => 'Consenso GDPR';
  @override
  String get consentGDPRDescription => 'Acconsento al trattamento dei miei dati personali conforme al GDPR';
  @override
  String get consentParental => 'Consenso Genitoriale';
  @override
  String get consentParentalDescription => 'Acconsento al trattamento dei dati del mio minore';
  @override
  String get consentTerms => 'Termini di Servizio';
  @override
  String get consentPrivacy => 'Privacy Policy';
  @override
  String get consentAccept => 'Accetto';
  @override
  String get consentDecline => 'Rifiuto';
  @override
  String get consentRequired => 'Consenso obbligatorio';
  @override
  String get consentParentalRequired => 'Consenso genitoriale obbligatorio per minorenni';

  // Error Messages
  @override
  String get errorEmailRequired => 'Email richiesta';
  @override
  String get errorEmailInvalid => 'Email non valida';
  @override
  String get errorPasswordRequired => 'Password richiesta';
  @override
  String get errorPasswordTooShort => 'Password troppo corta';
  @override
  String get errorPasswordMismatch => 'Le password non corrispondono';
  @override
  String get errorPhoneRequired => 'Numero di telefono richiesto';
  @override
  String get errorPhoneInvalid => 'Numero di telefono non valido';
  @override
  String get errorOTPRequired => 'OTP richiesto';
  @override
  String get errorOTPInvalid => 'OTP non valido';
  @override
  String get errorUserNotFound => 'Utente non trovato';
  @override
  String get errorWrongPassword => 'Password errata';
  @override
  String get errorEmailExists => 'Email già in uso';
  @override
  String get errorWeakPassword => 'Password troppo debole';
  @override
  String get errorUserDisabled => 'Utente disabilitato';
  @override
  String get errorTooManyRequests => 'Troppe richieste';
  @override
  String get errorNetworkError => 'Errore di rete';
  @override
  String get errorAuthError => 'Errore di autenticazione';
  @override
  String get errorUnknownError => 'Errore sconosciuto';
  @override
  String get errorAccountAlreadyExists => 'Account già esistente';
  @override
  String get errorCannotLinkAccounts => 'Impossibile collegare gli account';
  @override
  String get errorSessionExpired => 'Sessione scaduta';
  @override
  String get errorOperationNotAllowed => 'Operazione non consentita';

  // Onboarding Strings
  @override
  String get onboardingCompleteProfile => 'Completa il Profilo';
  @override
  String get onboardingCreateProfile => 'Crea Profilo';
  @override
  String get onboardingFirstName => 'Nome';
  @override
  String get onboardingLastName => 'Cognome';
  @override
  String get onboardingDateOfBirth => 'Data di Nascita';
  @override
  String get onboardingAge => 'Età';
  @override
  String get onboardingContinue => 'Continua';
  @override
  String get onboardingSkip => 'Salta';
  @override
  String get onboardingGetStarted => 'Inizia';
  @override
  String get onboardingProfilePicture => 'Foto Profilo';
  @override
  String get onboardingUploadPhoto => 'Carica Foto';
  @override
  String get onboardingMinorWarning => 'Sei minorenne. È richiesto il consenso genitoriale.';
  @override
  String get onboardingParentalConsent => 'Consenso Genitoriale';

  // Navigation
  @override
  String get navLogout => 'Logout';
  @override
  String get navSettings => 'Impostazioni';
  @override
  String get navProfile => 'Profilo';

  // Moderation Strings
  @override
  String get moderationReport => 'Segnala';
  @override
  String get moderationReportContent => 'Segnala Contenuto';
  @override
  String get moderationReported => 'Segnalato';
  @override
  String get moderationAlreadyReported => 'Già Segnalato';
  @override
  String get moderationReportReason => 'Motivo della Segnalazione';
  @override
  String get moderationReasonSpam => 'Spam';
  @override
  String get moderationReasonHarassment => 'Molestie';
  @override
  String get moderationReasonHateSpeech => 'Discorso d\'odio';
  @override
  String get moderationReasonViolence => 'Violenza';
  @override
  String get moderationReasonSexualContent => 'Contenuto Sessuale';
  @override
  String get moderationReasonMisinformation => 'Informazioni False';
  @override
  String get moderationReasonSelfHarm => 'Autolesionismo';
  @override
  String get moderationReasonOther => 'Altro';
  @override
  String get moderationAdditionalDetails => 'Dettagli Aggiuntivi';
  @override
  String get moderationSubmit => 'Invia';
  @override
  String get moderationCancel => 'Annulla';
  @override
  String get moderationSuccess => 'Successo';
  @override
  String get moderationSuccessMessage => 'Contenuto segnalato con successo';
  @override
  String get moderationRateLimit => 'Limite Raggiunto';
  @override
  String get moderationRateLimitMessage => 'Hai raggiunto il limite di segnalazioni giornaliere';
  @override
  String get moderationWarning => 'Attenzione';
  @override
  String get moderationWarningMessage => 'Stai per raggiungere il limite di segnalazioni';
  @override
  String get moderationGuidelinesTitle => 'Linee Guida della Community';
  @override
  String get moderationGuidelinesAgree => 'Accetto le Linee Guida';
  @override
  String get moderationQueue => 'Coda Moderazione';
  @override
  String get moderationQueueEmpty => 'Nessun contenuto da moderare';
  @override
  String get moderationNoReports => 'Nessuna segnalazione';
  @override
  String get moderationViewDetails => 'Visualizza Dettagli';
  @override
  String get moderationTakeAction => 'Prendi Azione';
  @override
  String get moderationKeepActive => 'Mantieni Attivo';
  @override
  String get moderationKeepHidden => 'Mantieni Nascosto';
  @override
  String get moderationRemoveContent => 'Rimuovi Contenuto';
  @override
  String get moderationContentHidden => 'Contenuto Nascosto';

  @override
  String get trustBadgeNewcomerLabel => 'Nuovo Arrivato';
  @override
  String get trustBadgeMemberLabel => 'Membro';
  @override
  String get trustBadgeTrustedLabel => 'Fidato';
  @override
  String get trustBadgeVeteranLabel => 'Veterano';
  @override
  String get trustBadgeNewcomerDescription => 'Nuovo nella comunità';
  @override
  String get trustBadgeMemberDescription => 'Membro attivo della comunità';
  @override
  String get trustBadgeTrustedDescription => 'Membro fidato della comunità';
  @override
  String get trustBadgeVeteranDescription => 'Membro storico della comunità';
  @override
  String get trustInfoLearnMore => 'Ulteriori informazioni sui livelli di fiducia';
  @override
  String get trustBadgeTooltip => 'Il badge di fiducia indica la reputazione nella comunità';
  @override
  String get trustLowTrustWarningTitle => 'Utente Nuovo';
  @override
  String get trustLowTrustWarningDescription => 'Questo utente è nuovo nella comunità. Interagisci con cautela.';
  @override
  String get trustLowTrustWarningProceed => 'Continua';
  @override
  String get trustLowTrustWarningCancel => 'Annulla';
}