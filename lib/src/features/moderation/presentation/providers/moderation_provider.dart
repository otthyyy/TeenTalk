import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../data/models/content_report.dart';
import '../../data/models/moderation_item.dart';
import '../../data/models/report_reason.dart';
import '../../data/services/moderation_service.dart';

final moderationServiceProvider = Provider<ModerationService>((ref) {
  return ModerationService(logger: Logger());
});

final moderationQueueProvider = StreamProvider<List<ModerationItem>>((ref) {
  final service = ref.watch(moderationServiceProvider);
  return service.getModerationQueue();
});

final contentReportsProvider = StreamProvider.family<List<ContentReport>, String>((ref, contentId) {
  final service = ref.watch(moderationServiceProvider);
  return service.getReportsForContent(contentId);
});

class ReportState {
  final bool isSubmitting;
  final String? error;
  final bool submitted;

  const ReportState({
    this.isSubmitting = false,
    this.error,
    this.submitted = false,
  });

  ReportState copyWith({
    bool? isSubmitting,
    String? error,
    bool? submitted,
  }) {
    return ReportState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      submitted: submitted ?? this.submitted,
    );
  }
}

class ReportNotifier extends StateNotifier<ReportState> {
  final ModerationService _moderationService;
  final Logger _logger;

  ReportNotifier(this._moderationService, this._logger) 
      : super(const ReportState());

  Future<void> submitReport({
    required String contentId,
    required ContentType contentType,
    required String reporterId,
    required String contentAuthorId,
    required ReportReason reason,
    String? additionalDetails,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null, submitted: false);

    try {
      await _moderationService.submitReport(
        contentId: contentId,
        contentType: contentType,
        reporterId: reporterId,
        contentAuthorId: contentAuthorId,
        reason: reason,
        additionalDetails: additionalDetails,
      );

      state = state.copyWith(isSubmitting: false, submitted: true);
      _logger.i('Report submitted successfully');
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
        submitted: false,
      );
      _logger.e('Error submitting report: $e');
    }
  }

  void reset() {
    state = const ReportState();
  }
}

final reportNotifierProvider = StateNotifierProvider<ReportNotifier, ReportState>((ref) {
  final service = ref.watch(moderationServiceProvider);
  return ReportNotifier(service, Logger());
});

final userReportCountProvider = FutureProvider.family<int, String>((ref, userId) async {
  final service = ref.watch(moderationServiceProvider);
  return service.getUserReportCount(userId);
});

final hasUserReportedContentProvider = FutureProvider.family<bool, ({String userId, String contentId})>((ref, params) async {
  final service = ref.watch(moderationServiceProvider);
  return service.hasUserReportedContent(params.userId, params.contentId);
});

final isContentHiddenProvider = FutureProvider.family<bool, String>((ref, contentId) async {
  final service = ref.watch(moderationServiceProvider);
  return service.isContentHidden(contentId);
});
