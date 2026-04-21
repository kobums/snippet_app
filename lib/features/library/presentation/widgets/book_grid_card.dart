import 'package:flutter/material.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';

/// Fintech Style Book Grid Card
/// 세련된 북 카드 with 디자인 토큰
class BookGridCard extends StatelessWidget {
  final UserBookDto book;
  final VoidCallback onTap;
  final Function(BookStatus)? onStatusChange;

  const BookGridCard({
    super.key,
    required this.book,
    required this.onTap,
    this.onStatusChange,
  });

  Color _getStatusColor(BookStatus status) {
    switch (status) {
      case BookStatus.waiting:
        return DesignTokens.neutral500;
      case BookStatus.reading:
        return DesignTokens.primaryMain;
      case BookStatus.completed:
        return DesignTokens.success;
      case BookStatus.dropped:
        return DesignTokens.warning;
      default:
        return DesignTokens.neutral500;
    }
  }

  String _getStatusText(BookStatus status) {
    switch (status) {
      case BookStatus.waiting:
        return '대기중';
      case BookStatus.reading:
        return '읽는중';
      case BookStatus.completed:
        return '완독';
      case BookStatus.dropped:
        return '중단';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        padding: const EdgeInsets.all(DesignTokens.space8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
                    child: Image.network(
                      book.coverUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          decoration: BoxDecoration(
                            color: DesignTokens.neutral200,
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusSm,
                            ),
                          ),
                          child: const Icon(
                            Icons.book_outlined,
                            size: DesignTokens.icon2xl,
                            color: DesignTokens.neutral400,
                          ),
                        );
                      },
                    ),
                  ),
                  // Status badge
                  if (book.status != BookStatus.none)
                  Positioned(
                    top: DesignTokens.space8,
                    right: DesignTokens.space8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: DesignTokens.space8,
                        vertical: DesignTokens.space4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(book.status),
                        borderRadius: BorderRadius.circular(
                          DesignTokens.radiusSm,
                        ),
                        boxShadow: DesignTokens.shadowSm,
                      ),
                      child: Text(
                        _getStatusText(book.status),
                        style: AppTypography.captionSmall.copyWith(
                          color: Colors.white,
                          fontWeight: DesignTokens.fontMedium,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: DesignTokens.space12),

            // Book title
            Text(
              book.title,
              style: AppTypography.labelMedium.copyWith(
                color: DesignTokens.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: DesignTokens.space4),

            // Author
            Text(
              book.author,
              style: AppTypography.caption.copyWith(
                color: DesignTokens.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Progress bar (if reading)
            if (book.status == BookStatus.reading) ...[
              const SizedBox(height: DesignTokens.space8),
              ClipRRect(
                borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
                child: LinearProgressIndicator(
                  value: book.progress,
                  minHeight: 4,
                  backgroundColor: DesignTokens.neutral200,
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    DesignTokens.primaryMain,
                  ),
                ),
              ),
              const SizedBox(height: DesignTokens.space4),
              Text(
                '${(book.progress * 100).toInt()}%',
                style: AppTypography.captionSmall.copyWith(
                  color: DesignTokens.textTertiary,
                ),
              ),
            ],

            if (onStatusChange != null && book.status == BookStatus.waiting) ...[
              const SizedBox(height: DesignTokens.space8),
              _ActionButton(
                label: '읽기 시작',
                color: DesignTokens.primaryMain,
                onTap: () => onStatusChange!(BookStatus.reading),
              ),
            ],

            if (onStatusChange != null && book.status == BookStatus.reading) ...[
              const SizedBox(height: DesignTokens.space8),
              Row(
                children: [
                  Expanded(
                    child: _ActionButton(
                      label: '완독',
                      color: DesignTokens.success,
                      onTap: () => onStatusChange!(BookStatus.completed),
                    ),
                  ),
                  const SizedBox(width: DesignTokens.space4),
                  Expanded(
                    child: _ActionButton(
                      label: '중단',
                      color: DesignTokens.neutral400,
                      onTap: () => onStatusChange!(BookStatus.dropped),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: DesignTokens.space4),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(DesignTokens.radiusXs),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.captionSmall.copyWith(
              color: color,
              fontWeight: DesignTokens.fontMedium,
            ),
          ),
        ),
      ),
    );
  }
}
