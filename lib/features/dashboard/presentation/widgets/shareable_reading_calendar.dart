import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/core/design_tokens.dart';

/// Instagram 피드 공유를 위한 4:5 비율 독서 캘린더 위젯
///
/// 상호작용 없이 스크린샷 캡처에 최적화된 위젯입니다.
class ShareableReadingCalendar extends StatelessWidget {
  final List<UserBookDto> completedBooks;
  final int year;
  final int month;
  final bool showTitle;
  final bool showStats;
  final bool isDark;

  const ShareableReadingCalendar({
    super.key,
    required this.completedBooks,
    required this.year,
    required this.month,
    this.showTitle = true,
    this.showStats = false,
    this.isDark = false,
  });

  // ─── 테마 색상 ─────────────────────────────────────────────────────────────
  Color get _bgColor =>
      isDark ? const Color(0xFF1C1C1E) : DesignTokens.bgPrimary;
  Color get _cardBg =>
      isDark ? const Color(0xFF2C2C2E) : Colors.white.withValues(alpha: 0.7);
  Color get _textPrimary =>
      isDark ? Colors.white : DesignTokens.textPrimary;
  Color get _textSecondary =>
      isDark ? const Color(0xFFAEAEB2) : DesignTokens.textSecondary;
  Color get _textTertiary =>
      isDark ? const Color(0xFF636366) : DesignTokens.textTertiary;
  Color get _primary =>
      isDark ? Colors.white : DesignTokens.primaryMain;
  Color get _emptyCellBg =>
      isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey.withValues(alpha: 0.05);
  Color get _emptyCellBorder =>
      isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey.withValues(alpha: 0.1);

