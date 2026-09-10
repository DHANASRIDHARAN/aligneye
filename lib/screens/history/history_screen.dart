import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/models/enums.dart';
import '../../providers/app_provider.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/domain_widgets.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _dayFilter = 7;
  final _filters = [1, 7, 30];
  final _filterLabels = ['Today', '7 Days', '30 Days'];

  @override
  Widget build(BuildContext context) {
    return Consumer<AppProvider>(
      builder: (context, provider, _) {
        final history = provider.getHistoryForRange(_dayFilter);

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            title: const Text('History', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
          body: Column(
            children: [
              // Filter tabs
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: List.generate(_filters.length, (i) {
                    final selected = _dayFilter == _filters[i];
                    return Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _dayFilter = _filters[i]),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppColors.primary
                                : AppColors.surface,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.cardBorder,
                            ),
                          ),
                          child: Text(
                            _filterLabels[i],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected
                                  ? AppColors.background
                                  : AppColors.textSecondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 90),
                  child: Column(
                    children: [
                      // Chart
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SectionHeader(
                                title: 'Alignment Deviation Over Time'),
                            const SizedBox(height: 16),
                            _DeviationChart(history: history),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Stats
                      Row(
                        children: [
                          Expanded(
                            child: MetricCard(
                              label: 'Total Events',
                              value: '${history.length}',
                              icon: Icons.event_note,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              label: 'Warning Events',
                              value: '${history.where((h) => h.overallStatus == AlignmentStatus.warning).length}',
                              icon: Icons.warning_amber,
                              valueColor: AppColors.warning,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: MetricCard(
                              label: 'Critical Events',
                              value: '${history.where((h) => h.overallStatus == AlignmentStatus.critical).length}',
                              icon: Icons.error_outline,
                              valueColor: AppColors.critical,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // History list
                      const SectionHeader(title: 'Event Log'),
                      const SizedBox(height: 12),
                      ...history.take(20).map((entry) => _HistoryEntryCard(entry: entry)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DeviationChart extends StatelessWidget {
  final List<dynamic> history;

  const _DeviationChart({required this.history});

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return const Center(
        child: Text('No data', style: TextStyle(color: AppColors.textMuted)),
      );
    }

    final reversed = history.reversed.toList();
    final spots = reversed.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value.frDeviation ?? 0.0));
    }).toList();

    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          backgroundColor: Colors.transparent,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 0.25,
            getDrawingHorizontalLine: (_) => FlLine(
              color: AppColors.cardBorder,
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 0.5,
                reservedSize: 28,
                getTitlesWidget: (value, meta) => Text(
                  '${value.toStringAsFixed(1)}°',
                  style: const TextStyle(
                      color: AppColors.textMuted, fontSize: 9),
                ),
              ),
            ),
            bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          borderData: FlBorderData(show: false),
          minY: 0,
          maxY: 1.2,
          lineBarsData: [
            // FR deviation line
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.warning,
              barWidth: 2,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.warning.withOpacity(0.08),
              ),
            ),
            // Tolerance line
            LineChartBarData(
              spots: List.generate(
                spots.length,
                (i) => FlSpot(i.toDouble(), 0.5),
              ),
              isCurved: false,
              color: AppColors.critical.withOpacity(0.5),
              barWidth: 1,
              dotData: const FlDotData(show: false),
              dashArray: [4, 4],
            ),
          ],
        ),
      ),
    );
  }
}

class _HistoryEntryCard extends StatelessWidget {
  final dynamic entry;

  const _HistoryEntryCard({required this.entry});

  @override
  Widget build(BuildContext context) {
    final status = entry.overallStatus as AlignmentStatus;
    final color = status == AlignmentStatus.normal
        ? AppColors.normal
        : status == AlignmentStatus.warning
            ? AppColors.warning
            : AppColors.critical;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StatusBadge(status: status, fontSize: 10),
                    Text(
                      DateFormat('dd MMM, HH:mm').format(entry.timestamp),
                      style: const TextStyle(
                          color: AppColors.textMuted, fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    if (entry.affectedWheel != null) ...[
                      Text(
                        'Wheel: ${entry.affectedWheel}',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                      const SizedBox(width: 12),
                    ],
                    if (entry.deviation != null)
                      Text(
                        'Dev: ${entry.deviation!.toStringAsFixed(2)}°',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 11),
                      ),
                    if (entry.vehicleSpeed != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        '${entry.vehicleSpeed!.toStringAsFixed(0)} km/h',
                        style: const TextStyle(
                            color: AppColors.textMuted, fontSize: 11),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
