import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:teen_talk_app/src/features/admin/data/models/extended_analytics.dart';
import 'package:teen_talk_app/src/features/admin/data/models/report.dart';
import 'package:teen_talk_app/src/features/admin/presentation/providers/admin_providers.dart';
import 'package:teen_talk_app/src/features/admin/presentation/widgets/enhanced_analytics_widget.dart';

void main() {
  group('EnhancedAnalyticsWidget', () {
    late AdminAnalytics mockBasicAnalytics;
    late ExtendedAnalytics mockExtendedAnalytics;

    setUp(() {
      mockBasicAnalytics = const AdminAnalytics(
        activeReportCount: 10,
        flaggedPostCount: 5,
        flaggedCommentCount: 3,
        userBanCount: 2,
        resolvedReportCount: 20,
        dismissedReportCount: 15,
      );

      mockExtendedAnalytics = ExtendedAnalytics(
        dailyMetrics: [
          DailyMetric(
            date: DateTime(2024, 1, 1),
            postCount: 10,
            commentCount: 20,
            reportCount: 2,
            activeUserCount: 15,
          ),
          DailyMetric(
            date: DateTime(2024, 1, 2),
            postCount: 15,
            commentCount: 25,
            reportCount: 3,
            activeUserCount: 18,
          ),
          DailyMetric(
            date: DateTime(2024, 1, 3),
            postCount: 12,
            commentCount: 22,
            reportCount: 1,
            activeUserCount: 16,
          ),
        ],
        schoolMetrics: const [
          SchoolMetric(
            schoolName: 'Test School A',
            userCount: 100,
            postCount: 50,
            reportCount: 5,
          ),
          SchoolMetric(
            schoolName: 'Test School B',
            userCount: 80,
            postCount: 40,
            reportCount: 3,
          ),
        ],
        reportReasons: const {
          'Spam': 10,
          'Harassment': 5,
          'Inappropriate Content': 3,
        },
        totalUsers: 200,
        activeUsers: 100,
        totalPosts: 500,
        totalComments: 800,
      );
    });

    testWidgets('renders loading state', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: EnhancedAnalyticsWidget(),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders overview cards with data', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockBasicAnalytics),
            ),
            extendedAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockExtendedAnalytics),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EnhancedAnalyticsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('200'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
      expect(find.text('500'), findsOneWidget);
      expect(find.text('800'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('renders daily trends chart', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockBasicAnalytics),
            ),
            extendedAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockExtendedAnalytics),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EnhancedAnalyticsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Daily Activity Trends'), findsOneWidget);
      expect(find.text('Posts'), findsOneWidget);
      expect(find.text('Comments'), findsOneWidget);
      expect(find.text('Reports'), findsOneWidget);
    });

    testWidgets('renders school metrics chart', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockBasicAnalytics),
            ),
            extendedAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockExtendedAnalytics),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EnhancedAnalyticsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Top Schools by User Count'), findsOneWidget);
    });

    testWidgets('renders report reasons chart', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockBasicAnalytics),
            ),
            extendedAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockExtendedAnalytics),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EnhancedAnalyticsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Report Reasons Distribution'), findsOneWidget);
    });

    testWidgets('filter button is displayed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockBasicAnalytics),
            ),
            extendedAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockExtendedAnalytics),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EnhancedAnalyticsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('export button is displayed', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockBasicAnalytics),
            ),
            extendedAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockExtendedAnalytics),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EnhancedAnalyticsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Export CSV'), findsOneWidget);
      expect(find.byIcon(Icons.download), findsOneWidget);
    });

    testWidgets('handles error state', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminAnalyticsProvider.overrideWith(
              (ref) => Future.error('Test error'),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EnhancedAnalyticsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Error: Test error'), findsOneWidget);
    });

    testWidgets('handles empty data gracefully', (tester) async {
      const emptyExtendedAnalytics = ExtendedAnalytics(
        dailyMetrics: [],
        schoolMetrics: [],
        reportReasons: {},
        totalUsers: 0,
        activeUsers: 0,
        totalPosts: 0,
        totalComments: 0,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            adminAnalyticsProvider.overrideWith(
              (ref) => Future.value(mockBasicAnalytics),
            ),
            extendedAnalyticsProvider.overrideWith(
              (ref) => Future.value(emptyExtendedAnalytics),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: EnhancedAnalyticsWidget(),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No daily metrics available'), findsOneWidget);
      expect(find.text('No school metrics available'), findsOneWidget);
      expect(find.text('No report reasons available'), findsOneWidget);
    });
  });
}
