import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/admin/data/models/report.dart';
import 'package:teen_talk_app/src/features/admin/presentation/providers/admin_providers.dart';
import 'package:teen_talk_app/src/features/admin/presentation/widgets/moderation_detail_sheet.dart';
import 'package:teen_talk_app/src/features/auth/presentation/providers/auth_provider.dart';

class ReportsListWidget extends ConsumerStatefulWidget {
  const ReportsListWidget({super.key});

  @override
  ConsumerState<ReportsListWidget> createState() => _ReportsListWidgetState();
}

class _ReportsListWidgetState extends ConsumerState<ReportsListWidget> {
  String _selectedStatus = 'all';
  String _selectedContentType = 'all';
  String _selectedSeverity = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final filter = AdminReportsFilter(
      status: _selectedStatus,
      contentType: _selectedContentType,
      severity: _selectedSeverity,
      startDate: _startDate,
      endDate: _endDate,
    );

    final reportsAsyncValue = ref.watch(adminReportsProvider(filter));
    final isWide = MediaQuery.of(context).size.width > 900;

    return Column(
      children: [
        _buildFilters(isWide),
        Expanded(
          child: reportsAsyncValue.when(
            data: (reports) {
              if (reports.isEmpty) {
                return const Center(
                  child: Text('No reports found'),
                );
              }
              return isWide
                  ? _buildWideLayout(reports)
                  : _buildNarrowLayout(reports);
            },
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => Center(
              child: Text('Error: $error'),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFilters(bool isWide) {
    if (isWide) {
      return Card(
        margin: const EdgeInsets.all(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(child: _buildStatusFilter()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildContentTypeFilter()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSeverityFilter()),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(child: _buildDateFromButton()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildDateToButton()),
                  const SizedBox(width: 16),
                  Expanded(child: _buildClearDatesButton()),
                ],
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildStatusFilter(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildContentTypeFilter()),
              const SizedBox(width: 8),
              Expanded(child: _buildSeverityFilter()),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildDateFromButton()),
              const SizedBox(width: 8),
              Expanded(child: _buildDateToButton()),
            ],
          ),
          if (_startDate != null || _endDate != null) ...[
            const SizedBox(height: 8),
            _buildClearDatesButton(),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedStatus,
      decoration: const InputDecoration(
        labelText: 'Status',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Status')),
        DropdownMenuItem(value: 'pending', child: Text('Pending')),
        DropdownMenuItem(value: 'resolved', child: Text('Resolved')),
        DropdownMenuItem(value: 'dismissed', child: Text('Dismissed')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedStatus = value);
        }
      },
    );
  }

  Widget _buildContentTypeFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedContentType,
      decoration: const InputDecoration(
        labelText: 'Content Type',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Types')),
        DropdownMenuItem(value: 'post', child: Text('Posts')),
        DropdownMenuItem(value: 'comment', child: Text('Comments')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedContentType = value);
        }
      },
    );
  }

  Widget _buildSeverityFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedSeverity,
      decoration: const InputDecoration(
        labelText: 'Severity',
        border: OutlineInputBorder(),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(value: 'all', child: Text('All Severity')),
        DropdownMenuItem(value: 'low', child: Text('Low')),
        DropdownMenuItem(value: 'medium', child: Text('Medium')),
        DropdownMenuItem(value: 'high', child: Text('High')),
        DropdownMenuItem(value: 'critical', child: Text('Critical')),
      ],
      onChanged: (value) {
        if (value != null) {
          setState(() => _selectedSeverity = value);
        }
      },
    );
  }

  Widget _buildDateFromButton() {
    return OutlinedButton.icon(
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _startDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _startDate = date);
        }
      },
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(
        _startDate == null
            ? 'From'
            : 'From: ${_startDate!.toLocal().toString().split(' ')[0]}',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildDateToButton() {
    return OutlinedButton.icon(
      onPressed: () async {
        final date = await showDatePicker(
          context: context,
          initialDate: _endDate ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
        );
        if (date != null) {
          setState(() => _endDate = date);
        }
      },
      icon: const Icon(Icons.calendar_today, size: 16),
      label: Text(
        _endDate == null
            ? 'To'
            : 'To: ${_endDate!.toLocal().toString().split(' ')[0]}',
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Widget _buildClearDatesButton() {
    if (_startDate == null && _endDate == null) {
      return const SizedBox.shrink();
    }
    return OutlinedButton.icon(
      onPressed: () {
        setState(() {
          _startDate = null;
          _endDate = null;
        });
      },
      icon: const Icon(Icons.clear, size: 16),
      label: const Text('Clear Dates'),
    );
  }

  Widget _buildWideLayout(List<Report> reports) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.builder(
        itemCount: reports.length,
        itemBuilder: (context, index) {
          final report = reports[index];
          return ReportListItem(
            report: report,
            isWide: true,
          );
        },
      ),
    );
  }

  Widget _buildNarrowLayout(List<Report> reports) {
    return ListView.builder(
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return ReportListItem(
          report: report,
          isWide: false,
        );
      },
    );
  }
}

