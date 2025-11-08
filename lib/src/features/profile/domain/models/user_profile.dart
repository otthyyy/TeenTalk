import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    required String uid,
    required String nickname,
    required bool nicknameVerified,
    String? gender,
    String? school,
    @Default(0) int anonymousPostsCount,
    required DateTime createdAt,
    DateTime? lastNicknameChangeAt,
    required bool privacyConsentGiven,
    required DateTime privacyConsentTimestamp,
    bool? isMinor,
    String? guardianContact,
    bool? parentalConsentGiven,
    DateTime? parentalConsentTimestamp,
    @Default(true) bool allowAnonymousPosts,
    @Default(true) bool profileVisible,
    DateTime? updatedAt,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: doc.id,
      nickname: data['nickname'] as String,
      nicknameVerified: data['nicknameVerified'] as bool? ?? false,
      gender: data['gender'] as String?,
      school: data['school'] as String?,
      anonymousPostsCount: data['anonymousPostsCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
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
      allowAnonymousPosts: data['allowAnonymousPosts'] as bool? ?? true,
      profileVisible: data['profileVisible'] as bool? ?? true,
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : null,
    );
  }

  static Map<String, dynamic> toFirestore(UserProfile profile) {
    return {
      'nickname': profile.nickname,
      'nicknameVerified': profile.nicknameVerified,
      'gender': profile.gender,
      'school': profile.school,
      'anonymousPostsCount': profile.anonymousPostsCount,
      'createdAt': Timestamp.fromDate(profile.createdAt),
      'lastNicknameChangeAt': profile.lastNicknameChangeAt != null
          ? Timestamp.fromDate(profile.lastNicknameChangeAt!)
          : null,
      'privacyConsentGiven': profile.privacyConsentGiven,
      'privacyConsentTimestamp':
          Timestamp.fromDate(profile.privacyConsentTimestamp),
      'isMinor': profile.isMinor,
      'guardianContact': profile.guardianContact,
      'parentalConsentGiven': profile.parentalConsentGiven,
      'parentalConsentTimestamp': profile.parentalConsentTimestamp != null
          ? Timestamp.fromDate(profile.parentalConsentTimestamp!)
          : null,
      'allowAnonymousPosts': profile.allowAnonymousPosts,
      'profileVisible': profile.profileVisible,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    };
  }
}
