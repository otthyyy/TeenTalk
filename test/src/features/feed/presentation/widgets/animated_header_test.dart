import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/feed/domain/models/feed_sort_option.dart';
import 'package:teen_talk_app/src/features/feed/presentation/widgets/animated_header.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/trust_level.dart';
import 'package:teen_talk_app/src/features/profile/domain/models/user_profile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AnimatedHeader', () {
    testWidgets('renders basic header without user profile', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedHeader(
              userProfile: null,
              sortOption: FeedSortOption.newest,
            ),
          ),
        ),
      );

      expect(find.text('👀 Spotted'), findsOneWidget);
      expect(find.text('Share what you\'ve spotted around campus'), findsOneWidget);
      expect(find.text('Latest'), findsOneWidget);
    });

    testWidgets('renders school badge when user profile has school', (tester) async {
      final mockProfile = UserProfile(
        uid: 'test-user',
        nickname: 'TestUser',
        nicknameVerified: true,
        school: 'Test University',
        createdAt: DateTime.now(),
        privacyConsentGiven: true,
        privacyConsentTimestamp: DateTime.now(),
        trustLevel: TrustLevel.member,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedHeader(
              userProfile: mockProfile,
              sortOption: FeedSortOption.newest,
            ),
          ),
        ),
      );

      expect(find.text('👀 Spotted'), findsOneWidget);
      expect(find.text('Test University'), findsOneWidget);
      expect(find.byIcon(Icons.school), findsOneWidget);
    });

    testWidgets('displays correct badge for newest sort option', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedHeader(
              userProfile: null,
              sortOption: FeedSortOption.newest,
            ),
          ),
        ),
      );

      expect(find.text('Latest'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('displays correct badge for most liked sort option', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedHeader(
              userProfile: null,
              sortOption: FeedSortOption.mostLiked,
            ),
          ),
        ),
      );

      expect(find.text('Most Liked'), findsOneWidget);
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    });

    testWidgets('displays correct badge for trending sort option', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedHeader(
              userProfile: null,
              sortOption: FeedSortOption.trending,
            ),
          ),
        ),
      );

      expect(find.text('Trending Now'), findsOneWidget);
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('animation controller is properly initialized and disposed', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedHeader(
              userProfile: null,
              sortOption: FeedSortOption.newest,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(AnimatedHeader), findsOneWidget);

      await tester.pumpWidget(const MaterialApp(home: Scaffold()));

      expect(find.byType(AnimatedHeader), findsNothing);
    });
  });
}
