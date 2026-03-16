import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user_book.dart';
import '../../core/design_tokens.dart';

/// Instagram 피드 공유를 위한 4:5 비율 독서 캘린더 위젯
///
/// 상호작용 없이 스크린샷 캡처에 최적화된 위젯입니다.
class ShareableReadingCalendar extends StatelessWidget {
  final List<UserBookDto> completedBooks;
  final int year;
  final int month;

  const ShareableReadingCalendar({
    super.key,
    required this.completedBooks,
    required this.year,
    required this.month,
  });

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
    final today = DateTime.now();
    final isCurrentMonth = year == today.year && month == today.month;

    // 캘린더 그리드 계산
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstDayOfMonth = DateTime(year, month, 1);
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = Sunday

    final days = List.generate(daysInMonth, (index) => index + 1);
    final emptyCells = List.generate(firstWeekday, (_) => 0);
    final allCells = [...emptyCells, ...days];

    // 완독 권수 계산
    final completedCount = completedBooks.length;

    return RepaintBoundary(
      child: Container(
        width: 1080,
        height: 1350,
        decoration: const BoxDecoration(
          color: DesignTokens.bgPrimary,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DesignTokens.bgPrimary, DesignTokens.bgSecondary],
          ),
        ),
        padding: const EdgeInsets.all(24), // 세로 공간 활용
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 브랜딩 헤더
            _buildHeader(),
            const SizedBox(height: 20), // 간격 줄임

            // 년월 타이틀
            Center(
              child: Text(
                '$year년 $month월',
                style: const TextStyle(
                  fontSize: 14, // 폰트 크기 줄임
                  fontWeight: FontWeight.w600,
                  color: DesignTokens.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
            ),
            const SizedBox(height: 16), // 간격 줄임

            // 캘린더 그리드
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(DesignTokens.radiusLg),
                  boxShadow: DesignTokens.shadowMd,
                ),
                padding: const EdgeInsets.all(10), // 패딩 최소화
                child: Column(
                  children: [
                    // 요일 헤더
                    _buildWeekdayHeaders(),
                    const SizedBox(height: 8), // 간격 줄임

                    // 캘린더 그리드 (6줄 고정)
                    Expanded(
                      child: Column(
                        children: List.generate(6, (weekIndex) {
                          return Expanded(
                            child: Row(
                              children: List.generate(7, (dayIndex) {
                                final cellIndex = weekIndex * 7 + dayIndex;
                                final day = cellIndex < allCells.length
                                    ? allCells[cellIndex]
                                    : 0;

                                if (day == 0) {
                                  // 빈 셀
                                  return Expanded(child: const SizedBox());
                                }

                                final booksOnDay = _getBooksCompletedOnDate(day);
                                final hasBooks = booksOnDay.isNotEmpty;
                                final isToday =
                                    isCurrentMonth && today.day == day;

                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(1.5), // 3px 간격 / 2
                                    child: _buildDayCell(
                                      day: day,
                                      books: booksOnDay,
                                      hasBooks: hasBooks,
                                      isToday: isToday,
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

            const SizedBox(height: 16), // 간격 줄임

            // 통계 푸터
            _buildFooter(completedCount),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Snippet',
          style: TextStyle(
            fontSize: 30, // 크기 줄임
            fontWeight: FontWeight.w300,
            letterSpacing: 2.5,
            color: DesignTokens.primaryMain,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), // 패딩 줄임
          decoration: BoxDecoration(
            color: DesignTokens.primaryMain.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            '독서 캘린더',
            style: TextStyle(
              fontSize: 12, // 크기 줄임
              fontWeight: FontWeight.w500,
              color: DesignTokens.primaryMain,
              letterSpacing: 0.5,
            ),
          ),
        ),
      ],
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
                fontSize: 13, // 크기 줄임
                fontWeight: FontWeight.w600,
                color: isWeekend
                    ? (index == 0 ? Colors.red : Colors.blue)
                    : DesignTokens.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDayCell({
    required int day,
    required List<UserBookDto> books,
    required bool hasBooks,
    required bool isToday,
  }) {
    if (!hasBooks) {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(6), // 반경 줄임
          border: Border.all(
            color: isToday
                ? DesignTokens.primaryMain.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.1),
            width: isToday ? 1.5 : 0.5, // 테두리 얇게
          ),
        ),
        child: Center(
          child: Text(
            '$day',
            style: TextStyle(
              fontSize: 13, // 크기 줄임
              fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
              color: isToday
                  ? DesignTokens.primaryMain
                  : DesignTokens.textTertiary,
            ),
          ),
        ),
      );
    }

    // 책이 있는 날
    final lastBook = books.last;
    final coverUrl = lastBook.coverUrl;

    return ClipRRect(
      borderRadius: BorderRadius.circular(6), // 반경 줄임
      child: Stack(
        fit: StackFit.expand,
        children: [
          // 책 표지 배경
          if (coverUrl.isNotEmpty)
            CachedNetworkImage(
              imageUrl: coverUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.blue.withValues(alpha: 0.2),
                child: const Center(
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.blue.withValues(alpha: 0.2),
                child: const Icon(Icons.book, color: Colors.blue, size: 24),
              ),
            )
          else
            Container(
              color: Colors.blue.withValues(alpha: 0.2),
              child: const Center(
                child: Icon(Icons.book, color: Colors.blue, size: 24),
              ),
            ),

          // 그라데이션 오버레이
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),

          // 날짜 배지 (상단 왼쪽)
          Positioned(
            top: 3,
            left: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
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

          // 권수 표시 (하단)
          if (books.length > 1)
            Positioned(
              bottom: 3,
              right: 3,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: DesignTokens.primaryMain.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: Text(
                  '${books.length}권',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter(int completedCount) {
    return Container(
      padding: const EdgeInsets.all(14), // 패딩 줄임
      decoration: BoxDecoration(
        color: DesignTokens.primaryMain.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(
          color: DesignTokens.primaryMain.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.auto_stories,
            color: DesignTokens.primaryMain,
            size: 22, // 크기 줄임
          ),
          const SizedBox(width: 10),
          Text(
            completedCount > 0
                ? '이번 달 $completedCount권 완독 🎉'
                : '이번 달 완독한 책이 없습니다',
            style: const TextStyle(
              fontSize: 16, // 크기 줄임
              fontWeight: FontWeight.w600,
              color: DesignTokens.primaryMain,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}
