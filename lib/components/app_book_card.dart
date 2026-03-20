import 'package:flutter/material.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/core/design_tokens.dart';

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
  });

  final UserBookDto book;
  final BookCardSize size;
  final VoidCallback? onTap;
  final bool showProgress;
  final bool showTotalPage;
  final EdgeInsetsGeometry? padding;

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
                    const SizedBox(height: 8),
                    Text(
                      '${book.totalPage}쪽',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w300,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
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
              borderRadius: BorderRadius.circular(3),
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
          const SizedBox(width: 8),
          Text(
            '${(book.progress * 100).toInt()}%',
            style: TextStyle(
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
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: book.progress,
            minHeight: 6,
            backgroundColor: Colors.grey.withValues(alpha: 0.2),
            valueColor: const AlwaysStoppedAnimation<Color>(
              DesignTokens.primaryMain,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${book.readPage} / ${book.totalPage} 페이지 (${(book.progress * 100).toInt()}%)',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w300,
            color: Colors.black.withValues(alpha: 0.4),
          ),
        ),
      ],
    );
  }
}
