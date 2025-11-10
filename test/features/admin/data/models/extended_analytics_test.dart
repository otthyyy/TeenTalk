import 'package:flutter_test/flutter_test.dart';
import 'package:teen_talk_app/src/features/admin/data/models/extended_analytics.dart';

void main() {
  group('ExtendedAnalytics', () {
    test('fromJson parses valid JSON correctly', () {
      final json = {
        'dailyMetrics': [
          {
            'date': '2024-01-01T00:00:00.000Z',
            'postCount': 10,
            'commentCount': 20,
            'reportCount': 2,
            'activeUserCount': 15,
          }
        ],
        'schoolMetrics': [
          {
            'schoolName': 'Test School',
            'userCount': 100,
            'postCount': 50,
            'reportCount': 5,
          }
        ],
        'reportReasons': {
          'Spam': 10,
          'Harassment': 5,
        },
        'totalUsers': 100,
        'activeUsers': 50,
        'totalPosts': 200,
        'totalComments': 300,
      };

      final analytics = ExtendedAnalytics.fromJson(json);

      expect(analytics.dailyMetrics.length, 1);
      expect(analytics.dailyMetrics[0].postCount, 10);
      expect(analytics.dailyMetrics[0].commentCount, 20);
      expect(analytics.schoolMetrics.length, 1);
      expect(analytics.schoolMetrics[0].schoolName, 'Test School');
      expect(analytics.reportReasons['Spam'], 10);
      expect(analytics.totalUsers, 100);
      expect(analytics.activeUsers, 50);
      expect(analytics.totalPosts, 200);
      expect(analytics.totalComments, 300);
    });

    test('fromJson handles missing fields with defaults', () {
      final json = <String, dynamic>{};

      final analytics = ExtendedAnalytics.fromJson(json);

      expect(analytics.dailyMetrics, isEmpty);
      expect(analytics.schoolMetrics, isEmpty);
      expect(analytics.reportReasons, isEmpty);
      expect(analytics.totalUsers, 0);
      expect(analytics.activeUsers, 0);
      expect(analytics.totalPosts, 0);
      expect(analytics.totalComments, 0);
    });

    test('toJson serializes correctly', () {
      final analytics = ExtendedAnalytics(
        dailyMetrics: [
          DailyMetric(
            date: DateTime(2024, 1, 1),
            postCount: 10,
            commentCount: 20,
            reportCount: 2,
            activeUserCount: 15,
          ),
        ],
        schoolMetrics: [
          const SchoolMetric(
            schoolName: 'Test School',
            userCount: 100,
            postCount: 50,
            reportCount: 5,
          ),
        ],
        reportReasons: const {'Spam': 10},
        totalUsers: 100,
        activeUsers: 50,
        totalPosts: 200,
        totalComments: 300,
      );

      final json = analytics.toJson();

      expect(json['totalUsers'], 100);
      expect(json['activeUsers'], 50);
      expect(json['totalPosts'], 200);
      expect(json['totalComments'], 300);
      expect(json['reportReasons'], {'Spam': 10});
    });
  });

  group('DailyMetric', () {
    test('fromJson parses correctly', () {
      final json = {
        'date': '2024-01-01T00:00:00.000Z',
        'postCount': 10,
        'commentCount': 20,
        'reportCount': 2,
        'activeUserCount': 15,
      };

      final metric = DailyMetric.fromJson(json);

      expect(metric.date.year, 2024);
      expect(metric.date.month, 1);
      expect(metric.date.day, 1);
      expect(metric.postCount, 10);
      expect(metric.commentCount, 20);
      expect(metric.reportCount, 2);
      expect(metric.activeUserCount, 15);
    });

    test('toJson serializes correctly', () {
      final metric = DailyMetric(
        date: DateTime(2024, 1, 1),
        postCount: 10,
        commentCount: 20,
        reportCount: 2,
        activeUserCount: 15,
      );

      final json = metric.toJson();

      expect(json['postCount'], 10);
      expect(json['commentCount'], 20);
      expect(json['reportCount'], 2);
      expect(json['activeUserCount'], 15);
    });
  });

  group('SchoolMetric', () {
    test('fromJson parses correctly', () {
      final json = {
        'schoolName': 'Test School',
        'userCount': 100,
        'postCount': 50,
        'reportCount': 5,
      };

      final metric = SchoolMetric.fromJson(json);

      expect(metric.schoolName, 'Test School');
      expect(metric.userCount, 100);
      expect(metric.postCount, 50);
      expect(metric.reportCount, 5);
    });

    test('toJson serializes correctly', () {
      const metric = SchoolMetric(
        schoolName: 'Test School',
        userCount: 100,
        postCount: 50,
        reportCount: 5,
      );

      final json = metric.toJson();

      expect(json['schoolName'], 'Test School');
      expect(json['userCount'], 100);
      expect(json['postCount'], 50);
      expect(json['reportCount'], 5);
    });
  });

  group('AnalyticsFilter', () {
    test('copyWith updates only specified fields', () {
      final filter = AnalyticsFilter(
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 1, 31),
        school: 'Test School',
      );

      final updated = filter.copyWith(school: 'New School');

      expect(updated.startDate, filter.startDate);
      expect(updated.endDate, filter.endDate);
      expect(updated.school, 'New School');
    });

    test('toJson includes only non-null fields', () {
      const filter = AnalyticsFilter(school: 'Test School');

      final json = filter.toJson();

      expect(json.containsKey('school'), true);
      expect(json.containsKey('startDate'), false);
      expect(json.containsKey('endDate'), false);
    });
  });
}
