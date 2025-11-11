import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/feed/presentation/providers/liker_profiles_provider.dart';
import 'package:teen_talk_app/src/features/feed/presentation/widgets/liker_list_modal.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/trust_level.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/user_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LikerListModal', () {
    testWidgets('renders liker profiles', (tester) async {
      final mockProfiles = [
        UserProfile(
          uid: 'user1',
          nickname: 'Alice',
          nicknameVerified: true,
          school: 'Test School',
          createdAt: DateTime.now(),
          privacyConsentGiven: true,
          privacyConsentTimestamp: DateTime.now(),
          trustLevel: TrustLevel.member,
        ),
        UserProfile(
          uid: 'user2',
          nickname: 'Bob',
          nicknameVerified: true,
          school: 'Another School',
          createdAt: DateTime.now(),
          privacyConsentGiven: true,
          privacyConsentTimestamp: DateTime.now(),
          trustLevel: TrustLevel.trusted,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            likerProfilesProvider.overrideWithProvider(
              (likerIds) => FutureProvider((ref) async => mockProfiles),
            ),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: () {
                        LikerListModal.show(
                          context: context,
                          likerIds: const ['user1', 'user2'],
                        );
                      },
                      child: const Text('Open Likes'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Likes'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Test School'), findsOneWidget);
      expect(find.text('Another School'), findsOneWidget);
      expect(find.text('Liked by'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
    });
  });
}
