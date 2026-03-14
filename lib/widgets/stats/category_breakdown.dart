import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/stats.dart';
import '../glass_container.dart';

class CategoryBreakdown extends StatelessWidget {
  final List<CategoryStatsDto> stats;

  const CategoryBreakdown({
    super.key,
    required this.stats,
  });

  @override
  Widget build(BuildContext context) {
    if (stats.isEmpty) {
      return GlassContainer(
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: TextStyle(
              fontSize: 14,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        // Pie chart
        GlassContainer(
          child: AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: _buildPieSections(),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Category list
        ...stats.map((categoryStat) => _buildCategoryCard(categoryStat)),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections() {
    final colors = [
      const Color(0xFF7C5CBF),
      const Color(0xFFFF6B9D),
      const Color(0xFF4ECDC4),
      const Color(0xFFFFA07A),
      const Color(0xFF98D8C8),
      const Color(0xFFB5838D),
    ];

    return stats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;
      final color = colors[index % colors.length];

      return PieChartSectionData(
        value: stat.completedCount.toDouble(),
        title: '${stat.completedCount}',
        color: color,
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCategoryCard(CategoryStatsDto categoryStat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  categoryStat.category,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${categoryStat.completedCount} / ${categoryStat.totalCount}권',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Color(0xFF7C5CBF),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: categoryStat.completionRate / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF7C5CBF),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '완독률: ${categoryStat.completionRate.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w300,
                color: Colors.black.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
