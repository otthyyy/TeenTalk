import 'package:cloud_firestore/cloud_firestore.dart';
import 'trust_level.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/search_keywords_generator.dart';

class UserProfile {
  final String uid;
  final String nickname;
  final bool nicknameVerified;
  final String? gender;
  final String? school;
  final String? schoolYear;
  final List<String> interests;
  final List<String> clubs;
  final List<String> searchKeywords;
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
  final bool analyticsEnabled;
  final DateTime? updatedAt;
  final bool isAdmin;
  final bool isModerator;
  final TrustLevel trustLevel;
  final bool isBetaTester;
  final bool? betaConsentGiven;
  final DateTime? betaConsentTimestamp;
  final bool crashReportingEnabled;

  const UserProfile({
    required this.uid,
    required this.nickname,
    required this.nicknameVerified,
    this.gender,
    this.school,
    this.schoolYear,
    this.interests = const [],
    this.clubs = const [],
    this.searchKeywords = const [],
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
    this.analyticsEnabled = true,
    this.updatedAt,
    this.isAdmin = false,
    this.isModerator = false,
    this.trustLevel = TrustLevel.newcomer,
    this.isBetaTester = false,
    this.betaConsentGiven,
    this.betaConsentTimestamp,
    this.crashReportingEnabled = true,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final nickname = json['nickname'] as String? ?? '';
    final school = json['school'] as String?;
    final schoolYear = json['schoolYear'] as String?;
    final interests = _normalizeStringList(json['interests']);
    final clubs = _normalizeStringList(json['clubs']);
    final searchKeywords = _normalizeStringList(json['searchKeywords']);

    return UserProfile(
      uid: json['uid'] as String? ?? '',
      nickname: nickname,
      nicknameVerified: json['nicknameVerified'] as bool? ?? false,
      gender: json['gender'] as String?,
      school: school,
      schoolYear: schoolYear,
      interests: interests,
      clubs: clubs,
      searchKeywords: searchKeywords.isNotEmpty
          ? searchKeywords
          : buildSearchKeywords(
              nickname,
              school,
              schoolYear,
              interests,
              clubs,
              json['gender'] as String?,
            ),
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
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
      updatedAt: json['updatedAt'] != null
          ? (json['updatedAt'] as Timestamp).toDate()
          : null,
      isAdmin: json['isAdmin'] as bool? ?? false,
      isModerator: json['isModerator'] as bool? ?? false,
      trustLevel: TrustLevel.fromString(json['trustLevel'] as String?),
      isBetaTester: json['isBetaTester'] as bool? ?? false,
      betaConsentGiven: json['betaConsentGiven'] as bool?,
      betaConsentTimestamp: json['betaConsentTimestamp'] != null
          ? (json['betaConsentTimestamp'] as Timestamp).toDate()
          : null,
      crashReportingEnabled: json['crashReportingEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nickname': nickname,
      'nicknameVerified': nicknameVerified,
      'gender': gender,
      'school': school,
      'schoolYear': schoolYear,
      'interests': interests,
      'clubs': clubs,
      'searchKeywords': searchKeywords,
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
      'analyticsEnabled': analyticsEnabled,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
      'isAdmin': isAdmin,
      'isModerator': isModerator,
      'trustLevel': trustLevel.toJson(),
      'isBetaTester': isBetaTester,
      'betaConsentGiven': betaConsentGiven,
      'betaConsentTimestamp': betaConsentTimestamp != null
          ? Timestamp.fromDate(betaConsentTimestamp!)
          : null,
      'crashReportingEnabled': crashReportingEnabled,
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
    final nickname = data['nickname'] as String? ?? '';
    final school = data['school'] as String?;
    final schoolYear = data['schoolYear'] as String?;
    final interests = _normalizeStringList(data['interests']);
    final clubs = _normalizeStringList(data['clubs']);
    final searchKeywords = _normalizeStringList(data['searchKeywords']);

    return UserProfile(
      uid: doc.id,
      nickname: nickname,
      nicknameVerified: data['nicknameVerified'] as bool? ?? false,
      gender: data['gender'] as String?,
      school: school,
      schoolYear: schoolYear,
      interests: interests,
      clubs: clubs,
      searchKeywords: searchKeywords.isNotEmpty
          ? searchKeywords
          : buildSearchKeywords(
              nickname,
              school,
              schoolYear,
              interests,
              clubs,
              data['gender'] as String?,
            ),
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
      analyticsEnabled: data['analyticsEnabled'] as bool? ?? true,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
      isAdmin: data['isAdmin'] as bool? ?? false,
      isModerator: data['isModerator'] as bool? ?? false,
      trustLevel: TrustLevel.fromString(data['trustLevel'] as String?),
      isBetaTester: data['isBetaTester'] as bool? ?? false,
      betaConsentGiven: data['betaConsentGiven'] as bool?,
      betaConsentTimestamp: data['betaConsentTimestamp'] != null
          ? (data['betaConsentTimestamp'] as Timestamp).toDate()
          : null,
      crashReportingEnabled: data['crashReportingEnabled'] as bool? ?? true,
    );
  }

  static Map<String, dynamic> toFirestore(UserProfile profile) {
    return profile.toJson();
  }

  List<String> generateSearchKeywords() {
    return buildSearchKeywords(
      nickname,
      school,
      schoolYear,
      interests,
      clubs,
      gender,
    );
  }

  bool get isProfileComplete {
    final hasNickname = nickname.isNotEmpty && nicknameVerified;
    final hasSchool = school != null && school!.trim().isNotEmpty;
    final hasGender = gender != null && gender!.trim().isNotEmpty;
    final hasAgeInfo = isMinor != null;
    final hasSchoolYear = schoolYear != null && schoolYear!.trim().isNotEmpty;
    final hasInterests = interests.isNotEmpty;
    return onboardingComplete &&
        hasNickname &&
        hasSchool &&
        hasGender &&
        hasAgeInfo &&
        hasSchoolYear &&
        hasInterests &&
        privacyConsentGiven;
  }

  UserProfile copyWith({
    String? uid,
    String? nickname,
    bool? nicknameVerified,
    String? gender,
    String? school,
    String? schoolYear,
    List<String>? interests,
    List<String>? clubs,
    List<String>? searchKeywords,
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
    bool? analyticsEnabled,
    DateTime? updatedAt,
    bool? isAdmin,
    bool? isModerator,
    TrustLevel? trustLevel,
    bool? isBetaTester,
    bool? betaConsentGiven,
    DateTime? betaConsentTimestamp,
    bool? crashReportingEnabled,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      nickname: nickname ?? this.nickname,
      nicknameVerified: nicknameVerified ?? this.nicknameVerified,
      gender: gender ?? this.gender,
      school: school ?? this.school,
      schoolYear: schoolYear ?? this.schoolYear,
      interests: interests ?? this.interests,
      clubs: clubs ?? this.clubs,
      searchKeywords: searchKeywords ?? this.searchKeywords,
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
      analyticsEnabled: analyticsEnabled ?? this.analyticsEnabled,
      updatedAt: updatedAt ?? this.updatedAt,
      isAdmin: isAdmin ?? this.isAdmin,
      isModerator: isModerator ?? this.isModerator,
      trustLevel: trustLevel ?? this.trustLevel,
      isBetaTester: isBetaTester ?? this.isBetaTester,
      betaConsentGiven: betaConsentGiven ?? this.betaConsentGiven,
      betaConsentTimestamp: betaConsentTimestamp ?? this.betaConsentTimestamp,
      crashReportingEnabled:
          crashReportingEnabled ?? this.crashReportingEnabled,
    );
  }

  static const ListEquality<String> _listEquality = ListEquality<String>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.uid == uid &&
        other.nickname == nickname &&
        other.nicknameVerified == nicknameVerified &&
        other.gender == gender &&
        other.school == school &&
        other.schoolYear == schoolYear &&
        _listEquality.equals(other.interests, interests) &&
        _listEquality.equals(other.clubs, clubs) &&
        _listEquality.equals(other.searchKeywords, searchKeywords) &&
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
        other.analyticsEnabled == analyticsEnabled &&
        other.updatedAt == updatedAt &&
        other.isAdmin == isAdmin &&
        other.isModerator == isModerator &&
        other.trustLevel == trustLevel &&
        other.isBetaTester == isBetaTester &&
        other.betaConsentGiven == betaConsentGiven &&
        other.betaConsentTimestamp == betaConsentTimestamp &&
        other.crashReportingEnabled == crashReportingEnabled;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        nickname.hashCode ^
        nicknameVerified.hashCode ^
        gender.hashCode ^
        school.hashCode ^
        schoolYear.hashCode ^
        _listEquality.hash(interests) ^
        _listEquality.hash(clubs) ^
        _listEquality.hash(searchKeywords) ^
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
        analyticsEnabled.hashCode ^
        updatedAt.hashCode ^
        isAdmin.hashCode ^
        isModerator.hashCode ^
        trustLevel.hashCode ^
        isBetaTester.hashCode ^
        betaConsentGiven.hashCode ^
        betaConsentTimestamp.hashCode ^
        crashReportingEnabled.hashCode;
  }

  static List<String> _normalizeStringList(dynamic value) {
    if (value == null) return const [];
    if (value is List) {
      return List<String>.from(value);
    }
    return const [];
  }

  static List<String> buildSearchKeywords(
    String nickname,
    String? school,
    String? schoolYear,
    List<String> interests,
    List<String> clubs,
    String? gender,
  ) {
    return SearchKeywordsGenerator.generateUserKeywords(
      nickname: nickname,
      school: school,
      schoolYear: schoolYear,
      interests: interests,
      clubs: clubs,
      gender: gender,
    );
  }
}
