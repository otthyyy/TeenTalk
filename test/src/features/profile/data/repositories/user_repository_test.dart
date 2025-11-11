import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/profile/data/repositories/user_repository.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/trust_level.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/user_profile.dart';

void main() {
  group('UserRepository', () {
    late FakeFirebaseFirestore firestore;
    late UserRepository repository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      repository = UserRepository(firestore);
    });

    Future<void> _createUser({
      required String uid,
      required String nickname,
      String? school,
      List<String> interests = const [],
    }) async {
      await firestore.collection('users').doc(uid).set({
        'uid': uid,
        'nickname': nickname,
        'nicknameLowercase': nickname.toLowerCase(),
        'nicknameVerified': true,
        'school': school,
        'interests': interests,
        'clubs': [],
        'searchKeywords': UserProfile.buildSearchKeywords(
          nickname,
          school,
          null,
          interests,
          [],
        ),
        'createdAt': Timestamp.now(),
        'privacyConsentGiven': true,
        'privacyConsentTimestamp': Timestamp.now(),
        'onboardingComplete': true,
        'trustLevel': TrustLevel.newcomer.value,
      });
    }

    group('isNicknameAvailable', () {
      test('returns true when nickname is available', () async {
        final isAvailable = await repository.isNicknameAvailable('NewNick');
        expect(isAvailable, true);
      });

      test('returns false when nickname is taken (case-insensitive)', () async {
        await _createUser(uid: 'user1', nickname: 'TakenNick');

        final isAvailable1 = await repository.isNicknameAvailable('TakenNick');
        final isAvailable2 = await repository.isNicknameAvailable('takennick');
        final isAvailable3 = await repository.isNicknameAvailable('TAKENNICK');

        expect(isAvailable1, false);
        expect(isAvailable2, false);
        expect(isAvailable3, false);
      });

      test('ignores whitespace when checking availability', () async {
        await _createUser(uid: 'user1', nickname: 'SpaceyNick');

        final isAvailable = await repository.isNicknameAvailable('  SpaceyNick  ');
        expect(isAvailable, false);
      });
    });

    group('getUserProfile', () {
      test('returns null for non-existent user', () async {
        final profile = await repository.getUserProfile('nonexistent');
        expect(profile, isNull);
      });

      test('returns profile with correct data', () async {
        await _createUser(
          uid: 'user1',
          nickname: 'TestUser',
          school: 'Harvard',
          interests: ['coding', 'music'],
        );

        final profile = await repository.getUserProfile('user1');

        expect(profile, isNotNull);
        expect(profile!.uid, 'user1');
        expect(profile.nickname, 'TestUser');
        expect(profile.school, 'Harvard');
        expect(profile.interests, ['coding', 'music']);
      });
    });

    group('createUserProfile', () {
      test('creates profile with normalized nickname and search keywords', () async {
        final profile = UserProfile(
          uid: 'user1',
          nickname: '  TestUser  ',
          nicknameVerified: true,
          school: 'Harvard',
          interests: ['sports', 'art'],
          clubs: ['chess'],
          createdAt: DateTime.now(),
          privacyConsentGiven: true,
          privacyConsentTimestamp: DateTime.now(),
        );

        await repository.createUserProfile(profile);

        final doc = await firestore.collection('users').doc('user1').get();

        expect(doc.exists, true);
        expect(doc.get('nicknameLowercase'), 'testuser');
        expect(doc.get('searchKeywords'), isNotEmpty);
        
        final keywords = List<String>.from(doc.get('searchKeywords'));
        expect(keywords, contains('testuser'));
        expect(keywords, contains('harvard'));
        expect(keywords, contains('sports'));
        expect(keywords, contains('art'));
        expect(keywords, contains('chess'));
      });
    });

    group('updateUserProfile', () {
      test('updates profile and regenerates search keywords', () async {
        await _createUser(
          uid: 'user1',
          nickname: 'OldNick',
          school: 'MIT',
          interests: ['old'],
        );

        final success = await repository.updateUserProfile('user1', {
          'interests': ['new', 'interests'],
        });

        expect(success, true);

        final updated = await firestore.collection('users').doc('user1').get();
        final keywords = List<String>.from(updated.get('searchKeywords'));
        
        expect(keywords, contains('oldnick'));
        expect(keywords, contains('mit'));
        expect(keywords, contains('new'));
        expect(keywords, contains('interests'));
      });

      test('rejects nickname change if new nickname is taken', () async {
        await _createUser(uid: 'user1', nickname: 'User1');
        await _createUser(uid: 'user2', nickname: 'User2');

        final success = await repository.updateUserProfile('user1', {
          'nickname': 'User2',
        });

        expect(success, false);

        final doc = await firestore.collection('users').doc('user1').get();
        expect(doc.get('nickname'), 'User1');
      });

      test('updates nickname with normalized form and updates search keywords', () async {
        await _createUser(uid: 'user1', nickname: 'OldNick');

        final success = await repository.updateUserProfile('user1', {
          'nickname': 'NewNick',
        });

        expect(success, true);

        final updated = await firestore.collection('users').doc('user1').get();
        expect(updated.get('nickname'), 'NewNick');
        expect(updated.get('nicknameLowercase'), 'newnick');
        expect(updated.get('nicknameVerified'), true);
        expect(updated.get('lastNicknameChangeAt'), isNotNull);
        
        final keywords = List<String>.from(updated.get('searchKeywords'));
        expect(keywords, contains('newnick'));
      });

      test('updates multiple fields and regenerates keywords', () async {
        await _createUser(
          uid: 'user1',
          nickname: 'User1',
          school: 'MIT',
          interests: ['old'],
        );

        final success = await repository.updateUserProfile('user1', {
          'school': 'Harvard',
          'schoolYear': 'Sophomore',
          'interests': ['new', 'cool'],
          'clubs': ['debate', 'robotics'],
        });

        expect(success, true);

        final updated = await firestore.collection('users').doc('user1').get();
        final keywords = List<String>.from(updated.get('searchKeywords'));
        
        expect(keywords, contains('user1'));
        expect(keywords, contains('harvard'));
        expect(keywords, contains('sophomore'));
        expect(keywords, contains('new'));
        expect(keywords, contains('cool'));
        expect(keywords, contains('debate'));
        expect(keywords, contains('robotics'));
      });
    });

    group('canChangeNickname', () {
      test('returns true when user has never changed nickname', () async {
        await _createUser(uid: 'user1', nickname: 'User1');

        final canChange = await repository.canChangeNickname('user1');
        expect(canChange, true);
      });

      test('returns false when changed recently', () async {
        await firestore.collection('users').doc('user1').set({
          'uid': 'user1',
          'nickname': 'User1',
          'nicknameLowercase': 'user1',
          'nicknameVerified': true,
          'lastNicknameChangeAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: 15)),
          ),
          'createdAt': Timestamp.now(),
          'privacyConsentGiven': true,
          'privacyConsentTimestamp': Timestamp.now(),
          'trustLevel': TrustLevel.newcomer.value,
        });

        final canChange = await repository.canChangeNickname('user1');
        expect(canChange, false);
      });

      test('returns true when changed over 30 days ago', () async {
        await firestore.collection('users').doc('user1').set({
          'uid': 'user1',
          'nickname': 'User1',
          'nicknameLowercase': 'user1',
          'nicknameVerified': true,
          'lastNicknameChangeAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: 31)),
          ),
          'createdAt': Timestamp.now(),
          'privacyConsentGiven': true,
          'privacyConsentTimestamp': Timestamp.now(),
          'trustLevel': TrustLevel.newcomer.value,
        });

        final canChange = await repository.canChangeNickname('user1');
        expect(canChange, true);
      });
    });

    group('getDaysUntilNicknameChange', () {
      test('returns 0 when user has never changed nickname', () async {
        await _createUser(uid: 'user1', nickname: 'User1');

        final days = await repository.getDaysUntilNicknameChange('user1');
        expect(days, 0);
      });

      test('returns correct days remaining', () async {
        await firestore.collection('users').doc('user1').set({
          'uid': 'user1',
          'nickname': 'User1',
          'nicknameLowercase': 'user1',
          'nicknameVerified': true,
          'lastNicknameChangeAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: 20)),
          ),
          'createdAt': Timestamp.now(),
          'privacyConsentGiven': true,
          'privacyConsentTimestamp': Timestamp.now(),
          'trustLevel': TrustLevel.newcomer.value,
        });

        final days = await repository.getDaysUntilNicknameChange('user1');
        expect(days, 10);
      });

      test('returns 0 when enough time has passed', () async {
        await firestore.collection('users').doc('user1').set({
          'uid': 'user1',
          'nickname': 'User1',
          'nicknameLowercase': 'user1',
          'nicknameVerified': true,
          'lastNicknameChangeAt': Timestamp.fromDate(
            DateTime.now().subtract(Duration(days: 35)),
          ),
          'createdAt': Timestamp.now(),
          'privacyConsentGiven': true,
          'privacyConsentTimestamp': Timestamp.now(),
          'trustLevel': TrustLevel.newcomer.value,
        });

        final days = await repository.getDaysUntilNicknameChange('user1');
        expect(days, 0);
      });
    });
  });
}
