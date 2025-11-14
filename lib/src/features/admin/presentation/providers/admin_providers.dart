import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/admin/data/models/report.dart';
import 'package:teen_talk_app/src/features/admin/data/models/extended_analytics.dart';
import 'package:teen_talk_app/src/features/admin/data/repositories/admin_repository.dart';

final adminRepositoryProvider = Provider((ref) => AdminRepository());

final adminReportsFilterProvider = StateProvider<AdminReportsFilter>((ref) {
  return AdminReportsFilter();
});

final adminReportsProvider =
    FutureProvider.family<List<Report>, AdminReportsFilter>((ref, filter) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getReports(
    status: filter.status,
    contentType: filter.contentType,
    severity: filter.severity,
    startDate: filter.startDate,
    endDate: filter.endDate,
  );
});

final adminAnalyticsProvider = FutureProvider<AdminAnalytics>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getAnalytics();
});

final analyticsFilterProvider = StateProvider<AnalyticsFilter>((ref) {
  final now = DateTime.now();
  final thirtyDaysAgo = now.subtract(const Duration(days: 30));
  return AnalyticsFilter(startDate: thirtyDaysAgo, endDate: now);
});

final extendedAnalyticsProvider = FutureProvider<ExtendedAnalytics>((ref) async {
  final repository = ref.watch(adminRepositoryProvider);
  final filter = ref.watch(analyticsFilterProvider);
  return repository.getExtendedAnalytics(
    startDate: filter.startDate,
    endDate: filter.endDate,
    school: filter.school,
  );
});

final adminReportDetailsProvider =
    FutureProvider.family<Report?, String>((ref, reportId) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getReportById(reportId);
});

final reportedContentProvider =
    FutureProvider.family<Map<String, dynamic>?, ReportedContentRequest>(
        (ref, request) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getReportedContent(
    itemId: request.itemId,
    itemType: request.itemType,
  );
});

final moderationDecisionsProvider =
    FutureProvider.family<List<ModerationDecision>, String?>(
        (ref, reportId) async {
  final repository = ref.watch(adminRepositoryProvider);
  return repository.getModerationDecisions(reportId: reportId);
});

class AdminReportsFilter {

  AdminReportsFilter({
    this.status = 'all',
    this.contentType,
    this.severity,
    this.startDate,
    this.endDate,
  });
  final String status;
  final String? contentType;
  final String? severity;
  final DateTime? startDate;
  final DateTime? endDate;

  AdminReportsFilter copyWith({
    String? status,
    String? contentType,
    String? severity,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return AdminReportsFilter(
      status: status ?? this.status,
      contentType: contentType ?? this.contentType,
      severity: severity ?? this.severity,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}

class ReportedContentRequest {

  ReportedContentRequest({
    required this.itemId,
    required this.itemType,
  });
  final String itemId;
  final String itemType;
}
