import 'package:flutter/material.dart';
import 'package:snippet_app/features/dashboard/data/models/stats.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/components/section_header.dart';
import 'package:snippet_app/widgets/glass_container.dart';

class YearlySummary extends StatelessWidget {
  final List<YearlyStatsDto> stats;

  const YearlySummary({
    super.key,
    required this.stats,
  });

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

    final totalCompleted = stats.fold<int>(0, (sum, s) => sum + s.completedCount);
    final totalPages = stats.fold<int>(0, (sum, s) => sum + s.totalPages);

    return Column(
      children: [
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader('전체 통계'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('총 완독', '$totalCompleted권', appColors),
                  Container(
                    width: 1,
                    height: 40,
                    color: appColors.border,
                  ),
                  _buildStatItem('총 페이지', '$totalPages쪽', appColors),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        ...stats.map((yearStat) => _buildYearCard(yearStat, appColors)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, AppColors appColors) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h2.copyWith(
            fontWeight: FontWeight.w300,
            color: appColors.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            fontWeight: FontWeight.w400,
            color: appColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildYearCard(YearlyStatsDto yearStat, AppColors appColors) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${yearStat.year}년',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              children: [
                Text(
                  '${yearStat.completedCount}권',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w300,
                    color: appColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${yearStat.totalPages}쪽',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w300,
                    color: appColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
