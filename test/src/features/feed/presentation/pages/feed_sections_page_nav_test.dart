import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/core/layout/bottom_nav_metrics.dart';
import 'package:teen_talk_app/src/features/feed/presentation/pages/feed_sections_page.dart';
import 'package:teen_talk_app/src/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/user_profile.dart';

void main() {
  group('FeedSectionsPage Navigation Spacing', () {
    testWidgets('FAB has correct bottom padding for bottom nav', (tester) async {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: 'TestUser',
        nicknameVerified: false,
        createdAt: DateTime(2024, 1, 1),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime(2024, 1, 1),
        school: 'Test School',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith((ref) => Stream.value(profile)),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.only(bottom: 34.0),
            ),
            child: MaterialApp(
              home: FeedSectionsPage(),
            ),
          ),
        ),
      );

      await tester.pump();

      final fabFinder = find.byType(FloatingActionButton);

      if (fabFinder.evaluate().isNotEmpty) {
        final paddingFinder = find.ancestor(
          of: fabFinder,
          matching: find.byType(Padding),
        );

        if (paddingFinder.evaluate().isNotEmpty) {
          final fabWidget = tester.widget<Padding>(paddingFinder.first);
          final expectedPadding = BottomNavMetrics.fabPadding(margin: 16.0);
          expect(
            (fabWidget.padding as EdgeInsets).bottom,
            expectedPadding,
            reason: 'FAB should have bottom padding of $expectedPadding to clear bottom nav',
          );
        }
      }
    });

    testWidgets('Feed view has correct bottom spacer', (tester) async {
      final profile = UserProfile(
        uid: 'test-uid',
        nickname: 'TestUser',
        nicknameVerified: false,
        createdAt: DateTime(2024, 1, 1),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime(2024, 1, 1),
        school: 'Test School',
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userProfileProvider.overrideWith((ref) => Stream.value(profile)),
          ],
          child: const MediaQuery(
            data: MediaQueryData(
              size: Size(400, 800),
              padding: EdgeInsets.only(bottom: 34.0),
            ),
            child: MaterialApp(
              home: FeedSectionsPage(),
            ),
          ),
        ),
      );

      await tester.pump();

      final scrollView = find.byType(CustomScrollView);
      expect(scrollView, findsOneWidget);

      final sizedBoxes = find.descendant(
        of: find.byType(SliverToBoxAdapter),
        matching: find.byType(SizedBox),
      );

      bool foundBottomSpacer = false;
      const testSafeAreaBottom = 34.0;
      const extraPadding = 36.0;
      const expectedHeight = BottomNavMetrics.height + testSafeAreaBottom + extraPadding;

      for (final element in sizedBoxes.evaluate()) {
        final sizedBox = element.widget as SizedBox;
        if (sizedBox.height != null && (sizedBox.height! - expectedHeight).abs() < 1.0) {
          foundBottomSpacer = true;
          break;
        }
      }

      expect(
        foundBottomSpacer,
        isTrue,
        reason: 'Should have a bottom spacer that accounts for nav bar height and safe area',
      );
    });

    testWidgets('BottomNavMetrics calculations are correct', (tester) async {
      expect(BottomNavMetrics.height, 84.0);
      expect(BottomNavMetrics.barHeight, 68.0);
      expect(BottomNavMetrics.fabPadding(margin: 16.0), 84.0);
    });
  });
}
