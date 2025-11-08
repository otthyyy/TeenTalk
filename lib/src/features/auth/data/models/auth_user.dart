class AuthUser {
  final String uid;
  final String? email;
  final String? phoneNumber;
  final String? displayName;
  final String? photoURL;
  final bool emailVerified;
  final bool isAnonymous;
  final DateTime createdAt;
  final List<String> authMethods;
  final bool isMinor;
  final bool parentalConsentProvided;
  final bool gdprConsentProvided;
  final bool termsAccepted;

  const AuthUser({
    required this.uid,
    this.email,
    this.phoneNumber,
    this.displayName,
    this.photoURL,
    required this.emailVerified,
    required this.isAnonymous,
    required this.createdAt,
    required this.authMethods,
    this.isMinor = false,
    this.parentalConsentProvided = false,
    this.gdprConsentProvided = false,
    this.termsAccepted = false,
  });

  AuthUser copyWith({
    String? uid,
    String? email,
    String? phoneNumber,
    String? displayName,
    String? photoURL,
    bool? emailVerified,
    bool? isAnonymous,
    DateTime? createdAt,
    List<String>? authMethods,
    bool? isMinor,
    bool? parentalConsentProvided,
    bool? gdprConsentProvided,
    bool? termsAccepted,
  }) {
    return AuthUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      emailVerified: emailVerified ?? this.emailVerified,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      createdAt: createdAt ?? this.createdAt,
      authMethods: authMethods ?? this.authMethods,
      isMinor: isMinor ?? this.isMinor,
      parentalConsentProvided: parentalConsentProvided ?? this.parentalConsentProvided,
      gdprConsentProvided: gdprConsentProvided ?? this.gdprConsentProvided,
      termsAccepted: termsAccepted ?? this.termsAccepted,
    );
  }

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      uid: json['uid'] as String,
      email: json['email'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      displayName: json['displayName'] as String?,
      photoURL: json['photoURL'] as String?,
      emailVerified: json['emailVerified'] as bool? ?? false,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
      createdAt: DateTime.parse(json['createdAt'] as String),
      authMethods: List<String>.from(json['authMethods'] as List? ?? []),
      isMinor: json['isMinor'] as bool? ?? false,
      parentalConsentProvided: json['parentalConsentProvided'] as bool? ?? false,
      gdprConsentProvided: json['gdprConsentProvided'] as bool? ?? false,
      termsAccepted: json['termsAccepted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'phoneNumber': phoneNumber,
    'displayName': displayName,
    'photoURL': photoURL,
    'emailVerified': emailVerified,
    'isAnonymous': isAnonymous,
    'createdAt': createdAt.toIso8601String(),
    'authMethods': authMethods,
    'isMinor': isMinor,
    'parentalConsentProvided': parentalConsentProvided,
    'gdprConsentProvided': gdprConsentProvided,
    'termsAccepted': termsAccepted,
  };
}

class UserProfile {
  final String uid;
  final String firstName;
  final String lastName;
  final DateTime dateOfBirth;
  final String? photoURL;
  final String? bio;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool profileComplete;
  final bool isAdmin;

  const UserProfile({
    required this.uid,
    required this.firstName,
    required this.lastName,
    required this.dateOfBirth,
    this.photoURL,
    this.bio,
    required this.createdAt,
    required this.updatedAt,
    this.profileComplete = false,
    this.isAdmin = false,
  });

  UserProfile copyWith({
    String? uid,
    String? firstName,
    String? lastName,
    DateTime? dateOfBirth,
    String? photoURL,
    String? bio,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? profileComplete,
    bool? isAdmin,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      photoURL: photoURL ?? this.photoURL,
      bio: bio ?? this.bio,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileComplete: profileComplete ?? this.profileComplete,
      isAdmin: isAdmin ?? this.isAdmin,
    );
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      dateOfBirth: DateTime.parse(json['dateOfBirth'] as String),
      photoURL: json['photoURL'] as String?,
      bio: json['bio'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      profileComplete: json['profileComplete'] as bool? ?? false,
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'firstName': firstName,
    'lastName': lastName,
    'dateOfBirth': dateOfBirth.toIso8601String(),
    'photoURL': photoURL,
    'bio': bio,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'profileComplete': profileComplete,
    'isAdmin': isAdmin,
  };
}

class AuthState {
  final bool isAuthenticated;
  final bool isLoading;
  final String? error;
  final AuthUser? user;
  final UserProfile? profile;
  final bool requiresOnboarding;
  final bool requiresParentalConsent;

  const AuthState({
    required this.isAuthenticated,
    required this.isLoading,
    required this.error,
    this.user,
    this.profile,
    this.requiresOnboarding = false,
    this.requiresParentalConsent = false,
  });

  factory AuthState.initial() => const AuthState(
    isAuthenticated: false,
    isLoading: false,
    error: null,
    user: null,
    profile: null,
    requiresOnboarding: false,
    requiresParentalConsent: false,
  );

  AuthState copyWith({
    bool? isAuthenticated,
    bool? isLoading,
    String? error,
    AuthUser? user,
    UserProfile? profile,
    bool? requiresOnboarding,
    bool? requiresParentalConsent,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      user: user ?? this.user,
      profile: profile ?? this.profile,
      requiresOnboarding: requiresOnboarding ?? this.requiresOnboarding,
      requiresParentalConsent: requiresParentalConsent ?? this.requiresParentalConsent,
    );
  }
}

class Consent {
  final String uid;
  final bool gdprConsent;
  final bool termsConsent;
  final bool parentalConsent;
  final DateTime consentDate;
  final String consentVersion;

  const Consent({
    required this.uid,
    required this.gdprConsent,
    required this.termsConsent,
    required this.parentalConsent,
    required this.consentDate,
    required this.consentVersion,
  });

  factory Consent.fromJson(Map<String, dynamic> json) {
    return Consent(
      uid: json['uid'] as String,
      gdprConsent: json['gdprConsent'] as bool,
      termsConsent: json['termsConsent'] as bool,
      parentalConsent: json['parentalConsent'] as bool,
      consentDate: DateTime.parse(json['consentDate'] as String),
      consentVersion: json['consentVersion'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'gdprConsent': gdprConsent,
    'termsConsent': termsConsent,
    'parentalConsent': parentalConsent,
    'consentDate': consentDate.toIso8601String(),
    'consentVersion': consentVersion,
  };
}
