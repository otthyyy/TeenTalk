import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:teen_talk_app/src/features/admin/data/models/report.dart';
import 'package:teen_talk_app/src/features/admin/presentation/providers/admin_providers.dart';
import 'package:teen_talk_app/src/features/auth/presentation/providers/auth_provider.dart';

class ModerationDetailSheet extends ConsumerStatefulWidget {

  const ModerationDetailSheet({
    super.key,
    required this.report,
  });
  final Report report;

  @override
  ConsumerState<ModerationDetailSheet> createState() =>
      _ModerationDetailSheetState();
}

class _ModerationDetailSheetState extends ConsumerState<ModerationDetailSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedAction = 'resolved';
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;
  bool _deleteContent = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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

    final moderationHistoryAsyncValue = ref.watch(
      moderationDecisionsProvider(widget.report.id),
    );

    final isWide = MediaQuery.of(context).size.width > 900;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            children: [
              _buildHeader(context),
              TabBar(
                controller: _tabController,
                tabs: const [
                  Tab(text: 'Details', icon: Icon(Icons.info_outline, size: 18)),
                  Tab(text: 'Content', icon: Icon(Icons.article_outlined, size: 18)),
                  Tab(text: 'History', icon: Icon(Icons.history, size: 18)),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDetailsTab(isWide),
                    _buildContentTab(contentAsyncValue, isWide),
                    _buildHistoryTab(moderationHistoryAsyncValue, isWide),
                  ],
                ),
              ),
              if (widget.report.status == 'pending') _buildActionBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Report Details',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${widget.report.itemType.toUpperCase()} • ${widget.report.status.toUpperCase()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
            tooltip: 'Close',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsTab(bool isWide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: isWide ? _buildWideDetailsLayout() : _buildNarrowDetailsLayout(),
    );
  }

  Widget _buildWideDetailsLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: _buildReportInfo()),
        const SizedBox(width: 16),
        Expanded(child: _buildAuthorInfo()),
      ],
    );
  }

  Widget _buildNarrowDetailsLayout() {
    return Column(
      children: [
        _buildReportInfo(),
        const SizedBox(height: 16),
        _buildAuthorInfo(),
      ],
    );
  }

  Widget _buildReportInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow('Report ID', widget.report.id),
            _buildInfoRow('Type', widget.report.itemType.toUpperCase()),
            _buildInfoRow('Status', widget.report.status, 
              valueStyle: TextStyle(
                color: _getStatusColor(widget.report.status),
                fontWeight: FontWeight.bold,
              ),
            ),
            _buildInfoRow('Reason', widget.report.reason),
            if (widget.report.severity != null)
              _buildInfoRow('Severity', widget.report.severity!.toUpperCase(),
                valueStyle: TextStyle(
                  color: _getSeverityColor(widget.report.severity!),
                  fontWeight: FontWeight.bold,
                ),
              ),
            _buildInfoRow(
              'Reported At',
              widget.report.createdAt.toLocal().toString().split('.')[0],
            ),
            _buildInfoRow(
              'Last Updated',
              widget.report.updatedAt.toLocal().toString().split('.')[0],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Author Information',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Divider(height: 24),
            _buildInfoRow('Author ID', widget.report.authorId),
            _buildInfoRow('Nickname', widget.report.authorNickname),
            const SizedBox(height: 16),
            if (widget.report.status == 'pending') ...[
              const Text(
                'User Actions',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showUserActionsDialog(context),
                  icon: const Icon(Icons.person_off_outlined),
                  label: const Text('Mute/Suspend User'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildContentTab(AsyncValue contentAsyncValue, bool isWide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: contentAsyncValue.when(
        data: (content) {
          if (content == null) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'Content not found or has been deleted',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return _buildContentPreview(content, isWide);
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error loading content: $error',
                  style: const TextStyle(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContentPreview(Map<String, dynamic> content, bool isWide) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  widget.report.itemType == 'post'
                      ? Icons.article
                      : Icons.comment,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${widget.report.itemType.toUpperCase()} Content',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (content['imageUrl'] != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: content['imageUrl'] as String,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(child: CircularProgressIndicator()),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, size: 48),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (content['content'] != null) ...[
              const Text(
                'Text Content:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  content['content'] as String,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (content['authorNickname'] != null) ...[
              _buildInfoRow('Author', content['authorNickname'] as String),
            ],
            if (content['createdAt'] != null) ...[
              _buildInfoRow(
                'Created At',
                content['createdAt'] is String
                    ? content['createdAt']
                    : DateTime.parse(content['createdAt']).toString(),
              ),
            ],
            if (widget.report.itemType == 'post') ...[
              if (content['topicName'] != null)
                _buildInfoRow('Topic', content['topicName'] as String),
              if (content['commentCount'] != null)
                _buildInfoRow('Comments', content['commentCount'].toString()),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryTab(AsyncValue moderationHistoryAsyncValue, bool isWide) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: moderationHistoryAsyncValue.when(
        data: (decisions) {
          if (decisions.isEmpty) {
            return const Card(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 48, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No moderation history yet',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }
          return Column(
            children: decisions.map((decision) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColor(decision.decision),
                    child: Icon(
                      _getDecisionIcon(decision.decision),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    decision.decision.toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Moderator: ${decision.moderatorId}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (decision.notes != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Notes: ${decision.notes}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        decision.createdAt.toLocal().toString().split('.')[0],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          );
        },
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(32),
            child: CircularProgressIndicator(),
          ),
        ),
        error: (error, stack) => Card(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Text('Error loading history: $error'),
          ),
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButtonFormField<String>(
            initialValue: _selectedAction,
            decoration: const InputDecoration(
              labelText: 'Action',
              border: OutlineInputBorder(),
              isDense: true,
            ),
            items: const [
              DropdownMenuItem(
                value: 'resolved',
                child: Text('Resolve & Hide Content'),
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
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            maxLines: 2,
            decoration: InputDecoration(
              hintText: 'Add notes for this decision (optional)...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              isDense: true,
            ),
          ),
          if (_selectedAction == 'resolved') ...[
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _deleteContent,
              onChanged: (value) {
                setState(() => _deleteContent = value ?? true);
              },
              title: const Text('Delete/Hide Content'),
              dense: true,
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleModeration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedAction == 'resolved'
                        ? Colors.green
                        : Colors.grey,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Apply Decision'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'resolved':
        return Colors.green;
      case 'dismissed':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.amber;
      default:
        return Colors.grey;
    }
  }

  IconData _getDecisionIcon(String decision) {
    switch (decision.toLowerCase()) {
      case 'resolved':
        return Icons.check_circle;
      case 'dismissed':
        return Icons.cancel;
      case 'restored':
        return Icons.restore;
      default:
        return Icons.info;
    }
  }

  void _showUserActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('User Moderation Actions'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('User: ${widget.report.authorNickname}'),
            const SizedBox(height: 16),
            const Text(
              'Select an action:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.volume_off),
              title: const Text('Mute for 24 hours'),
              subtitle: const Text('User cannot post or comment'),
              onTap: () {
                Navigator.pop(context);
                _handleUserAction('mute_24h');
              },
            ),
            ListTile(
              leading: const Icon(Icons.block),
              title: const Text('Suspend for 7 days'),
              subtitle: const Text('User account suspended'),
              onTap: () {
                Navigator.pop(context);
                _handleUserAction('suspend_7d');
              },
            ),
            ListTile(
              leading: const Icon(Icons.warning, color: Colors.red),
              title: const Text('Issue Warning'),
              subtitle: const Text('Send warning to user'),
              onTap: () {
                Navigator.pop(context);
                _handleUserAction('warning');
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleUserAction(String action) async {
    try {
      final repository = ref.read(adminRepositoryProvider);
      final currentUser = ref.read(authStateProvider).user;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      await repository.moderateUser(
        userId: widget.report.authorId,
        action: action,
        moderatorId: currentUser.uid,
        reason: widget.report.reason,
        reportId: widget.report.id,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User action $action applied successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error applying user action: $e')),
        );
      }
    }
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

      if (_selectedAction == 'resolved' && _deleteContent) {
        await repository.deleteContent(
          itemId: widget.report.itemId,
          itemType: widget.report.itemType,
        );
      }

      await repository.updateReportStatus(
        reportId: widget.report.id,
        status: _selectedAction,
        moderatorId: currentUser.uid,
        notes: _notesController.text.isNotEmpty ? _notesController.text : null,
      );

      if (mounted) {
        ref.invalidate(adminReportsProvider);
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
