// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get uid => throw _privateConstructorUsedError;
  String get nickname => throw _privateConstructorUsedError;
  bool get nicknameVerified => throw _privateConstructorUsedError;
  String? get gender => throw _privateConstructorUsedError;
  String? get school => throw _privateConstructorUsedError;
  int get anonymousPostsCount => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastNicknameChangeAt => throw _privateConstructorUsedError;
  bool get privacyConsentGiven => throw _privateConstructorUsedError;
  DateTime get privacyConsentTimestamp => throw _privateConstructorUsedError;
  bool? get isMinor => throw _privateConstructorUsedError;
  String? get guardianContact => throw _privateConstructorUsedError;
  bool? get parentalConsentGiven => throw _privateConstructorUsedError;
  DateTime? get parentalConsentTimestamp => throw _privateConstructorUsedError;
  bool get allowAnonymousPosts => throw _privateConstructorUsedError;
  bool get profileVisible => throw _privateConstructorUsedError;
  DateTime? get updatedAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String uid,
      String nickname,
      bool nicknameVerified,
      String? gender,
      String? school,
      int anonymousPostsCount,
      DateTime createdAt,
      DateTime? lastNicknameChangeAt,
      bool privacyConsentGiven,
      DateTime privacyConsentTimestamp,
      bool? isMinor,
      String? guardianContact,
      bool? parentalConsentGiven,
      DateTime? parentalConsentTimestamp,
      bool allowAnonymousPosts,
      bool profileVisible,
      DateTime? updatedAt});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  final $Val _value;
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? nickname = null,
    Object? nicknameVerified = null,
    Object? gender = freezed,
    Object? school = freezed,
    Object? anonymousPostsCount = null,
    Object? createdAt = null,
    Object? lastNicknameChangeAt = freezed,
    Object? privacyConsentGiven = null,
    Object? privacyConsentTimestamp = null,
    Object? isMinor = freezed,
    Object? guardianContact = freezed,
    Object? parentalConsentGiven = freezed,
    Object? parentalConsentTimestamp = freezed,
    Object? allowAnonymousPosts = null,
    Object? profileVisible = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_value.copyWith(
      uid: null == uid
          ? _value.uid
          : uid,
      nickname: null == nickname
          ? _value.nickname
          : nickname,
      nicknameVerified: null == nicknameVerified
          ? _value.nicknameVerified
          : nicknameVerified,
      gender: freezed == gender
          ? _value.gender
          : gender,
      school: freezed == school
          ? _value.school
          : school,
      anonymousPostsCount: null == anonymousPostsCount
          ? _value.anonymousPostsCount
          : anonymousPostsCount,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt,
      lastNicknameChangeAt: freezed == lastNicknameChangeAt
          ? _value.lastNicknameChangeAt
          : lastNicknameChangeAt,
      privacyConsentGiven: null == privacyConsentGiven
          ? _value.privacyConsentGiven
          : privacyConsentGiven,
      privacyConsentTimestamp: null == privacyConsentTimestamp
          ? _value.privacyConsentTimestamp
          : privacyConsentTimestamp,
      isMinor: freezed == isMinor
          ? _value.isMinor
          : isMinor,
      guardianContact: freezed == guardianContact
          ? _value.guardianContact
          : guardianContact,
      parentalConsentGiven: freezed == parentalConsentGiven
          ? _value.parentalConsentGiven
          : parentalConsentGiven,
      parentalConsentTimestamp: freezed == parentalConsentTimestamp
          ? _value.parentalConsentTimestamp
          : parentalConsentTimestamp,
      allowAnonymousPosts: null == allowAnonymousPosts
          ? _value.allowAnonymousPosts
          : allowAnonymousPosts,
      profileVisible: null == profileVisible
          ? _value.profileVisible
          : profileVisible,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String uid,
      String nickname,
      bool nicknameVerified,
      String? gender,
      String? school,
      int anonymousPostsCount,
      DateTime createdAt,
      DateTime? lastNicknameChangeAt,
      bool privacyConsentGiven,
      DateTime privacyConsentTimestamp,
      bool? isMinor,
      String? guardianContact,
      bool? parentalConsentGiven,
      DateTime? parentalConsentTimestamp,
      bool allowAnonymousPosts,
      bool profileVisible,
      DateTime? updatedAt});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? uid = null,
    Object? nickname = null,
    Object? nicknameVerified = null,
    Object? gender = freezed,
    Object? school = freezed,
    Object? anonymousPostsCount = null,
    Object? createdAt = null,
    Object? lastNicknameChangeAt = freezed,
    Object? privacyConsentGiven = null,
    Object? privacyConsentTimestamp = null,
    Object? isMinor = freezed,
    Object? guardianContact = freezed,
    Object? parentalConsentGiven = freezed,
    Object? parentalConsentTimestamp = freezed,
    Object? allowAnonymousPosts = null,
    Object? profileVisible = null,
    Object? updatedAt = freezed,
  }) {
    return _then(_$UserProfileImpl(
      uid: null == uid
          ? _value.uid
          : uid,
      nickname: null == nickname
          ? _value.nickname
          : nickname,
      nicknameVerified: null == nicknameVerified
          ? _value.nicknameVerified
          : nicknameVerified,
      gender: freezed == gender
          ? _value.gender
          : gender,
      school: freezed == school
          ? _value.school
          : school,
      anonymousPostsCount: null == anonymousPostsCount
          ? _value.anonymousPostsCount
          : anonymousPostsCount,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt,
      lastNicknameChangeAt: freezed == lastNicknameChangeAt
          ? _value.lastNicknameChangeAt
          : lastNicknameChangeAt,
      privacyConsentGiven: null == privacyConsentGiven
          ? _value.privacyConsentGiven
          : privacyConsentGiven,
      privacyConsentTimestamp: null == privacyConsentTimestamp
          ? _value.privacyConsentTimestamp
          : privacyConsentTimestamp,
      isMinor: freezed == isMinor
          ? _value.isMinor
          : isMinor,
      guardianContact: freezed == guardianContact
          ? _value.guardianContact
          : guardianContact,
      parentalConsentGiven: freezed == parentalConsentGiven
          ? _value.parentalConsentGiven
          : parentalConsentGiven,
      parentalConsentTimestamp: freezed == parentalConsentTimestamp
          ? _value.parentalConsentTimestamp
          : parentalConsentTimestamp,
      allowAnonymousPosts: null == allowAnonymousPosts
          ? _value.allowAnonymousPosts
          : allowAnonymousPosts,
      profileVisible: null == profileVisible
          ? _value.profileVisible
          : profileVisible,
      updatedAt: freezed == updatedAt
          ? _value.updatedAt
          : updatedAt,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.uid,
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
      this.allowAnonymousPosts = true,
      this.profileVisible = true,
      this.updatedAt});

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String uid;
  @override
  final String nickname;
  @override
  final bool nicknameVerified;
  @override
  final String? gender;
  @override
  final String? school;
  @override
  @JsonKey()
  final int anonymousPostsCount;
  @override
  final DateTime createdAt;
  @override
  final DateTime? lastNicknameChangeAt;
  @override
  final bool privacyConsentGiven;
  @override
  final DateTime privacyConsentTimestamp;
  @override
  final bool? isMinor;
  @override
  final String? guardianContact;
  @override
  final bool? parentalConsentGiven;
  @override
  final DateTime? parentalConsentTimestamp;
  @override
  @JsonKey()
  final bool allowAnonymousPosts;
  @override
  @JsonKey()
  final bool profileVisible;
  @override
  final DateTime? updatedAt;

  @override
  String toString() {
    return 'UserProfile(uid: $uid, nickname: $nickname, nicknameVerified: $nicknameVerified, gender: $gender, school: $school, anonymousPostsCount: $anonymousPostsCount, createdAt: $createdAt, lastNicknameChangeAt: $lastNicknameChangeAt, privacyConsentGiven: $privacyConsentGiven, privacyConsentTimestamp: $privacyConsentTimestamp, isMinor: $isMinor, guardianContact: $guardianContact, parentalConsentGiven: $parentalConsentGiven, parentalConsentTimestamp: $parentalConsentTimestamp, allowAnonymousPosts: $allowAnonymousPosts, profileVisible: $profileVisible, updatedAt: $updatedAt)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.uid, uid) || other.uid == uid) &&
            (identical(other.nickname, nickname) ||
                other.nickname == nickname) &&
            (identical(other.nicknameVerified, nicknameVerified) ||
                other.nicknameVerified == nicknameVerified) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.school, school) || other.school == school) &&
            (identical(other.anonymousPostsCount, anonymousPostsCount) ||
                other.anonymousPostsCount == anonymousPostsCount) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastNicknameChangeAt, lastNicknameChangeAt) ||
                other.lastNicknameChangeAt == lastNicknameChangeAt) &&
            (identical(other.privacyConsentGiven, privacyConsentGiven) ||
                other.privacyConsentGiven == privacyConsentGiven) &&
            (identical(other.privacyConsentTimestamp, privacyConsentTimestamp) ||
                other.privacyConsentTimestamp == privacyConsentTimestamp) &&
            (identical(other.isMinor, isMinor) || other.isMinor == isMinor) &&
            (identical(other.guardianContact, guardianContact) ||
                other.guardianContact == guardianContact) &&
            (identical(other.parentalConsentGiven, parentalConsentGiven) ||
                other.parentalConsentGiven == parentalConsentGiven) &&
            (identical(other.parentalConsentTimestamp, parentalConsentTimestamp) ||
                other.parentalConsentTimestamp == parentalConsentTimestamp) &&
            (identical(other.allowAnonymousPosts, allowAnonymousPosts) ||
                other.allowAnonymousPosts == allowAnonymousPosts) &&
            (identical(other.profileVisible, profileVisible) ||
                other.profileVisible == profileVisible) &&
            (identical(other.updatedAt, updatedAt) ||
                other.updatedAt == updatedAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      uid,
      nickname,
      nicknameVerified,
      gender,
      school,
      anonymousPostsCount,
      createdAt,
      lastNicknameChangeAt,
      privacyConsentGiven,
      privacyConsentTimestamp,
      isMinor,
      guardianContact,
      parentalConsentGiven,
      parentalConsentTimestamp,
      allowAnonymousPosts,
      profileVisible,
      updatedAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final String uid,
      required final String nickname,
      required final bool nicknameVerified,
      final String? gender,
      final String? school,
      final int anonymousPostsCount,
      required final DateTime createdAt,
      final DateTime? lastNicknameChangeAt,
      required final bool privacyConsentGiven,
      required final DateTime privacyConsentTimestamp,
      final bool? isMinor,
      final String? guardianContact,
      final bool? parentalConsentGiven,
      final DateTime? parentalConsentTimestamp,
      final bool allowAnonymousPosts,
      final bool profileVisible,
      final DateTime? updatedAt}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get uid;
  @override
  String get nickname;
  @override
  bool get nicknameVerified;
  @override
  String? get gender;
  @override
  String? get school;
  @override
  int get anonymousPostsCount;
  @override
  DateTime get createdAt;
  @override
  DateTime? get lastNicknameChangeAt;
  @override
  bool get privacyConsentGiven;
  @override
  DateTime get privacyConsentTimestamp;
  @override
  bool? get isMinor;
  @override
  String? get guardianContact;
  @override
  bool? get parentalConsentGiven;
  @override
  DateTime? get parentalConsentTimestamp;
  @override
  bool get allowAnonymousPosts;
  @override
  bool get profileVisible;
  @override
  DateTime? get updatedAt;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
