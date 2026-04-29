import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:snippet_app/features/dashboard/data/models/stats.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/widgets/glass_container.dart';

class CategoryBreakdown extends StatelessWidget {
  final List<CategoryStatsDto> stats;

  const CategoryBreakdown({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;

    if (stats.isEmpty) {
      return GlassContainer(
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: AppTypography.bodyMedium.copyWith(
              color: appColors.textSecondary,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        GlassContainer(
          child: AspectRatio(
            aspectRatio: 1.3,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 60,
                sections: _buildPieSections(appColors),
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {},
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),

        ...stats.map(
          (categoryStat) => _buildCategoryCard(categoryStat, appColors),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildPieSections(AppColors appColors) {
    final colors = [
      appColors.primary,
      DesignTokens.chartColor1,
      DesignTokens.chartColor2,
      DesignTokens.chartColor3,
      DesignTokens.chartColor4,
      DesignTokens.chartColor5,
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
        titleStyle: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w400,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildCategoryCard(
    CategoryStatsDto categoryStat,
    AppColors appColors,
  ) {
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
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  '${categoryStat.completedCount} / ${categoryStat.totalCount}권',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w300,
                    color: appColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space12),
            ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              child: LinearProgressIndicator(
                value: categoryStat.completionRate / 100,
                minHeight: 8,
                backgroundColor: appColors.border,
                valueColor: AlwaysStoppedAnimation<Color>(appColors.primary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '완독률: ${categoryStat.completionRate.toStringAsFixed(1)}%',
              style: AppTypography.bodySmall.copyWith(
                fontWeight: FontWeight.w300,
                color: appColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
