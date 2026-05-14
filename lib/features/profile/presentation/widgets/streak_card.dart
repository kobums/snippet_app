import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/reading_session/reading_session_providers.dart';
import 'package:snippet_app/widgets/glass_container.dart';

class StreakCard extends ConsumerWidget {
  const StreakCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final streakAsync = ref.watch(streakProvider);

    return streakAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (streak) => GlassContainer(
        padding: const EdgeInsets.all(DesignTokens.space20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('🔥', style: AppTypography.h3),
                const SizedBox(width: DesignTokens.space8),
                Text(
                  '독서 스트릭',
                  style: AppTypography.labelLarge.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: DesignTokens.space16),
            Row(
              children: [
                Expanded(
                  child: _StatItem(
                    label: '현재 스트릭',
                    value: '${streak.currentStreak}일',
                    highlight: streak.currentStreak > 0,
                    context: context,
                  ),
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: context.colors.divider,
                ),
                Expanded(
                  child: _StatItem(
                    label: '최장 스트릭',
                    value: '${streak.maxStreak}일',
                    highlight: false,
                    context: context,
                  ),
                ),
              ],
            ),
            if (streak.lastReadDate != null) ...[
              const SizedBox(height: DesignTokens.space12),
              Text(
                '마지막 독서: ${streak.lastReadDate!.substring(0, 10).replaceAll('-', '.')}',
                style: AppTypography.caption.copyWith(
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final bool highlight;
  final BuildContext context;

  const _StatItem({
    required this.label,
    required this.value,
    required this.highlight,
    required this.context,
  });

  @override
  Widget build(BuildContext buildContext) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.h2.copyWith(
            color: highlight
                ? DesignTokens.warning
                : context.colors.textPrimary,
            fontWeight: DesignTokens.fontBold,
          ),
        ),
        const SizedBox(height: DesignTokens.space4),
        Text(
          label,
          style: AppTypography.captionSmall.copyWith(
            color: context.colors.textSecondary,
          ),
        ),
      ],
    );
  }
}
