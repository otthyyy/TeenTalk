import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String nickname;
  final bool nicknameVerified;
  final String? gender;
  final String? school;
  final int anonymousPostsCount;
  final DateTime createdAt;
  final DateTime? lastNicknameChangeAt;
  final bool privacyConsentGiven;
  final DateTime privacyConsentTimestamp;
  final bool? isMinor;
  final String? guardianContact;
  final bool? parentalConsentGiven;
  final DateTime? parentalConsentTimestamp;
  final bool onboardingComplete;
  final bool allowAnonymousPosts;
  final bool profileVisible;
  final DateTime? updatedAt;
  final bool isAdmin;
  final bool isModerator;

  const UserProfile({
    required this.uid,
    required this.nickname,
    required this.nicknameVerified,
    this.gender,
    this.school,
    this.anonymousPostsCount = 0,
    required this.createdAt,
    this.lastNicknameChangeAt,
    required this.privacyConsentGiven,
    required this.privacyConsentTimestamp,
    this.isMinor,
    this.guardianContact,
    this.parentalConsentGiven,
    this.parentalConsentTimestamp,
    this.onboardingComplete = false,
    this.allowAnonymousPosts = true,
    this.profileVisible = true,
    this.updatedAt,
    this.isAdmin = false,
    this.isModerator = false,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String? ?? '',
      nickname: json['nickname'] as String? ?? '',
      nicknameVerified: json['nicknameVerified'] as bool? ?? false,
      gender: json['gender'] as String?,
      school: json['school'] as String?,
      anonymousPostsCount: json['anonymousPostsCount'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastNicknameChangeAt: json['lastNicknameChangeAt'] != null
          ? (json['lastNicknameChangeAt'] as Timestamp).toDate()
          : null,
      privacyConsentGiven: json['privacyConsentGiven'] as bool? ?? false,
      privacyConsentTimestamp: json['privacyConsentTimestamp'] != null
          ? (json['privacyConsentTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isMinor: json['isMinor'] as bool?,
      guardianContact: json['guardianContact'] as String?,
      parentalConsentGiven: json['parentalConsentGiven'] as bool?,
      parentalConsentTimestamp: json['parentalConsentTimestamp'] != null
          ? (json['parentalConsentTimestamp'] as Timestamp).toDate()
          : null,
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      allowAnonymousPosts: json['allowAnonymousPosts'] as bool? ?? true,
      profileVisible: json['profileVisible'] as bool? ?? true,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      isAdmin: json['isAdmin'] as bool? ?? false,
      isModerator: json['isModerator'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nickname': nickname,
      'nicknameVerified': nicknameVerified,
      'gender': gender,
      'school': school,
      'anonymousPostsCount': anonymousPostsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastNicknameChangeAt': lastNicknameChangeAt != null
          ? Timestamp.fromDate(lastNicknameChangeAt!)
          : null,
      'privacyConsentGiven': privacyConsentGiven,
      'privacyConsentTimestamp': Timestamp.fromDate(privacyConsentTimestamp),
      'isMinor': isMinor,
      'guardianContact': guardianContact,
      'parentalConsentGiven': parentalConsentGiven,
      'parentalConsentTimestamp': parentalConsentTimestamp != null
          ? Timestamp.fromDate(parentalConsentTimestamp!)
          : null,
      'onboardingComplete': onboardingComplete,
      'allowAnonymousPosts': allowAnonymousPosts,
      'profileVisible': profileVisible,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'isAdmin': isAdmin,
      'isModerator': isModerator,
    };
  }

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      return UserProfile(
        uid: doc.id,
        nickname: '',
        nicknameVerified: false,
        createdAt: DateTime.now(),
        privacyConsentGiven: false,
        privacyConsentTimestamp: DateTime.now(),
      );
    }
    return UserProfile(
      uid: doc.id,
      nickname: data['nickname'] as String? ?? '',
      nicknameVerified: data['nicknameVerified'] as bool? ?? false,
      gender: data['gender'] as String?,
      school: data['school'] as String?,
      anonymousPostsCount: data['anonymousPostsCount'] as int? ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastNicknameChangeAt: data['lastNicknameChangeAt'] != null
          ? (data['lastNicknameChangeAt'] as Timestamp).toDate()
          : null,
      privacyConsentGiven: data['privacyConsentGiven'] as bool? ?? false,
      privacyConsentTimestamp: data['privacyConsentTimestamp'] != null
          ? (data['privacyConsentTimestamp'] as Timestamp).toDate()
          : DateTime.now(),
      isMinor: data['isMinor'] as bool?,
      guardianContact: data['guardianContact'] as String?,
      parentalConsentGiven: data['parentalConsentGiven'] as bool?,
      parentalConsentTimestamp: data['parentalConsentTimestamp'] != null
          ? (data['parentalConsentTimestamp'] as Timestamp).toDate()
          : null,
      onboardingComplete: data['onboardingComplete'] as bool? ?? false,
      allowAnonymousPosts: data['allowAnonymousPosts'] as bool? ?? true,
      profileVisible: data['profileVisible'] as bool? ?? true,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isAdmin: data['isAdmin'] as bool? ?? false,
      isModerator: data['isModerator'] as bool? ?? false,
    );
  }

  static Map<String, dynamic> toFirestore(UserProfile profile) {
    return profile.toJson();
  }

  bool get isProfileComplete {
    final hasNickname = nickname.isNotEmpty && nicknameVerified;
    final hasSchool = school != null && school!.trim().isNotEmpty;
    final hasGender = gender != null && gender!.trim().isNotEmpty;
    final hasAgeInfo = isMinor != null;
    return onboardingComplete && hasNickname && hasSchool && hasGender && hasAgeInfo && privacyConsentGiven;
  }

  UserProfile copyWith({
    String? uid,
    String? nickname,
    bool? nicknameVerified,
    String? gender,
    String? school,
    int? anonymousPostsCount,
    DateTime? createdAt,
    DateTime? lastNicknameChangeAt,
    bool? privacyConsentGiven,
    DateTime? privacyConsentTimestamp,
    bool? isMinor,
    String? guardianContact,
    bool? parentalConsentGiven,
    DateTime? parentalConsentTimestamp,
    bool? onboardingComplete,
    bool? allowAnonymousPosts,
    bool? profileVisible,
    DateTime? updatedAt,
    bool? isAdmin,
    bool? isModerator,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      nickname: nickname ?? this.nickname,
      nicknameVerified: nicknameVerified ?? this.nicknameVerified,
      gender: gender ?? this.gender,
      school: school ?? this.school,
      anonymousPostsCount: anonymousPostsCount ?? this.anonymousPostsCount,
      createdAt: createdAt ?? this.createdAt,
      lastNicknameChangeAt: lastNicknameChangeAt ?? this.lastNicknameChangeAt,
      privacyConsentGiven: privacyConsentGiven ?? this.privacyConsentGiven,
      privacyConsentTimestamp:
          privacyConsentTimestamp ?? this.privacyConsentTimestamp,
      isMinor: isMinor ?? this.isMinor,
      guardianContact: guardianContact ?? this.guardianContact,
      parentalConsentGiven: parentalConsentGiven ?? this.parentalConsentGiven,
      parentalConsentTimestamp:
          parentalConsentTimestamp ?? this.parentalConsentTimestamp,
      onboardingComplete: onboardingComplete ?? this.onboardingComplete,
      allowAnonymousPosts: allowAnonymousPosts ?? this.allowAnonymousPosts,
      profileVisible: profileVisible ?? this.profileVisible,
      updatedAt: updatedAt ?? this.updatedAt,
      isAdmin: isAdmin ?? this.isAdmin,
      isModerator: isModerator ?? this.isModerator,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.uid == uid &&
        other.nickname == nickname &&
        other.nicknameVerified == nicknameVerified &&
        other.gender == gender &&
        other.school == school &&
        other.anonymousPostsCount == anonymousPostsCount &&
        other.createdAt == createdAt &&
        other.lastNicknameChangeAt == lastNicknameChangeAt &&
        other.privacyConsentGiven == privacyConsentGiven &&
        other.privacyConsentTimestamp == privacyConsentTimestamp &&
        other.isMinor == isMinor &&
        other.guardianContact == guardianContact &&
        other.parentalConsentGiven == parentalConsentGiven &&
        other.parentalConsentTimestamp == parentalConsentTimestamp &&
        other.onboardingComplete == onboardingComplete &&
        other.allowAnonymousPosts == allowAnonymousPosts &&
        other.profileVisible == profileVisible &&
        other.updatedAt == updatedAt &&
        other.isAdmin == isAdmin &&
        other.isModerator == isModerator;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        nickname.hashCode ^
        nicknameVerified.hashCode ^
        gender.hashCode ^
        school.hashCode ^
        anonymousPostsCount.hashCode ^
        createdAt.hashCode ^
        lastNicknameChangeAt.hashCode ^
        privacyConsentGiven.hashCode ^
        privacyConsentTimestamp.hashCode ^
        isMinor.hashCode ^
        guardianContact.hashCode ^
        parentalConsentGiven.hashCode ^
        parentalConsentTimestamp.hashCode ^
        onboardingComplete.hashCode ^
        allowAnonymousPosts.hashCode ^
        profileVisible.hashCode ^
        updatedAt.hashCode ^
        isAdmin.hashCode ^
        isModerator.hashCode;
  }
}
