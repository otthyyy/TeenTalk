import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/admin/presentation/providers/admin_providers.dart';
import 'package:teen_talk_app/src/features/admin/presentation/widgets/report_detail_widget.dart';

class ReportsListWidget extends ConsumerStatefulWidget {
  const ReportsListWidget({super.key});

  @override
  ConsumerState<ReportsListWidget> createState() => _ReportsListWidgetState();
}

class _ReportsListWidgetState extends ConsumerState<ReportsListWidget> {
  String _selectedStatus = 'all';
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  Widget build(BuildContext context) {
    final filter = AdminReportsFilter(
      status: _selectedStatus,
      startDate: _startDate,
      endDate: _endDate,
    );

    final reportsAsyncValue = ref.watch(adminReportsProvider(filter));

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              DropdownButton<String>(
                value: _selectedStatus,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'all', child: Text('All Reports')),
                  DropdownMenuItem(value: 'pending', child: Text('Pending')),
                  DropdownMenuItem(
                      value: 'resolved', child: Text('Resolved')),
                  DropdownMenuItem(
                      value: 'dismissed', child: Text('Dismissed')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedStatus = value);
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
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
                      child: Text(
                        _startDate == null
                            ? 'From'
                            : 'From: ${_startDate!.toLocal().toString().split(' ')[0]}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
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
                      child: Text(
                        _endDate == null
                            ? 'To'
                            : 'To: ${_endDate!.toLocal().toString().split(' ')[0]}',
                      ),
                    ),
                  ),
                ],
              ),
              if (_startDate != null || _endDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _startDate = null;
                        _endDate = null;
                      });
                    },
                    child: const Text('Clear Dates'),
                  ),
                ),
            ],
          ),
        ),
        Expanded(
          child: reportsAsyncValue.when(
            data: (reports) {
              if (reports.isEmpty) {
                return const Center(
                  child: Text('No reports found'),
                );
              }
              return ListView.builder(
                itemCount: reports.length,
                itemBuilder: (context, index) {
                  final report = reports[index];
                  return ReportListItem(report: report);
                },
              );
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
}

class ReportListItem extends StatelessWidget {
  final report;

  const ReportListItem({
    super.key,
    required this.report,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(
          '${report.itemType.toUpperCase()} Report',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text('Reason: ${report.reason}'),
            Text('Author: ${report.authorNickname}'),
            Text(
              'Status: ${report.status}',
              style: TextStyle(
                color: _getStatusColor(report.status),
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Reported: ${report.createdAt.toLocal().toString().split('.')[0]}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => ReportDetailWidget(report: report),
          );
        },
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
}
