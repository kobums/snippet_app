import 'package:flutter/material.dart';
import 'package:snippet_app/features/dashboard/data/models/stats.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

class InsightsCard extends StatelessWidget {
  final ReadingInsightsDto? insights;

  const InsightsCard({
    super.key,
    required this.insights,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;
    if (insights == null) {
      return GlassContainer(
        padding: const EdgeInsets.all(DesignTokens.space32),
        child: Center(
          child: Text(
            '데이터가 없습니다',
            style: AppTypography.bodyMedium.copyWith(color: appColors.textSecondary),
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildInsightItem(
          icon: Icons.timelapse_outlined,
          title: '평균 독서 기간',
          value: '${insights!.averageReadingDays.toStringAsFixed(1)}일',
          description: '한 권을 읽는데 걸리는 평균 시간',
          appColors: appColors,
        ),
        const SizedBox(height: DesignTokens.space12),
        _buildInsightItem(
          icon: Icons.category_outlined,
          title: '선호 카테고리',
          value: insights!.topCategory,
          description: '가장 많이 읽은 카테고리',
          appColors: appColors,
        ),
        const SizedBox(height: DesignTokens.space12),
        _buildInsightItem(
          icon: Icons.emoji_events_outlined,
          title: '최장 독서 기록',
          value: '${insights!.longestReadingDays}일',
          description: '가장 오래 읽은 책의 독서 기간',
          appColors: appColors,
        ),
        const SizedBox(height: DesignTokens.space12),
        _buildInsightItem(
          icon: Icons.menu_book_outlined,
          title: '가장 오래 읽은 책',
          value: insights!.longestBook,
          description: '가장 오래 걸린 책',
          appColors: appColors,
        ),
      ],
    );
  }

  Widget _buildInsightItem({
    required IconData icon,
    required String title,
    required String value,
    required String description,
    required AppColors appColors,
  }) {
    return GlassContainer(
      padding: const EdgeInsets.all(DesignTokens.space16),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  appColors.primary.withValues(alpha: 0.1),
                  appColors.primary.withValues(alpha: 0.05),
                ],
              ),
              borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            ),
            child: Icon(
              icon,
              color: appColors.primary,
              size: DesignTokens.iconLg,
            ),
          ),
          const SizedBox(width: DesignTokens.space16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.caption.copyWith(color: appColors.textSecondary),
                ),
                const SizedBox(height: DesignTokens.space4),
                Text(
                  value,
                  style: AppTypography.h4.copyWith(color: appColors.primary),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: DesignTokens.space2),
                Text(
                  description,
                  style: AppTypography.captionSmall.copyWith(color: appColors.textTertiary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
