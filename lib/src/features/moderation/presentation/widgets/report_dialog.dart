import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/models/content_report.dart';
import '../../data/models/report_reason.dart';
import '../providers/moderation_provider.dart';

class ReportDialog extends ConsumerStatefulWidget {
  final String contentId;
  final ContentType contentType;
  final String contentAuthorId;

  const ReportDialog({
    super.key,
    required this.contentId,
    required this.contentType,
    required this.contentAuthorId,
  });

  @override
  ConsumerState<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends ConsumerState<ReportDialog> {
  ReportReason? _selectedReason;
  final TextEditingController _detailsController = TextEditingController();
  bool _agreedToGuidelines = false;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final reportState = ref.watch(reportNotifierProvider);
    final theme = Theme.of(context);

    if (authState.user == null) {
      return AlertDialog(
        title: const Text('Error'),
        content: const Text('You must be logged in to report content.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    }

    if (reportState.submitted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Report submitted successfully. Thank you for helping keep our community safe.'),
              duration: Duration(seconds: 3),
            ),
          );
          ref.read(reportNotifierProvider.notifier).reset();
        }
      });
    }

    return AlertDialog(
      title: const Text('Report Content'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Help us understand what\'s wrong with this ${widget.contentType.value}.',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Reason for report:',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            ...ReportReason.values.map((reason) {
              return RadioListTile<ReportReason>(
                title: Text(reason.displayName),
                value: reason,
                groupValue: _selectedReason,
                onChanged: reportState.isSubmitting
                    ? null
                    : (value) {
                        setState(() {
                          _selectedReason = value;
                        });
                      },
                dense: true,
                contentPadding: EdgeInsets.zero,
              );
            }),
            const SizedBox(height: 16),
            TextField(
              controller: _detailsController,
              decoration: const InputDecoration(
                labelText: 'Additional details (optional)',
                hintText: 'Provide more context...',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
              maxLength: 500,
              enabled: !reportState.isSubmitting,
            ),
            const SizedBox(height: 16),
            CheckboxListTile(
              title: const Text(
                'I have read and understand the community guidelines',
                style: TextStyle(fontSize: 13),
              ),
              value: _agreedToGuidelines,
              onChanged: reportState.isSubmitting
                  ? null
                  : (value) {
                      setState(() {
                        _agreedToGuidelines = value ?? false;
                      });
                    },
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
              dense: true,
            ),
            TextButton(
              onPressed: () => _showCommunityGuidelines(context),
              child: const Text('View Community Guidelines'),
            ),
            if (reportState.error != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  reportState.error!,
                  style: TextStyle(
                    color: theme.colorScheme.onErrorContainer,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: reportState.isSubmitting
              ? null
              : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: reportState.isSubmitting || 
                     _selectedReason == null || 
                     !_agreedToGuidelines
              ? null
              : () => _submitReport(),
          child: reportState.isSubmitting
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Submit Report'),
        ),
      ],
    );
  }

  void _submitReport() {
    if (_selectedReason == null || !_agreedToGuidelines) return;

    final authState = ref.read(authStateProvider);
    if (authState.user == null) return;

    ref.read(reportNotifierProvider.notifier).submitReport(
          contentId: widget.contentId,
          contentType: widget.contentType,
          reporterId: authState.user!.uid,
          contentAuthorId: widget.contentAuthorId,
          reason: _selectedReason!,
          additionalDetails: _detailsController.text.trim().isEmpty
              ? null
              : _detailsController.text.trim(),
        );
  }

  void _showCommunityGuidelines(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Community Guidelines'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _guidelineItem('Be respectful', 'Treat others with kindness and respect.'),
              _guidelineItem('No bullying or harassment', 'Do not engage in any form of bullying, harassment, or hate speech.'),
              _guidelineItem('Keep it safe', 'Do not share content that promotes violence, self-harm, or illegal activities.'),
              _guidelineItem('Respect privacy', 'Do not share personal information about yourself or others.'),
              _guidelineItem('No spam', 'Do not post repetitive, misleading, or irrelevant content.'),
              _guidelineItem('Age-appropriate content', 'Keep all content appropriate for a teen audience.'),
              const SizedBox(height: 8),
              const Text(
                'Violations of these guidelines may result in content removal or account restrictions.',
                style: TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _guidelineItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(fontSize: 13),
          ),
        ],
      ),
    );
  }
}
