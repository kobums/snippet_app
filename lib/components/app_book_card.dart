import 'package:flutter/material.dart';
import 'package:snippet_app/components/app_button.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

enum BookCardSize {
  small(imageWidth: 45, imageHeight: 68, titleSize: 14, authorSize: 12, borderRadius: 6),
  medium(imageWidth: 50, imageHeight: 75, titleSize: 14, authorSize: 12, borderRadius: 8),
  large(imageWidth: 60, imageHeight: 90, titleSize: 16, authorSize: 14, borderRadius: 8);

  const BookCardSize({
    required this.imageWidth,
    required this.imageHeight,
    required this.titleSize,
    required this.authorSize,
    required this.borderRadius,
  });

  final double imageWidth;
  final double imageHeight;
  final double titleSize;
  final double authorSize;
  final double borderRadius;
}

class AppBookCard extends StatelessWidget {
  const AppBookCard({
    super.key,
    required this.book,
    this.size = BookCardSize.large,
    this.onTap,
    this.showProgress = false,
    this.showTotalPage = false,
    this.padding,
    this.onStatusChange,
  });

  final UserBookDto book;
  final BookCardSize size;
  final VoidCallback? onTap;
  final bool showProgress;
  final bool showTotalPage;
  final EdgeInsetsGeometry? padding;
  final Function(BookStatus)? onStatusChange;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: padding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(size.borderRadius),
              child: Image.network(
                book.coverUrl,
                width: size.imageWidth,
                height: size.imageHeight,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: size.imageWidth,
                    height: size.imageHeight,
                    color: Colors.grey.withValues(alpha: 0.3),
                    child: Icon(
                      Icons.book,
                      size: size == BookCardSize.small ? 20 : null,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: TextStyle(
                      fontSize: size.titleSize,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: size.authorSize,
                      fontWeight: FontWeight.w300,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showProgress && book.status == BookStatus.reading) ...[
                    const SizedBox(height: 12),
                    _buildProgressIndicator(),
                  ],
                  if (showTotalPage) ...[
                    const SizedBox(height: DesignTokens.space8),
                    Text(
                      '${book.totalPage}쪽',
                      style: AppTypography.labelSmall.copyWith(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                    ),
                  ],
                  if (onStatusChange != null &&
                      book.status == BookStatus.waiting) ...[
                    const SizedBox(height: DesignTokens.space12),
                    AppButton(
                      text: '읽기 시작',
                      variant: AppButtonVariant.primary,
                      size: AppButtonSize.small,
                      isFullWidth: true,
                      onPressed: () => onStatusChange!(BookStatus.reading),
                    ),
                  ],
                  if (onStatusChange != null &&
                      book.status == BookStatus.reading) ...[
                    const SizedBox(height: DesignTokens.space12),
                    Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            text: '완독',
                            variant: AppButtonVariant.primary,
                            size: AppButtonSize.small,
                            isFullWidth: true,
                            onPressed: () =>
                                onStatusChange!(BookStatus.completed),
                          ),
                        ),
                        const SizedBox(width: DesignTokens.space8),
                        Expanded(
                          child: AppButton(
                            text: '중단',
                            variant: AppButtonVariant.outlinedDanger,
                            size: AppButtonSize.small,
                            isFullWidth: true,
                            onPressed: () =>
                                onStatusChange!(BookStatus.dropped),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    if (size == BookCardSize.small) {
      return Row(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(DesignTokens.radiusXxs),
              child: LinearProgressIndicator(
                value: book.progress,
                minHeight: 4,
                backgroundColor: Colors.grey.withValues(alpha: 0.2),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  DesignTokens.primaryMain,
                ),
              ),
            ),
          ),
          const SizedBox(width: DesignTokens.space8),
          Text(
            '${(book.progress * 100).toInt()}%',
            style: AppTypography.labelSmall.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w300,
              color: Colors.black.withValues(alpha: 0.4),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
          child: LinearProgressIndicator(
            value: book.progress,
            minHeight: 6,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(
              DesignTokens.primaryMain,
            ),
          ),
        ),
        const SizedBox(height: DesignTokens.space4),
        Text(
          '${book.readPage} / ${book.totalPage} 페이지 (${(book.progress * 100).toInt()}%)',
          style: AppTypography.labelSmall.copyWith(
            fontWeight: FontWeight.w300,
            color: Colors.black.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
