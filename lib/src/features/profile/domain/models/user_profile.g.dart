// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserProfileImpl _$$UserProfileImplFromJson(Map<String, dynamic> json) =>
    _$UserProfileImpl(
      uid: json['uid'] as String,
      nickname: json['nickname'] as String,
      nicknameVerified: json['nicknameVerified'] as bool,
      gender: json['gender'] as String?,
      school: json['school'] as String?,
      anonymousPostsCount: json['anonymousPostsCount'] as int? ?? 0,
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastNicknameChangeAt: json['lastNicknameChangeAt'] == null
          ? null
          : DateTime.parse(json['lastNicknameChangeAt'] as String),
      privacyConsentGiven: json['privacyConsentGiven'] as bool,
      privacyConsentTimestamp:
          DateTime.parse(json['privacyConsentTimestamp'] as String),
      isMinor: json['isMinor'] as bool?,
      guardianContact: json['guardianContact'] as String?,
      parentalConsentGiven: json['parentalConsentGiven'] as bool?,
      parentalConsentTimestamp: json['parentalConsentTimestamp'] == null
          ? null
          : DateTime.parse(json['parentalConsentTimestamp'] as String),
      allowAnonymousPosts: json['allowAnonymousPosts'] as bool? ?? true,
      profileVisible: json['profileVisible'] as bool? ?? true,
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$UserProfileImplToJson(_$UserProfileImpl instance) =>
    <String, dynamic>{
      'uid': instance.uid,
      'nickname': instance.nickname,
      'nicknameVerified': instance.nicknameVerified,
      'gender': instance.gender,
      'school': instance.school,
      'anonymousPostsCount': instance.anonymousPostsCount,
      'createdAt': instance.createdAt.toIso8601String(),
      'lastNicknameChangeAt': instance.lastNicknameChangeAt?.toIso8601String(),
      'privacyConsentGiven': instance.privacyConsentGiven,
      'privacyConsentTimestamp':
          instance.privacyConsentTimestamp.toIso8601String(),
      'isMinor': instance.isMinor,
      'guardianContact': instance.guardianContact,
      'parentalConsentGiven': instance.parentalConsentGiven,
      'parentalConsentTimestamp':
          instance.parentalConsentTimestamp?.toIso8601String(),
      'allowAnonymousPosts': instance.allowAnonymousPosts,
      'profileVisible': instance.profileVisible,
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
