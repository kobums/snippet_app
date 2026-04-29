import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:snippet_app/features/dashboard/data/models/stats.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/core/app_colors.dart';

class MonthlyChart extends StatelessWidget {
  final List<MonthlyStatsDto> stats;

  const MonthlyChart({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;

    if (stats.isEmpty) {
      return Center(
        child: Text(
          '데이터가 없습니다',
          style: AppTypography.bodyMedium.copyWith(
            color: appColors.textSecondary,
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.space16),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxY(),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) =>
                    appColors.primary.withValues(alpha: 0.8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final month = stats[groupIndex].month;
                  return BarTooltipItem(
                    '$month월\n',
                    AppTypography.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${rod.toY.toInt()}권',
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              show: true,
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() >= 0 && value.toInt() < stats.length) {
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '${stats[value.toInt()].month}',
                          style: AppTypography.bodySmall.copyWith(
                            color: appColors.textSecondary,
                          ),
                        ),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toInt().toString(),
                      style: AppTypography.bodySmall.copyWith(
                        color: appColors.textSecondary,
                      ),
                    );
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
            borderData: FlBorderData(show: false),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: _getGridInterval(),
              getDrawingHorizontalLine: (value) {
                return FlLine(color: appColors.border, strokeWidth: 1);
              },
            ),
            barGroups: _buildBarGroups(appColors),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (stats.isEmpty) return 10;
    final maxCount = stats
        .map((s) => s.completedCount)
        .reduce((a, b) => a > b ? a : b);
    return (maxCount * 1.2).ceilToDouble();
  }

  double _getGridInterval() {
    final maxY = _getMaxY();
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    return 10;
  }

  List<BarChartGroupData> _buildBarGroups(AppColors appColors) {
    return stats.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.completedCount.toDouble(),
            color: appColors.primary,
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }
}
