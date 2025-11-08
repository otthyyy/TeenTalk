import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/content_report.dart';
import '../../data/services/moderation_service.dart';
import '../providers/moderation_provider.dart';
import 'report_dialog.dart';

class ReportButton extends ConsumerWidget {
  final String contentId;
  final ContentType contentType;
  final String contentAuthorId;
  final bool isIconButton;

  const ReportButton({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.contentAuthorId,
    this.isIconButton = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final moderationService = ref.watch(moderationServiceProvider);

    if (authState.user == null) {
      return const SizedBox.shrink();
    }

    final hasReportedAsync = ref.watch(
      hasUserReportedContentProvider((
        userId: authState.user!.uid,
        contentId: contentId,
      )),
    );

    return hasReportedAsync.when(
      data: (hasReported) {
        if (hasReported) {
          return isIconButton
              ? IconButton(
                  icon: const Icon(Icons.flag),
                  onPressed: null,
                  tooltip: 'Already reported',
                  color: Colors.orange,
                )
              : TextButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.flag, size: 16),
                  label: const Text('Reported'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.orange,
                  ),
                );
        }

        return isIconButton
            ? IconButton(
                icon: const Icon(Icons.flag_outlined),
                onPressed: () => _handleReport(context, ref, moderationService, authState.user!.uid),
                tooltip: 'Report content',
              )
            : TextButton.icon(
                onPressed: () => _handleReport(context, ref, moderationService, authState.user!.uid),
                icon: const Icon(Icons.flag_outlined, size: 16),
                label: const Text('Report'),
              );
      },
      loading: () => isIconButton
          ? const SizedBox(
              width: 48,
              height: 48,
              child: Center(
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          : const SizedBox.shrink(),
      error: (_, __) => isIconButton
          ? IconButton(
              icon: const Icon(Icons.flag_outlined),
              onPressed: () => _handleReport(context, ref, moderationService, authState.user!.uid),
              tooltip: 'Report content',
            )
          : TextButton.icon(
              onPressed: () => _handleReport(context, ref, moderationService, authState.user!.uid),
              icon: const Icon(Icons.flag_outlined, size: 16),
              label: const Text('Report'),
            ),
    );
  }

  Future<void> _handleReport(
    BuildContext context,
    WidgetRef ref,
    ModerationService moderationService,
    String userId,
  ) async {
    final reportCount = await moderationService.getUserReportCount(userId);
    final maxReports = moderationService.maxReportsPerUserPerDay;

    if (!context.mounted) return;

    if (reportCount >= maxReports) {
      _showRateLimitDialog(context, maxReports);
      return;
    }

    if (reportCount >= maxReports - 2) {
      _showWarningDialog(context, reportCount, maxReports);
      return;
    }

    showDialog(
      context: context,
      builder: (context) => ReportDialog(
        contentId: contentId,
        contentType: contentType,
        contentAuthorId: contentAuthorId,
      ),
    );
  }

  void _showRateLimitDialog(BuildContext context, int maxReports) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Limit Reached'),
        content: Text(
          'You have reached the maximum number of reports ($maxReports) allowed per day. '
          'Please try again tomorrow.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWarningDialog(BuildContext context, int currentCount, int maxReports) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Report Warning'),
        content: Text(
          'You have submitted $currentCount reports today. '
          'You can submit ${maxReports - currentCount} more report(s) before reaching the daily limit.\n\n'
          'Please ensure you are reporting genuine violations of our community guidelines.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              showDialog(
                context: context,
                builder: (context) => ReportDialog(
                  contentId: contentId,
                  contentType: contentType,
                  contentAuthorId: contentAuthorId,
                ),
              );
            },
            child: const Text('Continue'),
          ),
        ],
      ),
    );
  }
}
