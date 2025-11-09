import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/profile/presentation/pages/profile_page.dart';
import 'package:teen_talk_app/src/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/user_profile.dart';
import 'package:teen_talk_app/src/features/auth/data/services/firebase_auth_service.dart';
import 'package:teen_talk_app/src/features/auth/presentation/providers/auth_provider.dart';

class FakeFirebaseAuthService extends FirebaseAuthService {
  bool signOutCalled = false;

  @override
  Future<void> signOut() async {
    signOutCalled = true;
  }
}

void main() {
  late FakeFirebaseAuthService fakeAuthService;

  setUp(() {
    fakeAuthService = FakeFirebaseAuthService();
  });

  Widget createTestWidget(UserProfile? profile) {
    return ProviderScope(
      overrides: [
        userProfileProvider.overrideWith((ref) => Stream.value(profile)),
        firebaseAuthServiceProvider.overrideWithValue(fakeAuthService),
      ],
      child: const MaterialApp(
        home: ProfilePage(),
      ),
    );
  }

  group('ProfilePage', () {
    testWidgets('displays loading indicator when profile is loading', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith((ref) => const Stream.empty()),
          ],
          child: const MaterialApp(
            home: ProfilePage(),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays empty state when profile is null', (tester) async {
      await tester.pumpWidget(createTestWidget(null));
      await tester.pump();

      expect(find.text('No profile found'), findsOneWidget);
      expect(find.text('Please complete your profile setup to continue'), findsOneWidget);
    });

    testWidgets('displays profile with all required fields', (tester) async {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: 'TestUser',
        nicknameVerified: true,
        createdAt: DateTime(2024, 1, 1),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime(2024, 1, 1),
        anonymousPostsCount: 5,
        allowAnonymousPosts: true,
        profileVisible: true,
      );

      await tester.pumpWidget(createTestWidget(profile));
      await tester.pump();

      expect(find.text('TestUser'), findsOneWidget);
      expect(find.text('Verified'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('handles profile with null optional fields gracefully', (tester) async {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: 'TestUser',
        nicknameVerified: false,
        gender: null,
        school: null,
        createdAt: DateTime(2024, 1, 1),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createTestWidget(profile));
      await tester.pump();

      expect(find.text('TestUser'), findsOneWidget);
      expect(find.text('Add your gender in settings'), findsOneWidget);
      expect(find.text('Add your school in settings'), findsOneWidget);
    });

    testWidgets('displays optional fields when populated', (tester) async {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: 'TestUser',
        nicknameVerified: false,
        gender: 'male',
        school: 'Test School',
        createdAt: DateTime(2024, 1, 1),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createTestWidget(profile));
      await tester.pump();

      expect(find.text('Male'), findsOneWidget);
      expect(find.text('Test School'), findsOneWidget);
    });

    testWidgets('displays privacy settings correctly', (tester) async {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: 'TestUser',
        nicknameVerified: false,
        createdAt: DateTime(2024, 1, 1),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime(2024, 1, 1),
        allowAnonymousPosts: true,
        profileVisible: false,
      );

      await tester.pumpWidget(createTestWidget(profile));
      await tester.pump();

      expect(find.text('Enabled'), findsOneWidget);
      expect(find.text('Hidden'), findsOneWidget);
    });

    testWidgets('sign out button shows confirmation dialog', (tester) async {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: 'TestUser',
        nicknameVerified: false,
        createdAt: DateTime(2024, 1, 1),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createTestWidget(profile));
      await tester.pump();

      final signOutButton = find.widgetWithText(OutlinedButton, 'Sign Out');
      expect(signOutButton, findsOneWidget);

      await tester.tap(signOutButton);
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to sign out?'), findsOneWidget);
    });

    testWidgets('sign out calls auth service when confirmed', (tester) async {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: 'TestUser',
        nicknameVerified: false,
        createdAt: DateTime(2024, 1, 1),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createTestWidget(profile));
      await tester.pump();

      await tester.tap(find.widgetWithText(OutlinedButton, 'Sign Out'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Sign Out').last);
      await tester.pumpAndSettle();

      expect(fakeAuthService.signOutCalled, isTrue);
    });

    testWidgets('handles empty nickname gracefully', (tester) async {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: '',
        nicknameVerified: false,
        createdAt: DateTime(2024, 1, 1),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(createTestWidget(profile));
      await tester.pump();

      expect(find.text('Anonymous'), findsOneWidget);
    });

    testWidgets('displays minor consent information when applicable', (tester) async {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: 'TestUser',
        nicknameVerified: false,
        createdAt: DateTime(2024, 1, 1),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime(2024, 1, 1),
        isMinor: true,
        parentalConsentGiven: true,
        guardianContact: 'parent@example.com',
      );

      await tester.pumpWidget(createTestWidget(profile));
      await tester.pump();

      expect(find.text('Given'), findsWidgets);
      expect(find.text('parent@example.com'), findsOneWidget);
    });
  });
}