class ReportListItem extends ConsumerStatefulWidget {
  final Report report;
  final bool isWide;

  const ReportListItem({
    super.key,
    required this.report,
    this.isWide = false,
  });

  @override
  ConsumerState<ReportListItem> createState() => _ReportListItemState();
}

class _ReportListItemState extends ConsumerState<ReportListItem> {
  bool _isProcessing = false;
  String? _localStatus;

  String get _status => _localStatus ?? widget.report.status;

  @override
  Widget build(BuildContext context) {
    if (widget.isWide) {
      return _buildWideListItem();
    }
    return _buildNarrowListItem();
  }

  Widget _buildWideListItem() {
    return InkWell(
      onTap: _showDetailSheet,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildTypeChip(),
                      const SizedBox(width: 8),
                      if (widget.report.severity != null) _buildSeverityBadge(),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Reason: ${widget.report.reason}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Author: ${widget.report.authorNickname}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatusChip(),
                  const SizedBox(height: 4),
                  Text(
                    widget.report.createdAt.toLocal().toString().split('.')[0],
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            if (_status == 'pending' && !_isProcessing)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildQuickActionButton(
                    'Resolve',
                    Icons.check_circle,
                    Colors.green,
                    () => _handleQuickAction('resolved'),
                  ),
                  const SizedBox(width: 8),
                  _buildQuickActionButton(
                    'Dismiss',
                    Icons.cancel,
                    Colors.grey,
                    () => _handleQuickAction('dismissed'),
                  ),
                ],
              ),
            if (_isProcessing)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            if (!_isProcessing)
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: _showDetailSheet,
                tooltip: 'View details',
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNarrowListItem() {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: _showDetailSheet,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildTypeChip(),
                      const SizedBox(width: 8),
                      if (widget.report.severity != null) _buildSeverityBadge(),
                    ],
                  ),
                  _buildStatusChip(),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'Reason: ${widget.report.reason}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Text(
                'Author: ${widget.report.authorNickname}',
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
              const SizedBox(height: 4),
              Text(
                'Reported: ${widget.report.createdAt.toLocal().toString().split('.')[0]}',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              if (_status == 'pending' && !_isProcessing) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleQuickAction('resolved'),
                        icon: const Icon(Icons.check_circle, size: 18),
                        label: const Text('Resolve'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _handleQuickAction('dismissed'),
                        icon: const Icon(Icons.cancel, size: 18),
                        label: const Text('Dismiss'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (_isProcessing) ...[
                const SizedBox(height: 12),
                const Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: widget.report.itemType == 'post'
            ? Colors.blue.shade100
            : Colors.purple.shade100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        widget.report.itemType.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: widget.report.itemType == 'post'
              ? Colors.blue.shade900
              : Colors.purple.shade900,
        ),
      ),
    );
  }

  Widget _buildSeverityBadge() {
    final severity = widget.report.severity?.toLowerCase() ?? 'low';
    Color color;
    switch (severity) {
      case 'critical':
        color = Colors.red;
        break;
      case 'high':
        color = Colors.orange;
        break;
      case 'medium':
        color = Colors.amber;
        break;
      default:
        color = Colors.grey;
    }

    final backgroundColor = color.withOpacity(0.15);
    final foregroundColor = color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.priority_high, size: 12, color: foregroundColor),
          const SizedBox(width: 2),
          Text(
            severity.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: foregroundColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getStatusColor(_status).withOpacity(0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        _status.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: _getStatusColor(_status),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(
    String label,
    IconData icon,
    Color color,
    VoidCallback onPressed,
  ) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
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

  void _showDetailSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => ModerationDetailSheet(report: widget.report),
    );
  }

  Future<void> _handleQuickAction(String action) async {
    setState(() {
      _isProcessing = true;
      _localStatus = action;
    });

    try {
      final repository = ref.read(adminRepositoryProvider);
      final currentUser = ref.read(authStateProvider).user;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final functionAction = switch (action) {
        'resolved' => 'approve',
        'dismissed' => 'reject',
        _ => 'approve',
      };

      await repository.processModerationAction(
        reportId: widget.report.id,
        action: functionAction,
        reason: 'Quick action from reports list',
      );

      await repository.updateReportStatus(
        reportId: widget.report.id,
        status: action,
        moderatorId: currentUser.uid,
        notes: 'Quick action from reports list',
      );

      if (mounted) {
        ref.invalidate(adminReportsProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Report $action successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _localStatus = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }
}
