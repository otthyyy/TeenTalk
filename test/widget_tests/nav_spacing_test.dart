import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/core/layout/bottom_nav_metrics.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/user_profile.dart';
import 'package:teen_talk_app/src/features/profile/presentation/pages/profile_page.dart';
import 'package:teen_talk_app/src/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:teen_talk_app/src/features/auth/presentation/providers/auth_provider.dart';
import 'package:teen_talk_app/src/features/auth/data/services/firebase_auth_service.dart';

class FakeFirebaseAuthService extends FirebaseAuthService {
  @override
  Future<void> signOut() async {}
}

void main() {
  group('Navigation Spacing Tests', () {
    testWidgets('ProfilePage has correct bottom padding for sign out button', (tester) async {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: 'TestUser',
        nicknameVerified: false,
        createdAt: DateTime(2024, 1, 1),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime(2024, 1, 1),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith((ref) => Stream.value(profile)),
            firebaseAuthServiceProvider.overrideWithValue(FakeFirebaseAuthService()),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.only(bottom: 34.0),
            ),
            child: MaterialApp(
              home: ProfilePage(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final signOutButton = find.widgetWithText(OutlinedButton, 'Sign Out');
      expect(signOutButton, findsOneWidget);

      final signOutButtonWidget = tester.widget<OutlinedButton>(signOutButton);
      final renderBox = tester.renderObject(signOutButton) as RenderBox;
      final buttonBottom = renderBox.localToGlobal(Offset.zero).dy + renderBox.size.height;
      const screenHeight = 800.0;

      final expectedBottomPadding = BottomNavMetrics.scrollBottomPadding(
        tester.element(signOutButton),
        extra: 16,
      );

      final actualBottomSpace = screenHeight - buttonBottom;
      expect(actualBottomSpace, greaterThanOrEqualTo(BottomNavMetrics.height - 20));
    });

    testWidgets('ProfilePage bottom padding accounts for safe area', (tester) async {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: 'TestUser',
        nicknameVerified: false,
        createdAt: DateTime(2024, 1, 1),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime(2024, 1, 1),
      );

      const testSafeAreaBottom = 34.0;

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith((ref) => Stream.value(profile)),
            firebaseAuthServiceProvider.overrideWithValue(FakeFirebaseAuthService()),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.only(bottom: testSafeAreaBottom),
            ),
            child: MaterialApp(
              home: ProfilePage(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final scrollView = find.byType(CustomScrollView);
      expect(scrollView, findsOneWidget);

      final sizedBoxes = find.descendant(
        of: find.byType(SliverToBoxAdapter),
        matching: find.byType(SizedBox),
      );

      bool foundCorrectPadding = false;
      for (final element in sizedBoxes.evaluate()) {
        final sizedBox = element.widget as SizedBox;
        if (sizedBox.height != null) {
          const expectedHeight = BottomNavMetrics.height + testSafeAreaBottom + 16;
          if ((sizedBox.height! - expectedHeight).abs() < 1.0) {
            foundCorrectPadding = true;
            break;
          }
        }
      }

      expect(foundCorrectPadding, isTrue, reason: 'Should have bottom padding that accounts for nav bar and safe area');
    });

    testWidgets('BottomNavMetrics constants are correct', (tester) async {
      expect(BottomNavMetrics.height, 84.0);
      expect(BottomNavMetrics.barHeight, 68.0);

      await tester.pumpWidget(
        const MediaQuery(
          data: MediaQueryData(
            padding: EdgeInsets.only(bottom: 34.0),
          ),
          child: Builder(
            builder: _TestWidget.new,
          ),
        ),
      );

      await tester.pump();
    });

    testWidgets('FAB padding calculation is correct', (tester) async {
      final fabPadding = BottomNavMetrics.fabPadding(margin: 16.0);
      expect(fabPadding, 84.0);

      final fabPaddingWithCustomMargin = BottomNavMetrics.fabPadding(margin: 24.0);
      expect(fabPaddingWithCustomMargin, 92.0);
    });
  });
}

class _TestWidget extends StatelessWidget {
  const _TestWidget(BuildContext context);

  @override
  Widget build(BuildContext context) {
    final height = BottomNavMetrics.safeAreaAwareHeight(context);
    expect(height, 84.0 + 34.0);
    return Container();
  }
}
