import 'package:flutter/material.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/core/app_colors.dart';

class ReadingCalendar extends StatefulWidget {
  final List<UserBookDto> completedBooks;
  final int year;
  final int month;

  const ReadingCalendar({
    super.key,
    required this.completedBooks,
    required this.year,
    required this.month,
  });

  @override
  State<ReadingCalendar> createState() => _ReadingCalendarState();
}

class _ReadingCalendarState extends State<ReadingCalendar> {
  List<UserBookDto> _getBooksCompletedOnDate(int day) {
    return widget.completedBooks.where((book) {
      if (book.endDate.isEmpty) return false;
      final endDate = DateTime.tryParse(book.endDate);
      if (endDate == null) return false;
      return endDate.year == widget.year &&
          endDate.month == widget.month &&
          endDate.day == day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final appColors = context.colors;
    final today = DateTime.now();
    final isCurrentMonth =
        widget.year == today.year && widget.month == today.month;

    final daysInMonth = DateTime(widget.year, widget.month + 1, 0).day;
    final firstDayOfMonth = DateTime(widget.year, widget.month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final days = List.generate(daysInMonth, (index) => index + 1);
    final emptyCells = List.generate(firstWeekday, (_) => 0);
    final allCells = [...emptyCells, ...days];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space4,
            vertical: DesignTokens.space8,
          ),
          child: Row(
            children: [
              _buildWeekdayHeader('일', appColors: appColors, isRed: true),
              _buildWeekdayHeader('월', appColors: appColors),
              _buildWeekdayHeader('화', appColors: appColors),
              _buildWeekdayHeader('수', appColors: appColors),
              _buildWeekdayHeader('목', appColors: appColors),
              _buildWeekdayHeader('금', appColors: appColors),
              _buildWeekdayHeader('토', appColors: appColors, isBlue: true),
            ],
          ),
        ),
        const SizedBox(height: DesignTokens.space8),

        GridView.builder(
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 3 / 4,
            crossAxisSpacing: DesignTokens.space4,
            mainAxisSpacing: DesignTokens.space4,
          ),
          itemCount: allCells.length,
          itemBuilder: (context, index) {
            final day = allCells[index];
            if (day == 0) {
              return const SizedBox.shrink();
            }

            final booksOnDay = _getBooksCompletedOnDate(day);
            final hasBooks = booksOnDay.isNotEmpty;
            final isToday = isCurrentMonth && today.day == day;

            return _buildDayCell(
              day: day,
              books: booksOnDay,
              hasBooks: hasBooks,
              isToday: isToday,
              appColors: appColors,
            );
          },
        ),
      ],
    );
  }

  Widget _buildWeekdayHeader(
    String label, {
    required AppColors appColors,
    bool isRed = false,
    bool isBlue = false,
  }) {
    return Expanded(
      child: Center(
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isRed
                ? Colors.red.withValues(alpha: 0.7)
                : isBlue
                ? Colors.blue.withValues(alpha: 0.7)
                : appColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDayCell({
    required int day,
    required List<UserBookDto> books,
    required bool hasBooks,
    required bool isToday,
    required AppColors appColors,
  }) {
    return GestureDetector(
      onTap: hasBooks ? () => _showBooksDialog(context, day, books) : null,
      child: Container(
        decoration: BoxDecoration(
          color: isToday
              ? appColors.primary.withValues(alpha: 0.05)
              : appColors.surfaceSecondary,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          border: Border.all(
            color: isToday
                ? appColors.primary.withValues(alpha: 0.3)
                : appColors.border,
            width: isToday ? 1.5 : 1,
          ),
        ),
        child: hasBooks
            ? _buildBookCoverCell(day, books, isToday)
            : _buildEmptyCell(day, isToday, appColors),
      ),
    );
  }

  Widget _buildBookCoverCell(int day, List<UserBookDto> books, bool isToday) {
    final lastBook = books.last;
    final coverUrl = lastBook.coverUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (coverUrl.isNotEmpty)
            Image.network(
              coverUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: Colors.blue.withValues(alpha: 0.1),
                child: const Center(
                  child: Icon(
                    Icons.book,
                    color: Colors.blue,
                    size: DesignTokens.iconSm,
                  ),
                ),
              ),
            )
          else
            Container(
              color: Colors.blue.withValues(alpha: 0.1),
              child: Center(
                child: Text(
                  '완독',
                  style: AppTypography.captionSmall.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),

          // Dark gradient overlay on book cover — intentional for readability
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(DesignTokens.space4),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.2),
                    Colors.black.withValues(alpha: 0.6),
                  ],
                ),
              ),
              child: Text(
                '${books.length}권',
                style: AppTypography.captionSmall.copyWith(
                  color: Colors.white,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Day badge on book cover — intentional dark overlay
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(DesignTokens.radiusSm),
              ),
              child: Center(
                child: Text(
                  '$day',
                  style: AppTypography.captionSmall.copyWith(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyCell(int day, bool isToday, AppColors appColors) {
    return Center(
      child: Text(
        '$day',
        style: AppTypography.caption.copyWith(
          color: isToday ? appColors.primary : appColors.textTertiary,
          fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
        ),
      ),
    );
  }

  void _showBooksDialog(
    BuildContext context,
    int day,
    List<UserBookDto> books,
  ) {
    final appColors = context.colors;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
        ),
        title: Text(
          '${widget.month}월 $day일 완독',
          style: AppTypography.h4.copyWith(color: appColors.textPrimary),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: books.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: DesignTokens.space12),
            itemBuilder: (context, index) {
              final book = books[index];
              return Container(
                padding: const EdgeInsets.all(DesignTokens.space12),
                decoration: BoxDecoration(
                  color: appColors.primary.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                  border: Border.all(
                    color: appColors.primary.withValues(alpha: 0.1),
                  ),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusSm,
                      ),
                      child: Image.network(
                        book.coverUrl,
                        width: 40,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 40,
                            height: 60,
                            decoration: BoxDecoration(
                              color: appColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(
                                DesignTokens.radiusSm,
                              ),
                            ),
                            child: Icon(
                              Icons.book_outlined,
                              size: 24,
                              color: appColors.primary,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: DesignTokens.space12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            book.title,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w500,
                              color: appColors.textPrimary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: DesignTokens.space4),
                          Text(
                            book.author,
                            style: AppTypography.caption.copyWith(
                              color: appColors.textSecondary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: appColors.primary),
            child: Text(
              '닫기',
              style: AppTypography.labelLarge.copyWith(
                color: appColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
