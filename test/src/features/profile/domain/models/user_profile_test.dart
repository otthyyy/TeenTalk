import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/trust_level.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/user_profile.dart';

dynamic _timestampFromDate(DateTime date) => Timestamp.fromDate(date);

dynamic _timestampOrNull(DateTime? date) => date != null ? Timestamp.fromDate(date) : null;

void main() {
  group('UserProfile serialization', () {
    test('fromJson handles null and missing fields safely', () {
      final now = DateTime.now();
      final json = <String, dynamic>{
        'uid': 'user-123',
        'nickname': null,
        'nicknameVerified': null,
        'gender': null,
        'school': null,
        'anonymousPostsCount': null,
        'createdAt': _timestampFromDate(now),
        'lastNicknameChangeAt': null,
        'privacyConsentGiven': null,
        'privacyConsentTimestamp': null,
        'isMinor': null,
        'guardianContact': null,
        'parentalConsentGiven': null,
        'parentalConsentTimestamp': null,
        'onboardingComplete': null,
        'allowAnonymousPosts': null,
        'profileVisible': null,
        'updatedAt': null,
        'isAdmin': null,
        'isModerator': null,
        'trustLevel': null,
      };

      final profile = UserProfile.fromJson(json);

      expect(profile.uid, 'user-123');
      expect(profile.nickname, isEmpty);
      expect(profile.nicknameVerified, isFalse);
      expect(profile.gender, isNull);
      expect(profile.school, isNull);
      expect(profile.anonymousPostsCount, 0);
      expect(profile.createdAt, now);
      expect(profile.lastNicknameChangeAt, isNull);
      expect(profile.privacyConsentGiven, isFalse);
      expect(profile.privacyConsentTimestamp.day, now.day);
      expect(profile.onboardingComplete, isFalse);
      expect(profile.allowAnonymousPosts, isTrue);
      expect(profile.profileVisible, isTrue);
      expect(profile.updatedAt, isNull);
      expect(profile.isAdmin, isFalse);
      expect(profile.isModerator, isFalse);
      expect(profile.trustLevel, TrustLevel.newcomer);
    });

    test('fromFirestore handles missing fields safely', () {
      final now = DateTime.now();
      final doc = _FakeDocumentSnapshot({
        'nickname': null,
        'nicknameVerified': null,
        'gender': null,
        'school': null,
        'anonymousPostsCount': null,
        'createdAt': _timestampFromDate(now),
        'lastNicknameChangeAt': null,
        'privacyConsentGiven': null,
        'privacyConsentTimestamp': null,
        'isMinor': null,
        'guardianContact': null,
        'parentalConsentGiven': null,
        'parentalConsentTimestamp': null,
        'onboardingComplete': null,
        'allowAnonymousPosts': null,
        'profileVisible': null,
        'updatedAt': null,
        'isAdmin': null,
        'isModerator': null,
        'trustLevel': null,
      }, 'doc-123');

      final profile = UserProfile.fromFirestore(doc);

      expect(profile.uid, 'doc-123');
      expect(profile.nickname, isEmpty);
      expect(profile.anonymousPostsCount, 0);
      expect(profile.createdAt, now);
      expect(profile.privacyConsentTimestamp.day, now.day);
      expect(profile.onboardingComplete, isFalse);
      expect(profile.allowAnonymousPosts, isTrue);
      expect(profile.profileVisible, isTrue);
      expect(profile.trustLevel, TrustLevel.newcomer);
    });

    test('toJson converts DateTime fields to Timestamp', () {
      final createdAt = DateTime(2024, 1, 1);
      final updatedAt = DateTime(2024, 6, 1);
      final profile = UserProfile(
        uid: 'user-123',
        nickname: 'TestUser',
        nicknameVerified: false,
        createdAt: createdAt,
        privacyConsentGiven: true,
        privacyConsentTimestamp: createdAt,
        lastNicknameChangeAt: updatedAt,
        parentalConsentTimestamp: updatedAt,
        updatedAt: updatedAt,
        trustLevel: TrustLevel.trusted,
      );

      final json = profile.toJson();

      expect(json['createdAt'], isA<Timestamp>());
      expect(json['lastNicknameChangeAt'], isA<Timestamp>());
      expect(json['parentalConsentTimestamp'], isA<Timestamp>());
      expect(json['updatedAt'], isA<Timestamp>());
      expect(json['onboardingComplete'], isFalse);
      expect(json['trustLevel'], 'trusted');
    });
  });
}

class _FakeDocumentSnapshot implements DocumentSnapshot<Map<String, dynamic>> {
  final Map<String, dynamic> _data;
  final String _id;

  _FakeDocumentSnapshot(this._data, this._id);

  @override
  Map<String, dynamic>? data() => _data;

  @override
  String get id => _id;

  // The following members are not needed for the tests.
  @override
  SnapshotMetadata get metadata => throw UnimplementedError();

  @override
  Reference get reference => throw UnimplementedError();

  @override
  bool get exists => true;

  @override
  dynamic get(Object field) => _data[field];

  @override
  T data<T>([GetOptions? options]) => _data as T;

  @override
  dynamic operator [](String key) => _data[key];

  @override
  bool get isEqual => false;
}
