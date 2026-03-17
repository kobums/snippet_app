import 'package:flutter/material.dart';
import '../../models/stats.dart';
import '../../core/design_tokens.dart';
import '../glass_container.dart';

class YearlySummary extends StatelessWidget {
  final List<YearlyStatsDto> stats;

  const YearlySummary({
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

    final totalCompleted = stats.fold<int>(0, (sum, s) => sum + s.completedCount);
    final totalPages = stats.fold<int>(0, (sum, s) => sum + s.totalPages);

    return Column(
      children: [
        // Total summary
        GlassContainer(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '전체 통계',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  letterSpacing: 1.5,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('총 완독', '$totalCompleted권'),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                  _buildStatItem('총 페이지', '$totalPages쪽'),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Yearly breakdown
        ...stats.map((yearStat) => _buildYearCard(yearStat)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: DesignTokens.primaryMain,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildYearCard(YearlyStatsDto yearStat) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${yearStat.year}년',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
              ),
            ),
            Row(
              children: [
                Text(
                  '${yearStat.completedCount}권',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    color: DesignTokens.primaryMain,
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${yearStat.totalPages}쪽',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.black.withValues(alpha: 0.5),
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
