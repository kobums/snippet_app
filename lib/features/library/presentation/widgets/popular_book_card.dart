import 'package:flutter/material.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/features/library/data/models/book_search.dart';
import 'package:snippet_app/features/library/data/models/popular_book.dart';
import 'package:snippet_app/features/library/presentation/widgets/add_book_bottom_sheet.dart';
import 'package:snippet_app/widgets/glass_container.dart';

class PopularBookCard extends StatelessWidget {
  final PopularBookDto book;

  const PopularBookCard({super.key, required this.book});

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      level: GlassLevel.subtle,
      margin: const EdgeInsets.symmetric(
        horizontal: DesignTokens.space16,
        vertical: 6,
      ),
      padding: const EdgeInsets.all(DesignTokens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _RankBadge(rank: book.rank),
          const SizedBox(width: 12),
          _BookCover(coverUrl: book.coverUrl),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  book.title,
                  style: AppTypography.labelMedium.copyWith(
                    color: context.colors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: AppTypography.captionSmall.copyWith(
                    color: context.colors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  book.publisher,
                  style: AppTypography.captionSmall.copyWith(
                    color: context.colors.textTertiary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.auto_stories_outlined,
                      size: 12,
                      color: context.colors.iconSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '대출 ${_formatCount(book.loanCount)}회',
                      style: AppTypography.captionSmall.copyWith(
                        color: context.colors.iconSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          _AddButton(book: book),
        ],
      ),
    );
  }

  String _formatCount(int count) {
    if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}k';
    }
    return count.toString();
  }
}

// ============================================================================
// Rank Badge
// ============================================================================
class _RankBadge extends StatelessWidget {
  final int rank;
  const _RankBadge({required this.rank});

  @override
  Widget build(BuildContext context) {
    final color = switch (rank) {
      1 => const Color(0xFFFFD700),
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => DesignTokens.neutral400,
    };

    return SizedBox(
      width: 28,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (rank <= 3)
            Icon(
              Icons.emoji_events_rounded,
              color: color,
              size: DesignTokens.iconXs,
            ),
          Text(
            '$rank위',
            style: AppTypography.captionSmall.copyWith(
              color: rank <= 3 ? color : context.colors.textTertiary,
              fontWeight: rank <= 3 ? FontWeight.w700 : FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Book Cover
// ============================================================================
class _BookCover extends StatelessWidget {
  final String coverUrl;
  const _BookCover({required this.coverUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
      child: coverUrl.isNotEmpty
          ? Image.network(
              coverUrl,
              width: 56,
              height: 80,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 56,
                height: 80,
                color: context.colors.surfaceSecondary,
                child: Icon(
                  Icons.book_outlined,
                  color: context.colors.iconSecondary,
                  size: 24,
                ),
              ),
            )
          : Container(
              width: 56,
              height: 80,
              color: context.colors.surfaceSecondary,
              child: Icon(
                Icons.book_outlined,
                color: context.colors.iconSecondary,
                size: 24,
              ),
            ),
    );
  }
}

// ============================================================================
// Add to Library Button
// ============================================================================
class _AddButton extends StatelessWidget {
  final PopularBookDto book;
  const _AddButton({required this.book});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showAddSheet(context),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: context.colors.primary,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.add, color: context.colors.surface, size: 18),
      ),
    );
  }

  void _showAddSheet(BuildContext context) {
    final bookSearch = BookSearchDto(
      title: book.title,
      author: book.author,
      publisher: book.publisher,
      pubDate: '',
      isbn: book.isbn13,
      coverUrl: book.coverUrl,
      totalPage: null,
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBookBottomSheet(book: bookSearch),
    );
  }
}
