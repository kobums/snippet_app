import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/reading_session/data/models/reading_session.dart';
import 'package:snippet_app/widgets/glass_container.dart';

class ReadingSessionCard extends StatelessWidget {
  final ReadingSessionDto session;

  const ReadingSessionCard({super.key, required this.session});

  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (_) {
      return dateStr;
    }
  }

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '$h시간 $m분';
    if (m > 0) return '$m분';
    return '$seconds초';
  }

  String _formatPace(double secondsPerPage) {
    if (secondsPerPage <= 0) return '-';
    return '${(secondsPerPage / 60).toStringAsFixed(1)} min/p';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.space12),
      child: GestureDetector(
        onTap: () => context.push(AppRoutes.sessionDetail, extra: session),
        child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(session.sessionDate),
                  style: AppTypography.labelMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                Text(
                  _formatDuration(session.durationSeconds),
                  style: AppTypography.labelMedium.copyWith(
                    color: context.colors.primary,
                    fontWeight: DesignTokens.fontMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space12),
            Row(
              children: [
                Icon(
                  Icons.menu_book_outlined,
                  size: 16,
                  color: context.colors.textTertiary,
                ),
                const SizedBox(width: DesignTokens.space8),
                Text(
                  '${session.startPage} → ${session.endPage} 페이지',
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  '+${session.pagesRead}p',
                  style: AppTypography.bodyMedium.copyWith(
                    color: DesignTokens.success,
                    fontWeight: DesignTokens.fontMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space8),
            Row(
              children: [
                Icon(
                  Icons.speed_outlined,
                  size: 16,
                  color: context.colors.textTertiary,
                ),
                const SizedBox(width: DesignTokens.space8),
                Text(
                  '페이스: ${_formatPace(session.secondsPerPage)}',
                  style: AppTypography.bodySmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
