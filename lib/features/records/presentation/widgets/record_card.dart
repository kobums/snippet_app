import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/presentation/providers/record_provider.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';

class RecordCard extends ConsumerWidget {
  final RecordDto record;

  const RecordCard({super.key, required this.record});

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: DesignTokens.space12),
      child: Dismissible(
        key: Key('record_${record.id}'),
        direction: DismissDirection.endToStart,
        confirmDismiss: (direction) async {
          return await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('기록 삭제', style: AppTypography.h3.copyWith(color: context.colors.textPrimary)),
              content: Text(
                '이 기록을 삭제하시겠습니까?',
                style: AppTypography.bodyMedium.copyWith(color: context.colors.textPrimary),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text('취소', style: AppTypography.labelMedium.copyWith(color: context.colors.textPrimary)),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: TextButton.styleFrom(
                    foregroundColor: DesignTokens.error,
                  ),
                  child: Text(
                    '삭제',
                    style: AppTypography.labelMedium.copyWith(
                      color: DesignTokens.error,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
        onDismissed: (direction) async {
          try {
            await ref.read(recordProvider.notifier).deleteRecord(record.id);

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('기록이 삭제되었습니다'),
                  backgroundColor: DesignTokens.success,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.1,
                    left: 16,
                    right: 16,
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(e.toString().replaceAll('Exception: ', '')),
                  backgroundColor: DesignTokens.error,
                  behavior: SnackBarBehavior.floating,
                  margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).size.height * 0.1,
                    left: 16,
                    right: 16,
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          }
        },
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: DesignTokens.space20),
          decoration: BoxDecoration(
            color: DesignTokens.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
            border: Border.all(
              color: DesignTokens.error.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: const Icon(
            Icons.delete_outline,
            color: DesignTokens.error,
            size: DesignTokens.iconLg,
          ),
        ),
        child: GestureDetector(
          onTap: () {
            context.push(AppRoutes.editRecord, extra: record);
          },
          child: GlassContainer(
            showBorder: false,
            padding: const EdgeInsets.all(DesignTokens.space16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (record.tag != null && record.tag!.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: DesignTokens.space12,
                          vertical: DesignTokens.space4,
                        ),
                        decoration: BoxDecoration(
                          color: context.colors.primary.withValues(
                            alpha: 0.1,
                          ),
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusSm,
                          ),
                        ),
                        child: Text(
                          '#${record.tag}',
                          style: AppTypography.caption.copyWith(
                            color: context.colors.primary,
                            fontWeight: DesignTokens.fontMedium,
                          ),
                        ),
                      )
                    else
                      const SizedBox.shrink(),
                    Row(
                      children: [
                        if (record.relatedPage != null) ...[
                          Text(
                            'p.${record.relatedPage}',
                            style: AppTypography.caption.copyWith(
                              color: context.colors.textTertiary,
                            ),
                          ),
                          const SizedBox(width: DesignTokens.space8),
                        ],
                        Text(
                          _formatDate(record.createDate),
                          style: AppTypography.caption.copyWith(
                            color: context.colors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: DesignTokens.space12),
                Text(
                  record.text,
                  style: AppTypography.bodyMedium.copyWith(
                    height: DesignTokens.lineHeightRelaxed,
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
