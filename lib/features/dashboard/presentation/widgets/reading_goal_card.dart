import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/dashboard/dashboard_providers.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/components/section_header.dart';

class ReadingGoalCard extends ConsumerWidget {
  const ReadingGoalCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final goalAsync = ref.watch(readingGoalProvider);

    return goalAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (goal) => GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(child: SectionHeader('올해 독서 목표')),
                TextButton(
                  onPressed: () => _showGoalDialog(context, ref, goal.targetBooks),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: DesignTokens.space8,
                      vertical: DesignTokens.space4,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    goal.targetBooks == 0 ? '목표 설정' : '수정',
                    style: AppTypography.captionSmall.copyWith(
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ],
            ),
            if (goal.targetBooks == 0)
              Padding(
                padding: const EdgeInsets.only(top: DesignTokens.space8),
                child: Text(
                  '올해 몇 권을 읽을지 목표를 설정해보세요!',
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              )
            else ...[
              const SizedBox(height: DesignTokens.space12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${goal.completedBooks}',
                    style: AppTypography.displaySmall.copyWith(
                      color: context.colors.primary,
                      fontWeight: DesignTokens.fontBold,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                        bottom: DesignTokens.space4,
                        left: DesignTokens.space4),
                    child: Text(
                      '/ ${goal.targetBooks}권',
                      style: AppTypography.labelMedium.copyWith(
                        color: context.colors.textSecondary,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${(goal.progress * 100).toInt()}%',
                    style: AppTypography.labelLarge.copyWith(
                      color: goal.progress >= 1.0
                          ? DesignTokens.success
                          : context.colors.textSecondary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: DesignTokens.space8),
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(DesignTokens.radiusXs),
                child: LinearProgressIndicator(
                  value: goal.progress,
                  minHeight: 6,
                  backgroundColor: context.colors.border,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    goal.progress >= 1.0
                        ? DesignTokens.success
                        : context.colors.primary,
                  ),
                ),
              ),
              if (goal.progress >= 1.0) ...[
                const SizedBox(height: DesignTokens.space8),
                Text(
                  '🎉 목표 달성! 축하합니다!',
                  style: AppTypography.caption.copyWith(
                    color: DesignTokens.success,
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  void _showGoalDialog(
      BuildContext context, WidgetRef ref, int currentTarget) {
    final controller =
        TextEditingController(text: currentTarget > 0 ? '$currentTarget' : '');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.surface,
        title: Text(
          '독서 목표 설정',
          style: AppTypography.h3.copyWith(color: context.colors.textPrimary),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: InputDecoration(
            hintText: '목표 권수 입력',
            suffixText: '권',
            hintStyle: TextStyle(color: context.colors.textTertiary),
          ),
          style: AppTypography.bodyLarge.copyWith(
            color: context.colors.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('취소',
                style: TextStyle(color: context.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              if (value != null && value > 0) {
                ref.read(readingGoalProvider.notifier).setGoal(value);
              }
              Navigator.pop(ctx);
            },
            child: Text('저장',
                style: TextStyle(color: context.colors.primary)),
          ),
        ],
      ),
    );
  }
}
