import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:teen_talk_app/src/features/search/data/models/search_filters.dart';
import 'package:teen_talk_app/src/features/search/data/repositories/search_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late SearchRepository repository;

  setUp(() async {
    firestore = FakeFirebaseFirestore();
    repository = SearchRepository(firestore: firestore);

    await firestore.collection('users').doc('user1').set({
      'nickname': 'Alpha',
      'nicknameLowercase': 'alpha',
      'profileVisible': true,
      'interests': ['Music', 'Art'],
      'trustLevel': 80.0,
      'schoolYear': 10,
      'createdAt': Timestamp.now(),
      'privacyConsentGiven': true,
      'privacyConsentTimestamp': Timestamp.now(),
    });

    await firestore.collection('users').doc('user2').set({
      'nickname': 'Beta',
      'nicknameLowercase': 'beta',
      'profileVisible': true,
      'interests': ['Sports'],
      'trustLevel': 45.0,
      'schoolYear': 12,
      'createdAt': Timestamp.now(),
      'privacyConsentGiven': true,
      'privacyConsentTimestamp': Timestamp.now(),
    });

    await firestore.collection('users').doc('user3').set({
      'nickname': 'Gamma',
      'nicknameLowercase': 'gamma',
      'profileVisible': false,
      'interests': ['Gaming'],
      'trustLevel': 70.0,
      'schoolYear': 11,
      'createdAt': Timestamp.now(),
      'privacyConsentGiven': true,
      'privacyConsentTimestamp': Timestamp.now(),
    });
  });

  group('SearchRepository', () {
    test('returns only visible profiles', () async {
      final results = await repository.searchProfiles(const SearchFilters());

      expect(results.length, 2);
      expect(results.every((profile) => profile.profileVisible), isTrue);
    });

    test('filters by interests using array-contains-any', () async {
      final filters = SearchFilters(interests: const ['Music']);

      final results = await repository.searchProfiles(filters);

      expect(results.length, 1);
      expect(results.first.nickname, 'Alpha');
    });

    test('filters by school year range', () async {
      final filters = SearchFilters(minSchoolYear: 11, maxSchoolYear: 12);

      final results = await repository.searchProfiles(filters);

      expect(results.length, 1);
      expect(results.first.nickname, 'Beta');
    });

    test('filters by trust level threshold', () async {
      final filters = SearchFilters(minTrustLevel: 70);

      final results = await repository.searchProfiles(filters);

      expect(results.length, 1);
      expect(results.first.nickname, 'Alpha');
    });

    test('supports combined filters', () async {
      final filters = SearchFilters(
        interests: const ['Music', 'Art'],
        minTrustLevel: 70,
        minSchoolYear: 9,
        maxSchoolYear: 11,
      );

      final results = await repository.searchProfiles(filters);

      expect(results.length, 1);
      expect(results.first.nickname, 'Alpha');
    });
  });
}
