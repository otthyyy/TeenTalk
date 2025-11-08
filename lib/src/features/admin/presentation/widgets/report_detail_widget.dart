import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/admin/data/models/report.dart';
import 'package:teen_talk_app/src/features/admin/presentation/providers/admin_providers.dart';
import 'package:teen_talk_app/src/features/auth/presentation/providers/auth_provider.dart';

class ReportDetailWidget extends ConsumerStatefulWidget {
  final Report report;

  const ReportDetailWidget({
    super.key,
    required this.report,
  });

  @override
  ConsumerState<ReportDetailWidget> createState() =>
      _ReportDetailWidgetState();
}

class _ReportDetailWidgetState extends ConsumerState<ReportDetailWidget> {
  String _selectedAction = 'resolved';
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final contentAsyncValue = ref.watch(reportedContentProvider(
      ReportedContentRequest(
        itemId: widget.report.itemId,
        itemType: widget.report.itemType,
      ),
    ));

    return DraggableScrollableSheet(
      expand: false,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Report Details',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),
                _buildInfoSection('Report Information', [
                  ('Type', widget.report.itemType.toUpperCase()),
                  ('Status', widget.report.status),
                  ('Reason', widget.report.reason),
                  ('Reported', widget.report.createdAt.toLocal().toString()),
                  ('Author', widget.report.authorNickname),
                ]),
                const SizedBox(height: 24),
                const Text(
                  'Reported Content',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                contentAsyncValue.when(
                  data: (content) {
                    if (content == null) {
                      return const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('Content not found'),
                        ),
                      );
                    }
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              content['content'] ?? '',
                              style: const TextStyle(fontSize: 14),
                            ),
                            const SizedBox(height: 8),
                            if (content['authorNickname'] != null)
                              Text(
                                'By: ${content['authorNickname']}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                  loading: () => const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Error loading content: $error'),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Moderation Action',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (widget.report.status == 'pending')
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButton<String>(
                        value: _selectedAction,
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'resolved',
                            child: Text('Resolve (Delete Content)'),
                          ),
                          DropdownMenuItem(
                            value: 'restored',
                            child: Text('Restore Content'),
                          ),
                          DropdownMenuItem(
                            value: 'dismissed',
                            child: Text('Dismiss Report'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _selectedAction = value);
                          }
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _notesController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: 'Add notes for this decision...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _handleModeration,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Apply Decision'),
                        ),
                      ),
                    ],
                  )
                else
                  Card(
                    color: Colors.grey[100],
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status: ${widget.report.status.toUpperCase()}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'This report has already been processed.',
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoSection(String title, List<(String, String)> items) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.$1,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.$2,
                      textAlign: TextAlign.end,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }

  Future<void> _handleModeration() async {
    if (_selectedAction.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an action')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repository = ref.read(adminRepositoryProvider);
      final currentUser = ref.read(authStateProvider).user;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      if (_selectedAction == 'resolved') {
        await repository.deleteContent(
          itemId: widget.report.itemId,
          itemType: widget.report.itemType,
        );
      } else if (_selectedAction == 'restored') {
        await repository.restoreContent(
          itemId: widget.report.itemId,
          itemType: widget.report.itemType,
        );
      }

      await repository.updateReportStatus(
        reportId: widget.report.id,
        status: _selectedAction,
        moderatorId: currentUser.uid,
        notes: _notesController.text.isNotEmpty
            ? _notesController.text
            : null,
      );

      if (mounted) {
        ref.refresh(adminReportsProvider(AdminReportsFilter()));
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report $_selectedAction successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
