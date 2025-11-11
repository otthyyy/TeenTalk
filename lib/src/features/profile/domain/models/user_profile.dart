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
      betaConsentTimestamp: json['betaConsentTimestamp'] != null
          ? (json['betaConsentTimestamp'] as Timestamp).toDate()
          : null,
      crashReportingEnabled: json['crashReportingEnabled'] as bool? ?? true,
      screenshotProtectionEnabled:
          json['screenshotProtectionEnabled'] as bool? ?? true,
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
    }..removeWhere((_, value) => value == null);
      'screenshotProtectionEnabled': screenshotProtectionEnabled,
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

    return UserProfile.fromJson({
      'uid': doc.id,
      ...data,
    });
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
      screenshotProtectionEnabled:
          data['screenshotProtectionEnabled'] as bool? ?? true,
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
      crashReportingEnabled: crashReportingEnabled ?? this.crashReportingEnabled,
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
    final keywords = <String>{};

    void addKeyword(String? rawValue) {
      if (rawValue == null) return;
      final trimmed = rawValue.trim();
      if (trimmed.isEmpty) return;

      final lower = trimmed.toLowerCase();
      keywords.add(lower);

      final sanitized = _stripDiacritics(lower);
      keywords.add(sanitized);
    }

    addKeyword(nickname);
    addKeyword(school);
    addKeyword(schoolYear);

    for (final interest in interests) {
      if (interest.isNotEmpty) {
        keywords.add(interest.toLowerCase());
      }
      addKeyword(interest);
    }

    for (final club in clubs) {
      if (club.isNotEmpty) {
        keywords.add(club.toLowerCase());
      }
    }
    return keywords.toList(growable: false);
      addKeyword(club);
    }

    keywords.removeWhere((element) => element.trim().isEmpty);
    return keywords.toList();
  }

  static String _stripDiacritics(String value) {
    final buffer = StringBuffer();
    for (final rune in value.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(_diacriticReplacements[char] ?? char);
    }
    return buffer.toString();
  }

  static const Map<String, String> _diacriticReplacements = {
    'á': 'a',
    'à': 'a',
    'â': 'a',
    'ä': 'a',
    'ã': 'a',
    'å': 'a',
    'ā': 'a',
    'ă': 'a',
    'ą': 'a',
    'ǎ': 'a',
    'æ': 'ae',
    'ç': 'c',
    'ć': 'c',
    'č': 'c',
    'ĉ': 'c',
    'ċ': 'c',
    'ď': 'd',
    'đ': 'd',
    'ð': 'd',
    'é': 'e',
    'è': 'e',
    'ê': 'e',
    'ë': 'e',
    'ē': 'e',
    'ė': 'e',
    'ę': 'e',
    'ě': 'e',
    'ğ': 'g',
    'ĝ': 'g',
    'ġ': 'g',
    'ģ': 'g',
    'ĥ': 'h',
    'ħ': 'h',
    'í': 'i',
    'ì': 'i',
    'î': 'i',
    'ï': 'i',
    'ī': 'i',
    'į': 'i',
    'ı': 'i',
    'ĵ': 'j',
    'ķ': 'k',
    'ĺ': 'l',
    'ľ': 'l',
    'ļ': 'l',
    'ł': 'l',
    'ñ': 'n',
    'ń': 'n',
    'ň': 'n',
    'ņ': 'n',
    'ŋ': 'n',
    'ó': 'o',
    'ò': 'o',
    'ô': 'o',
    'ö': 'o',
    'õ': 'o',
    'ő': 'o',
    'ō': 'o',
    'ø': 'o',
    'œ': 'oe',
    'ś': 's',
    'š': 's',
    'ş': 's',
    'ș': 's',
    'ŝ': 's',
    'ť': 't',
    'ţ': 't',
    'ț': 't',
    'ŧ': 't',
    'þ': 'th',
    'ú': 'u',
    'ù': 'u',
    'û': 'u',
    'ü': 'u',
    'ū': 'u',
    'ů': 'u',
    'ű': 'u',
    'ŭ': 'u',
    'ų': 'u',
    'ŵ': 'w',
    'ý': 'y',
    'ÿ': 'y',
    'ŷ': 'y',
    'ž': 'z',
    'ź': 'z',
    'ż': 'z',
    'ß': 'ss',
  };
}
