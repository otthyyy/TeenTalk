import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:teen_talk_app/src/features/admin/data/models/extended_analytics.dart';
import 'package:teen_talk_app/src/features/admin/data/models/report.dart';
import 'package:teen_talk_app/src/features/admin/data/services/analytics_export_service.dart';
import 'package:teen_talk_app/src/features/admin/presentation/providers/admin_providers.dart';
import 'package:intl/intl.dart';

class EnhancedAnalyticsWidget extends ConsumerStatefulWidget {
  const EnhancedAnalyticsWidget({super.key});

  @override
  ConsumerState<EnhancedAnalyticsWidget> createState() =>
      _EnhancedAnalyticsWidgetState();
}

class _EnhancedAnalyticsWidgetState
    extends ConsumerState<EnhancedAnalyticsWidget> {
  final _exportService = AnalyticsExportService();
  DateTimeRange? _selectedDateRange;
  String? _selectedSchool;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDateRange = DateTimeRange(
      start: now.subtract(const Duration(days: 30)),
      end: now,
    );
  }

  @override
  Widget build(BuildContext context) {
    final analyticsAsyncValue = ref.watch(adminAnalyticsProvider);
    final extendedAnalyticsAsyncValue = ref.watch(extendedAnalyticsProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Advanced Analytics',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.filter_list),
                      onPressed: _showFilterDialog,
                      tooltip: 'Filters',
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _exportData(
                        analyticsAsyncValue.value,
                        extendedAnalyticsAsyncValue.value,
                      ),
                      icon: const Icon(Icons.download),
                      label: const Text('Export CSV'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDateRangeDisplay(),
            const SizedBox(height: 24),
            analyticsAsyncValue.when(
              data: (basicAnalytics) {
                return extendedAnalyticsAsyncValue.when(
                  data: (extendedAnalytics) {
                    return Column(
                      children: [
                        _buildOverviewCards(basicAnalytics, extendedAnalytics),
                        const SizedBox(height: 24),
                        _buildDailyTrendsChart(extendedAnalytics),
                        const SizedBox(height: 24),
                        _buildSchoolMetricsChart(extendedAnalytics),
                        const SizedBox(height: 24),
                        _buildReportReasonsChart(extendedAnalytics),
                      ],
                    );
                  },
                  loading: () => const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
                  error: (error, stack) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Column(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text('Error loading extended analytics: $error'),
                        ],
                      ),
                    ),
                  ),
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

  Widget _buildDateRangeDisplay() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.date_range),
            const SizedBox(width: 12),
            Text(
              'Date Range: ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}',
              style: const TextStyle(fontSize: 14),
            ),
            if (_selectedSchool != null) ...[
              const SizedBox(width: 16),
              Chip(
                label: Text('School: $_selectedSchool'),
                onDeleted: () {
                  setState(() {
                    _selectedSchool = null;
                  });
                  _updateFilters();
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(
    AdminAnalytics basicAnalytics,
    ExtendedAnalytics extendedAnalytics,
  ) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildMetricCard(
          'Total Users',
          extendedAnalytics.totalUsers.toString(),
          Icons.people,
          Colors.blue,
        ),
        _buildMetricCard(
          'Active Users',
          extendedAnalytics.activeUsers.toString(),
          Icons.how_to_reg,
          Colors.green,
        ),
        _buildMetricCard(
          'Total Posts',
          extendedAnalytics.totalPosts.toString(),
          Icons.post_add,
          Colors.purple,
        ),
        _buildMetricCard(
          'Total Comments',
          extendedAnalytics.totalComments.toString(),
          Icons.comment,
          Colors.orange,
        ),
        _buildMetricCard(
          'Active Reports',
          basicAnalytics.activeReportCount.toString(),
          Icons.flag,
          Colors.red,
        ),
        _buildMetricCard(
          'Resolved Reports',
          basicAnalytics.resolvedReportCount.toString(),
          Icons.check_circle,
          Colors.teal,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDailyTrendsChart(ExtendedAnalytics analytics) {
    if (analytics.dailyMetrics.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No daily metrics available')),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Daily Activity Trends',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < analytics.dailyMetrics.length) {
                            final date =
                                analytics.dailyMetrics[value.toInt()].date;
                            return Text(
                              DateFormat('MM/dd').format(date),
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: analytics.dailyMetrics
                          .asMap()
                          .entries
                          .map((e) => FlSpot(
                              e.key.toDouble(), e.value.postCount.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.1),
                      ),
                    ),
                    LineChartBarData(
                      spots: analytics.dailyMetrics
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(),
                              e.value.commentCount.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.green,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.green.withOpacity(0.1),
                      ),
                    ),
                    LineChartBarData(
                      spots: analytics.dailyMetrics
                          .asMap()
                          .entries
                          .map((e) => FlSpot(e.key.toDouble(),
                              e.value.reportCount.toDouble()))
                          .toList(),
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Posts', Colors.blue),
                const SizedBox(width: 16),
                _buildLegendItem('Comments', Colors.green),
                const SizedBox(width: 16),
                _buildLegendItem('Reports', Colors.red),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildSchoolMetricsChart(ExtendedAnalytics analytics) {
    if (analytics.schoolMetrics.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No school metrics available')),
        ),
      );
    }

    final topSchools = analytics.schoolMetrics.take(10).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Top Schools by User Count',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: topSchools.isEmpty
                      ? 10
                      : topSchools
                              .map((e) => e.userCount)
                              .reduce((a, b) => a > b ? a : b)
                              .toDouble() *
                          1.2,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final school = topSchools[group.x.toInt()];
                        return BarTooltipItem(
                          '${school.schoolName}\nUsers: ${school.userCount}\nPosts: ${school.postCount}',
                          const TextStyle(color: Colors.white),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString());
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        getTitlesWidget: (value, meta) {
                          if (value.toInt() >= 0 &&
                              value.toInt() < topSchools.length) {
                            final schoolName = topSchools[value.toInt()]
                                .schoolName
                                .split(' ')
                                .first;
                            return Text(
                              schoolName.length > 8
                                  ? '${schoolName.substring(0, 8)}...'
                                  : schoolName,
                              style: const TextStyle(fontSize: 10),
                            );
                          }
                          return const Text('');
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: true),
                  barGroups: topSchools
                      .asMap()
                      .entries
                      .map(
                        (e) => BarChartGroupData(
                          x: e.key,
                          barRods: [
                            BarChartRodData(
                              toY: e.value.userCount.toDouble(),
                              color: Colors.blue,
                              width: 20,
                            ),
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportReasonsChart(ExtendedAnalytics analytics) {
    if (analytics.reportReasons.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: Text('No report reasons available')),
        ),
      );
    }

    final reasons = analytics.reportReasons.entries.toList();
    final total = reasons.fold<int>(0, (sum, e) => sum + e.value);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Report Reasons Distribution',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 200,
                    child: PieChart(
                      PieChartData(
                        sections: reasons
                            .asMap()
                            .entries
                            .map(
                              (e) => PieChartSectionData(
                                value: e.value.value.toDouble(),
                                title:
                                    '${(e.value.value / total * 100).toStringAsFixed(1)}%',
                                color: _getColorForIndex(e.key),
                                radius: 80,
                                titleStyle: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            )
                            .toList(),
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: reasons
                        .asMap()
                        .entries
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Container(
                                  width: 16,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: _getColorForIndex(e.key),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${e.value.key}: ${e.value.value}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForIndex(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.pink,
      Colors.amber,
    ];
    return colors[index % colors.length];
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter Analytics'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.date_range),
              title: const Text('Date Range'),
              subtitle: Text(
                '${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.start)} - ${DateFormat('MMM dd, yyyy').format(_selectedDateRange!.end)}',
              ),
              onTap: () async {
                final dateRange = await showDateRangePicker(
                  context: context,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                  initialDateRange: _selectedDateRange,
                );
                if (dateRange != null) {
                  setState(() {
                    _selectedDateRange = dateRange;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.school),
              title: const Text('School Filter'),
              subtitle: Text(_selectedSchool ?? 'All Schools'),
              onTap: () {
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                final now = DateTime.now();
                _selectedDateRange = DateTimeRange(
                  start: now.subtract(const Duration(days: 30)),
                  end: now,
                );
                _selectedSchool = null;
              });
              _updateFilters();
              Navigator.pop(context);
            },
            child: const Text('Reset'),
          ),
          TextButton(
            onPressed: () {
              _updateFilters();
              Navigator.pop(context);
            },
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }

  void _updateFilters() {
    ref.read(analyticsFilterProvider.notifier).state = AnalyticsFilter(
      startDate: _selectedDateRange?.start,
      endDate: _selectedDateRange?.end,
      school: _selectedSchool,
    );
  }

  Future<void> _exportData(
    AdminAnalytics? basicAnalytics,
    ExtendedAnalytics? extendedAnalytics,
  ) async {
    if (basicAnalytics == null || extendedAnalytics == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data available to export')),
      );
      return;
    }

    try {
      await _exportService.exportAnalyticsToCSV(
        basicAnalytics: basicAnalytics,
        extendedAnalytics: extendedAnalytics,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Analytics exported successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }
}
