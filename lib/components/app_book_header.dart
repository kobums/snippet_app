import 'package:flutter/material.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

/// 책 표지 + 제목 + 저자 + 배지를 표시하는 공용 헤더
///
/// [coverUrl] null이면 표지 영역 미표시, 빈 문자열이면 placeholder 표시
class AppBookHeader extends StatelessWidget {
  final String title;
  final String? author;
  final String? coverUrl;
  final String? badgeText;

  const AppBookHeader({
    super.key,
    required this.title,
    this.author,
    this.coverUrl,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (coverUrl != null) ...[
          _buildCover(appColors),
          const SizedBox(width: DesignTokens.space16),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.h4.copyWith(color: appColors.textPrimary),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (author != null && author!.isNotEmpty) ...[
                const SizedBox(height: DesignTokens.space4),
                Text(
                  author!,
                  style: AppTypography.labelSmall.copyWith(
                    color: appColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if (badgeText != null) ...[
                const SizedBox(height: DesignTokens.space8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: DesignTokens.space8,
                    vertical: DesignTokens.space4,
                  ),
                  decoration: BoxDecoration(
                    color: appColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                  ),
                  child: Text(
                    badgeText!,
                    style: AppTypography.labelSmall.copyWith(
                      color: appColors.primary,
                      fontWeight: DesignTokens.fontMedium,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCover(AppColors appColors) {
    if (coverUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
        child: Image.network(
          coverUrl!,
          width: 72,
          height: 100,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _placeholder(appColors),
        ),
      );
    }
    return _placeholder(appColors);
  }

  Widget _placeholder(AppColors appColors) {
    return Container(
      width: 72,
      height: 100,
      decoration: BoxDecoration(
        color: appColors.surfaceSecondary,
        borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      ),
      child: Icon(
        Icons.menu_book_outlined,
        color: appColors.textTertiary,
        size: 28,
      ),
    );
  }
}
