import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/stats.dart';
import '../../core/design_tokens.dart';

class MonthlyChart extends StatelessWidget {
  final List<MonthlyStatsDto> stats;

  const MonthlyChart({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return Center(
        child: Text(
          '데이터가 없습니다',
          style: TextStyle(
            fontSize: 14,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            maxY: _getMaxY(),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => DesignTokens.primaryMain.withValues(alpha: 0.8),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  final month = stats[groupIndex].month;
                  return BarTooltipItem(
                    '$month월\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w400,
                      fontSize: 12,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: '${rod.toY.toInt()}권',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black.withValues(alpha: 0.6),
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
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withValues(alpha: 0.6),
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
                return FlLine(
                  color: Colors.black.withValues(alpha: 0.1),
                  strokeWidth: 1,
                );
              },
            ),
            barGroups: _buildBarGroups(),
          ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (stats.isEmpty) return 10;
    final maxCount = stats.map((s) => s.completedCount).reduce((a, b) => a > b ? a : b);
    return (maxCount * 1.2).ceilToDouble();
  }

  double _getGridInterval() {
    final maxY = _getMaxY();
    if (maxY <= 5) return 1;
    if (maxY <= 10) return 2;
    if (maxY <= 20) return 5;
    return 10;
  }

  List<BarChartGroupData> _buildBarGroups() {
    return stats.asMap().entries.map((entry) {
      return BarChartGroupData(
        x: entry.key,
        barRods: [
          BarChartRodData(
            toY: entry.value.completedCount.toDouble(),
            color: DesignTokens.primaryMain,
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
