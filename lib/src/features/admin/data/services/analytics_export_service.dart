import 'package:csv/csv.dart';

import '../models/extended_analytics.dart';
import '../models/report.dart';
import 'analytics_export_delegate_stub.dart' show AnalyticsExportDelegate;
import 'analytics_export_delegate_stub.dart'
    if (dart.library.io) 'analytics_export_delegate_io.dart'
    if (dart.library.html) 'analytics_export_delegate_web.dart'
    as analytics_export;

class AnalyticsExportService {
  AnalyticsExportService();

  final AnalyticsExportDelegate _delegate =
      analytics_export.buildAnalyticsExportDelegate();

  Future<void> exportAnalyticsToCSV({
    required AdminAnalytics basicAnalytics,
    required ExtendedAnalytics extendedAnalytics,
  }) async {
    final List<List<dynamic>> rows = [];

    rows.add(['Analytics Report']);
    rows.add(['Generated at:', DateTime.now().toIso8601String()]);
    rows.add([]);

    rows.add(['Basic Metrics']);
    rows.add(['Metric', 'Count']);
    rows.add(['Active Reports', basicAnalytics.activeReportCount]);
    rows.add(['Resolved Reports', basicAnalytics.resolvedReportCount]);
    rows.add(['Dismissed Reports', basicAnalytics.dismissedReportCount]);
    rows.add(['Flagged Posts', basicAnalytics.flaggedPostCount]);
    rows.add(['Flagged Comments', basicAnalytics.flaggedCommentCount]);
    rows.add(['Banned Users', basicAnalytics.userBanCount]);
    rows.add([]);

    rows.add(['Extended Metrics']);
    rows.add(['Metric', 'Count']);
    rows.add(['Total Users', extendedAnalytics.totalUsers]);
    rows.add(['Active Users', extendedAnalytics.activeUsers]);
    rows.add(['Total Posts', extendedAnalytics.totalPosts]);
    rows.add(['Total Comments', extendedAnalytics.totalComments]);
    rows.add([]);

    if (extendedAnalytics.dailyMetrics.isNotEmpty) {
      rows.add(['Daily Metrics']);
      rows.add([
        'Date',
        'Posts',
        'Comments',
        'Reports',
        'Active Users',
      ]);
      for (final metric in extendedAnalytics.dailyMetrics) {
        rows.add([
          metric.date.toIso8601String().split('T')[0],
          metric.postCount,
          metric.commentCount,
          metric.reportCount,
          metric.activeUserCount,
        ]);
      }
      rows.add([]);
    }

    if (extendedAnalytics.schoolMetrics.isNotEmpty) {
      rows.add(['School Metrics']);
      rows.add(['School', 'Users', 'Posts', 'Reports']);
      for (final metric in extendedAnalytics.schoolMetrics) {
        rows.add([
          metric.schoolName,
          metric.userCount,
          metric.postCount,
          metric.reportCount,
        ]);
      }
      rows.add([]);
    }

    if (extendedAnalytics.reportReasons.isNotEmpty) {
      rows.add(['Report Reasons']);
      rows.add(['Reason', 'Count']);
      extendedAnalytics.reportReasons.forEach((reason, count) {
        rows.add([reason, count]);
      });
    }

    final csv = const ListToCsvConverter().convert(rows);

    await _delegate.export(
      'analytics_report_${DateTime.now().millisecondsSinceEpoch}.csv',
      csv,
    );
  }
}
