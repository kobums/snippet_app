import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/book_provider.dart';
import '../../models/user_book.dart';
import '../glass_container.dart';
import '../layout/bottom_nav_layout.dart';
import 'reading_calendar.dart';

class DashboardStatsSection extends ConsumerWidget {
  const DashboardStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookState = ref.watch(bookProvider);
    final bookNotifier = ref.read(bookProvider.notifier);

    final now = DateTime.now();
    final isCurrentMonth = bookState.selectedYear == now.year &&
        bookState.selectedMonth == now.month;

    final completedBooks =
        bookState.books.where((b) => b.status == BookStatus.completed).toList();
    final totalPages = completedBooks.fold<int>(
        0, (sum, b) => sum + b.totalPage);

    return BottomNavLayout(
      hasFloatingActionButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Month Navigator
          _buildMonthNavigator(
            context,
            bookState.selectedYear,
            bookState.selectedMonth,
            isCurrentMonth,
            bookNotifier,
          ),
          const SizedBox(height: 16),

          // Stats Card
          _buildStatsCard(completedBooks.length, totalPages),
          const SizedBox(height: 16),

          // Reading Calendar
          GlassContainer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '독서 캘린더',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    letterSpacing: 1.5,
                    color: Colors.black.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 12),
                ReadingCalendar(
                  completedBooks: completedBooks,
                  year: bookState.selectedYear,
                  month: bookState.selectedMonth,
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Completed Books List
          if (completedBooks.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, bottom: 12),
              child: Text(
                '완독한 책 (${completedBooks.length})',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 1,
                  color: Colors.black.withValues(alpha: 0.6),
                ),
              ),
            ),
            ...completedBooks.map((book) => _buildCompletedBookCard(book)),
          ],
        ],
      ),
    );
  }

  Widget _buildMonthNavigator(
    BuildContext context,
    int year,
    int month,
    bool isCurrentMonth,
    BookNotifier notifier,
  ) {
    return GlassContainer(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              if (month == 1) {
                notifier.setSelectedMonth(year - 1, 12);
              } else {
                notifier.setSelectedMonth(year, month - 1);
              }
            },
          ),
          Text(
            '$year년 $month월',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              color: isCurrentMonth
                  ? Colors.grey.withValues(alpha: 0.3)
                  : null,
            ),
            onPressed: isCurrentMonth
                ? null
                : () {
                    if (month == 12) {
                      notifier.setSelectedMonth(year + 1, 1);
                    } else {
                      notifier.setSelectedMonth(year, month + 1);
                    }
                  },
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(int completedCount, int totalPages) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '이번 달 통계',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              letterSpacing: 1.5,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('완독', '$completedCount권'),
              Container(
                width: 1,
                height: 40,
                color: Colors.black.withValues(alpha: 0.1),
              ),
              _buildStatItem('총 페이지', '$totalPages쪽'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w300,
            color: Color(0xFF7C5CBF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: Colors.black.withValues(alpha: 0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedBookCard(UserBookDto book) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GlassContainer(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book.coverUrl,
                width: 50,
                height: 75,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 50,
                    height: 75,
                    color: Colors.grey.withValues(alpha: 0.3),
                    child: Icon(
                      Icons.book,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),

            // Book info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w300,
                      color: Colors.black.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
