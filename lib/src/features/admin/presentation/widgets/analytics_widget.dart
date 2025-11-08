import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/admin/presentation/providers/admin_providers.dart';

class AnalyticsWidget extends ConsumerWidget {
  const AnalyticsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final analyticsAsyncValue = ref.watch(adminAnalyticsProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Moderation Analytics',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            analyticsAsyncValue.when(
              data: (analytics) {
                return Column(
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      children: [
                        _buildAnalyticsCard(
                          title: 'Active Reports',
                          value: analytics.activeReportCount.toString(),
                          icon: Icons.flag,
                          color: Colors.orange,
                        ),
                        _buildAnalyticsCard(
                          title: 'Resolved',
                          value: analytics.resolvedReportCount.toString(),
                          icon: Icons.check_circle,
                          color: Colors.green,
                        ),
                        _buildAnalyticsCard(
                          title: 'Dismissed',
                          value: analytics.dismissedReportCount.toString(),
                          icon: Icons.cancel,
                          color: Colors.grey,
                        ),
                        _buildAnalyticsCard(
                          title: 'Flagged Posts',
                          value: analytics.flaggedPostCount.toString(),
                          icon: Icons.post_add,
                          color: Colors.blue,
                        ),
                        _buildAnalyticsCard(
                          title: 'Flagged Comments',
                          value: analytics.flaggedCommentCount.toString(),
                          icon: Icons.comment,
                          color: Colors.purple,
                        ),
                        _buildAnalyticsCard(
                          title: 'Banned Users',
                          value: analytics.userBanCount.toString(),
                          icon: Icons.block,
                          color: Colors.red,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Summary',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildSummaryRow(
                              'Total Reports',
                              (analytics.activeReportCount +
                                      analytics.resolvedReportCount +
                                      analytics.dismissedReportCount)
                                  .toString(),
                            ),
                            _buildSummaryRow(
                              'Resolution Rate',
                              '${((analytics.resolvedReportCount + analytics.dismissedReportCount) / (analytics.activeReportCount + analytics.resolvedReportCount + analytics.dismissedReportCount) * 100).toStringAsFixed(1)}%',
                            ),
                            _buildSummaryRow(
                              'Total Flagged Content',
                              (analytics.flaggedPostCount +
                                      analytics.flaggedCommentCount)
                                  .toString(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Text('Error: $error'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnalyticsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