  // ─── helpers ───────────────────────────────────────────────────────────────
  List<UserBookDto> _getBooksCompletedOnDate(int day) {
    return completedBooks.where((book) {
      if (book.endDate.isEmpty) return false;
      final endDate = DateTime.tryParse(book.endDate);
      if (endDate == null) return false;
      return endDate.year == year &&
          endDate.month == month &&
          endDate.day == day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7;

    final days = List.generate(daysInMonth, (index) => index + 1);
    final emptyCells = List.generate(firstWeekday, (_) => 0);
    final allCells = [...emptyCells, ...days];

    final completedCount = completedBooks.length;

    return RepaintBoundary(
      child: Container(
        width: 1080,
        height: 1350,
        decoration: BoxDecoration(color: _bgColor),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showTitle) ...[
              const SizedBox(height: 20),
              Center(
                child: Text(
                  '$year년 $month월',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w400,
                    color: _textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
              const SizedBox(height: 60),
            ],
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _cardBg,
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  boxShadow: isDark ? null : DesignTokens.shadowMd,
                ),
                padding: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    _buildWeekdayHeaders(),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Column(
                        children: List.generate(6, (weekIndex) {
                          final isLastRow = weekIndex == 5;

                          return Expanded(
                            child: Row(
                              children: List.generate(7, (dayIndex) {
                                if (showStats && isLastRow && dayIndex >= 3) {
                                  if (dayIndex == 3) {
                                    return Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.5),
                                        child: _buildStatCell(
                                          label: '완독한 책',
                                          value: '${completedBooks.length}권',
                                          icon: Icons.auto_stories,
                                        ),
                                      ),
                                    );
                                  } else if (dayIndex == 5) {
                                    final totalPages = completedBooks.fold<int>(
                                      0,
                                      (sum, b) => sum + b.totalPage,
                                    );
                                    return Expanded(
                                      flex: 2,
                                      child: Padding(
                                        padding: const EdgeInsets.all(1.5),
                                        child: _buildStatCell(
                                          label: '총 페이지',
                                          value: '$totalPages쪽',
                                          icon: Icons.menu_book,
                                        ),
                                      ),
                                    );
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }

                                final cellIndex = weekIndex * 7 + dayIndex;
                                final day = cellIndex < allCells.length
                                    ? allCells[cellIndex]
                                    : 0;

                                if (day == 0) {
                                  return const Expanded(child: SizedBox());
                                }

                                final booksOnDay =
                                    _getBooksCompletedOnDate(day);
                                final hasBooks = booksOnDay.isNotEmpty;

                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.5),
                                    child: _buildDayCell(
                                      day: day,
                                      books: booksOnDay,
                                      hasBooks: hasBooks,
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    const weekdays = ['일', '월', '화', '수', '목', '금', '토'];
    return Row(
      children: weekdays.asMap().entries.map((entry) {
        final index = entry.key;
        final day = entry.value;
        final isWeekend = index == 0 || index == 6;

        return Expanded(
          child: Center(
            child: Text(
              day,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isWeekend
                    ? (index == 0
                        ? Colors.red.withValues(alpha: isDark ? 0.9 : 1.0)
                        : Colors.blue.withValues(alpha: isDark ? 0.9 : 1.0))
                    : _textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStackedCovers({
    required List<UserBookDto> books,
    required double offsetXPerLayer,
    required double offsetYPerLayer,
  }) {
    final maxCoversToShow = math.min(books.length, 4);
    final booksToDisplay = books.reversed.take(maxCoversToShow).toList();

    return Stack(
      fit: StackFit.expand,
      children: List.generate(
        booksToDisplay.length,
        (index) => _buildCoverLayer(
          coverUrl: booksToDisplay[index].coverUrl,
          index: index,
          totalLayers: booksToDisplay.length,
          offsetXPerLayer: offsetXPerLayer,
          offsetYPerLayer: offsetYPerLayer,
        ),
      ).reversed.toList(),
    );
  }

  Widget _buildCoverLayer({
    required String coverUrl,
    required int index,
    required int totalLayers,
    required double offsetXPerLayer,
    required double offsetYPerLayer,
  }) {
    final scale = (1.0 - ((totalLayers - 1) * 0.1)).clamp(0.7, 1.0);
    final offsetX = index * offsetXPerLayer;
    final offsetY = index * offsetYPerLayer;

    return Transform(
      transform: Matrix4.identity()
        ..translate(offsetX, offsetY, 0.0)
        ..scale(scale, scale, 1.0),
      alignment: Alignment.topLeft,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6 * scale),
        child: coverUrl.isNotEmpty
            ? CachedNetworkImage(
                imageUrl: coverUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.blue.withValues(
                      alpha: 0.2 * (1 - index * 0.1)),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2 * scale),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.blue.withValues(alpha: 0.2),
                  child: Icon(Icons.book, color: Colors.blue, size: 24 * scale),
                ),
              )
            : Container(
                color: Colors.blue.withValues(alpha: 0.2),
                child: Center(
                  child: Icon(Icons.book, color: Colors.blue, size: 24 * scale),
                ),
              ),
      ),
    );
  }

  Widget _buildDayCell({
    required int day,
    required List<UserBookDto> books,
    required bool hasBooks,
  }) {
    if (!hasBooks) {
      return Container(
        decoration: BoxDecoration(
          color: _emptyCellBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: _emptyCellBorder, width: 0.5),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: _textTertiary,
            ),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cellWidth = constraints.maxWidth;
        final cellHeight = constraints.maxHeight;
        final offsetXPerLayer = cellWidth * 0.10;
        final offsetYPerLayer = cellHeight * 0.10;

        return ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (books.length == 1)
                books.first.coverUrl.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: books.first.coverUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.blue.withValues(alpha: 0.2),
                          child: const Center(
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.blue.withValues(alpha: 0.2),
                          child: const Icon(Icons.book,
                              color: Colors.blue, size: 24),
                        ),
                      )
                    : Container(
                        color: Colors.blue.withValues(alpha: 0.2),
                        child: const Center(
                          child: Icon(Icons.book, color: Colors.blue, size: 24),
                        ),
                      )
              else
                _buildStackedCovers(
                  books: books,
                  offsetXPerLayer: offsetXPerLayer,
                  offsetYPerLayer: offsetYPerLayer,
                ),

              // 날짜 배지
              Positioned(
                top: 3,
                left: 3,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Text(
                    '$day',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // 권수 배지
              if (books.length > 1)
                Positioned(
                  bottom: 3,
                  right: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: _primary.withValues(alpha: 0.95),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${books.length}권',
                      style: TextStyle(
                        color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatCell({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: _primary, size: 40),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: _primary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: _primary.withValues(alpha: 0.7),
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}
