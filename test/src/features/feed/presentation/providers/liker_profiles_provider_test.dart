import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/auth/data/services/firebase_auth_service.dart';
import 'package:teen_talk_app/src/features/feed/presentation/providers/liker_profiles_provider.dart';
import 'package:teen_talk_app/src/features/messages/presentation/providers/direct_messages_provider.dart';
import 'package:teen_talk_app/src/features/profile/data/repositories/user_repository.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/user_profile.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/trust_level.dart';

class MockUserRepository extends UserRepository {
  final Map<String, UserProfile> _profiles;

  MockUserRepository(this._profiles) : super(null as dynamic);

  @override
  Future<UserProfile?> getUserProfile(String uid) async {
    return _profiles[uid];
  }
}

class MockFirebaseAuthService implements FirebaseAuthService {
  final String? _currentUserId;

  MockFirebaseAuthService(this._currentUserId);

  @override
  dynamic get currentUser => _currentUserId != null ? MockUser(_currentUserId) : null;

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockUser {
  final String uid;
  MockUser(this.uid);
}

void main() {
  group('LikerProfilesProvider Tests', () {
    late ProviderContainer container;
    late Map<String, UserProfile> mockProfiles;

    setUp(() {
      mockProfiles = {
        'user1': UserProfile(
          uid: 'user1',
          nickname: 'Alice',
          nicknameVerified: true,
          school: 'Test School',
          createdAt: DateTime.now(),
          privacyConsentGiven: true,
          privacyConsentTimestamp: DateTime.now(),
          trustLevel: TrustLevel.member,
        ),
        'user2': UserProfile(
          uid: 'user2',
          nickname: 'Bob',
          nicknameVerified: true,
          school: 'Test School',
          createdAt: DateTime.now(),
          privacyConsentGiven: true,
          privacyConsentTimestamp: DateTime.now(),
          trustLevel: TrustLevel.trusted,
        ),
        'user3': UserProfile(
          uid: 'user3',
          nickname: 'Charlie',
          nicknameVerified: true,
          school: 'Another School',
          createdAt: DateTime.now(),
          privacyConsentGiven: true,
          privacyConsentTimestamp: DateTime.now(),
          trustLevel: TrustLevel.newcomer,
        ),
      };
    });

    tearDown(() {
      container.dispose();
    });

    test('returns empty list for empty liker IDs', () async {
      container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(MockUserRepository(mockProfiles)),
          firebaseAuthServiceProvider.overrideWithValue(MockFirebaseAuthService('currentUser')),
          blockedUsersProvider.overrideWith((ref) => []),
        ],
      );

      final profiles = await container.read(likerProfilesProvider([]).future);
      expect(profiles, isEmpty);
    });

    test('returns profiles for valid liker IDs', () async {
      container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(MockUserRepository(mockProfiles)),
          firebaseAuthServiceProvider.overrideWithValue(MockFirebaseAuthService('currentUser')),
          blockedUsersProvider.overrideWith((ref) => []),
        ],
      );

      final likerIds = ['user1', 'user2'];
      final profiles = await container.read(likerProfilesProvider(likerIds).future);

      expect(profiles.length, 2);
      expect(profiles[0].uid, 'user1');
      expect(profiles[0].nickname, 'Alice');
      expect(profiles[1].uid, 'user2');
      expect(profiles[1].nickname, 'Bob');
    });

    test('deduplicates liker IDs', () async {
      container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(MockUserRepository(mockProfiles)),
          firebaseAuthServiceProvider.overrideWithValue(MockFirebaseAuthService('currentUser')),
          blockedUsersProvider.overrideWith((ref) => []),
        ],
      );

      final likerIds = ['user1', 'user1', 'user2', 'user2'];
      final profiles = await container.read(likerProfilesProvider(likerIds).future);

      expect(profiles.length, 2);
      expect(profiles.map((p) => p.uid).toSet(), {'user1', 'user2'});
    });

    test('filters out blocked users', () async {
      container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(MockUserRepository(mockProfiles)),
          firebaseAuthServiceProvider.overrideWithValue(MockFirebaseAuthService('currentUser')),
          blockedUsersProvider.overrideWith((ref) => ['user2']),
        ],
      );

      final likerIds = ['user1', 'user2', 'user3'];
      final profiles = await container.read(likerProfilesProvider(likerIds).future);

      expect(profiles.length, 2);
      expect(profiles.map((p) => p.uid).toSet(), {'user1', 'user3'});
      expect(profiles.any((p) => p.uid == 'user2'), false);
    });

    test('filters out null profiles', () async {
      container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(MockUserRepository(mockProfiles)),
          firebaseAuthServiceProvider.overrideWithValue(MockFirebaseAuthService('currentUser')),
          blockedUsersProvider.overrideWith((ref) => []),
        ],
      );

      final likerIds = ['user1', 'nonexistent', 'user2'];
      final profiles = await container.read(likerProfilesProvider(likerIds).future);

      expect(profiles.length, 2);
      expect(profiles.map((p) => p.uid).toSet(), {'user1', 'user2'});
    });

    test('handles multiple blocked users', () async {
      container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(MockUserRepository(mockProfiles)),
          firebaseAuthServiceProvider.overrideWithValue(MockFirebaseAuthService('currentUser')),
          blockedUsersProvider.overrideWith((ref) => ['user1', 'user3']),
        ],
      );

      final likerIds = ['user1', 'user2', 'user3'];
      final profiles = await container.read(likerProfilesProvider(likerIds).future);

      expect(profiles.length, 1);
      expect(profiles[0].uid, 'user2');
      expect(profiles[0].nickname, 'Bob');
    });

    test('returns all profiles when no user is logged in', () async {
      container = ProviderContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(MockUserRepository(mockProfiles)),
          firebaseAuthServiceProvider.overrideWithValue(MockFirebaseAuthService(null)),
          blockedUsersProvider.overrideWith((ref) => []),
        ],
      );

      final likerIds = ['user1', 'user2', 'user3'];
      final profiles = await container.read(likerProfilesProvider(likerIds).future);

      expect(profiles.length, 3);
      expect(profiles.map((p) => p.uid).toSet(), {'user1', 'user2', 'user3'});
    });
  });
}
