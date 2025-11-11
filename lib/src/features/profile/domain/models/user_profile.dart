import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/utils/search_keywords_generator.dart';

import 'trust_level.dart';

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
  final int trustScore;
  final TrustLevel trustLevel;
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
  final bool isBetaTester;
  final bool? betaConsentGiven;
  final DateTime? betaConsentTimestamp;
  final bool crashReportingEnabled;
  final bool screenshotProtectionEnabled;

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
    this.trustScore = 50,
    this.trustLevel = TrustLevel.newcomer,
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
    this.isBetaTester = false,
    this.betaConsentGiven,
    this.betaConsentTimestamp,
    this.crashReportingEnabled = true,
    this.screenshotProtectionEnabled = true,
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
      trustScore: json['trustScore'] as int? ?? 50,
      trustLevel: TrustLevel.fromString(json['trustLevel'] as String?),
      anonymousPostsCount: json['anonymousPostsCount'] as int? ?? 0,
      createdAt: _timestampToDate(json['createdAt']) ?? DateTime.now(),
      lastNicknameChangeAt:
          _timestampToDate(json['lastNicknameChangeAt']),
      privacyConsentGiven: json['privacyConsentGiven'] as bool? ?? false,
      privacyConsentTimestamp:
          _timestampToDate(json['privacyConsentTimestamp']) ?? DateTime.now(),
      isMinor: json['isMinor'] as bool?,
      guardianContact: json['guardianContact'] as String?,
      parentalConsentGiven: json['parentalConsentGiven'] as bool?,
      parentalConsentTimestamp:
          _timestampToDate(json['parentalConsentTimestamp']),
      onboardingComplete: json['onboardingComplete'] as bool? ?? false,
      allowAnonymousPosts: json['allowAnonymousPosts'] as bool? ?? true,
      profileVisible: json['profileVisible'] as bool? ?? true,
      analyticsEnabled: json['analyticsEnabled'] as bool? ?? true,
      updatedAt: _timestampToDate(json['updatedAt']),
      isAdmin: json['isAdmin'] as bool? ?? false,
      isModerator: json['isModerator'] as bool? ?? false,
      isBetaTester: json['isBetaTester'] as bool? ?? false,
      betaConsentGiven: json['betaConsentGiven'] as bool?,
      betaConsentTimestamp:
          _timestampToDate(json['betaConsentTimestamp']),
      crashReportingEnabled:
          json['crashReportingEnabled'] as bool? ?? true,
      screenshotProtectionEnabled:
          json['screenshotProtectionEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'uid': uid,
      'nickname': nickname,
      'nicknameVerified': nicknameVerified,
      'gender': gender,
      'school': school,
      'schoolYear': schoolYear,
      'interests': interests,
      'clubs': clubs,
      'searchKeywords': searchKeywords,
      'trustScore': trustScore,
      'trustLevel': trustLevel.toJson(),
      'anonymousPostsCount': anonymousPostsCount,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastNicknameChangeAt': lastNicknameChangeAt != null
          ? Timestamp.fromDate(lastNicknameChangeAt!)
          : null,
      'privacyConsentGiven': privacyConsentGiven,
      'privacyConsentTimestamp':
          Timestamp.fromDate(privacyConsentTimestamp),
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
      'updatedAt': updatedAt != null
          ? Timestamp.fromDate(updatedAt!)
          : null,
      'isAdmin': isAdmin,
      'isModerator': isModerator,
      'isBetaTester': isBetaTester,
      'betaConsentGiven': betaConsentGiven,
      'betaConsentTimestamp': betaConsentTimestamp != null
          ? Timestamp.fromDate(betaConsentTimestamp!)
          : null,
      'crashReportingEnabled': crashReportingEnabled,
      'screenshotProtectionEnabled': screenshotProtectionEnabled,
    };

    data.removeWhere((_, value) => value == null);
    return data;
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

    return UserProfile.fromJson({
      'uid': doc.id,
      ...data,
    });
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
    int? trustScore,
    TrustLevel? trustLevel,
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
    bool? isBetaTester,
    bool? betaConsentGiven,
    DateTime? betaConsentTimestamp,
    bool? crashReportingEnabled,
    bool? screenshotProtectionEnabled,
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
      trustScore: trustScore ?? this.trustScore,
      trustLevel: trustLevel ?? this.trustLevel,
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
      isBetaTester: isBetaTester ?? this.isBetaTester,
      betaConsentGiven: betaConsentGiven ?? this.betaConsentGiven,
      betaConsentTimestamp: betaConsentTimestamp ?? this.betaConsentTimestamp,
      crashReportingEnabled:
          crashReportingEnabled ?? this.crashReportingEnabled,
      screenshotProtectionEnabled:
          screenshotProtectionEnabled ?? this.screenshotProtectionEnabled,
    );
  }

  static const ListEquality<String> _listEquality = ListEquality<String>();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;

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
        other.trustScore == trustScore &&
        other.trustLevel == trustLevel &&
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
        other.isBetaTester == isBetaTester &&
        other.betaConsentGiven == betaConsentGiven &&
        other.betaConsentTimestamp == betaConsentTimestamp &&
        other.crashReportingEnabled == crashReportingEnabled &&
        other.screenshotProtectionEnabled == screenshotProtectionEnabled;
  }

  @override
  int get hashCode {
    return Object.hashAll([
      uid,
      nickname,
      nicknameVerified,
      gender,
      school,
      schoolYear,
      _listEquality.hash(interests),
      _listEquality.hash(clubs),
      _listEquality.hash(searchKeywords),
      trustScore,
      trustLevel,
      anonymousPostsCount,
      createdAt,
      lastNicknameChangeAt,
      privacyConsentGiven,
      privacyConsentTimestamp,
      isMinor,
      guardianContact,
      parentalConsentGiven,
      parentalConsentTimestamp,
      onboardingComplete,
      allowAnonymousPosts,
      profileVisible,
      analyticsEnabled,
      updatedAt,
      isAdmin,
      isModerator,
      isBetaTester,
      betaConsentGiven,
      betaConsentTimestamp,
      crashReportingEnabled,
      screenshotProtectionEnabled,
    ]);
  }

  static List<String> _normalizeStringList(dynamic value) {
    if (value == null) return const [];
    if (value is Iterable) {
      return value.map((e) => e.toString()).toList(growable: false);
    }
    return const [];
  }

  static DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
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

  static List<String> _normalizeStringList(dynamic value) {
    if (value == null) return const [];
    if (value is Iterable) {
      return value.map((e) => e.toString()).toList(growable: false);
    }
    return const [];
  }

  static DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
