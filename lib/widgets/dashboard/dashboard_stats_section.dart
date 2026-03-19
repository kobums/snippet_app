import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/book_provider.dart';
import '../../models/user_book.dart';
import '../glass_container.dart';
import 'reading_calendar.dart';
import '../../core/design_tokens.dart';
import '../../components/month_navigator.dart';
import '../../components/section_header.dart';
import '../../screens/stats_screen.dart';
import '../../screens/reading_calendar_screen.dart';

class DashboardStatsSection extends ConsumerWidget {
  const DashboardStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookState = ref.watch(bookProvider);
    final bookNotifier = ref.read(bookProvider.notifier);

    final now = DateTime.now();
    final isCurrentMonth =
        bookState.selectedYear == now.year &&
        bookState.selectedMonth == now.month;

    final completedBooks = bookState.books
        .where((b) => b.status == BookStatus.completed)
        .toList();
    final totalPages = completedBooks.fold<int>(
      0,
      (sum, b) => sum + b.totalPage,
    );

    return CustomScrollView(
      slivers: [
        // Sticky Month Navigator
        SliverPersistentHeader(
          pinned: true,
          delegate: StickyMonthNavigator(
            year: bookState.selectedYear,
            month: bookState.selectedMonth,
            isCurrentMonth: isCurrentMonth,
            onMonthChanged: (year, month) {
              bookNotifier.setSelectedMonth(year, month);
            },
            height: 64,
          ),
        ),

        // Content
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Stats Card
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const StatsScreen()),
                  );
                },
                child: _buildStatsCard(completedBooks.length, totalPages),
              ),
              const SizedBox(height: 16),

              // Reading Calendar
              GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const ReadingCalendarScreen(),
                    ),
                  );
                },
                child: GlassContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader('독서 캘린더'),
                      const SizedBox(height: 8),
                      ReadingCalendar(
                        completedBooks: completedBooks,
                        year: bookState.selectedYear,
                        month: bookState.selectedMonth,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Completed Books List
              if (completedBooks.isNotEmpty) ...[
                SectionHeader(
                  '완독한 책 (${completedBooks.length})',
                  size: SectionHeaderSize.large,
                  padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                ),
                ...completedBooks.map((book) => _buildCompletedBookCard(book)),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(int completedCount, int totalPages) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('이번 달 통계'),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Center(child: _buildStatItem('완독', '$completedCount권')),
              ),
              Container(
                width: 2,
                height: 40,
                color: Colors.black.withValues(alpha: 0.1),
              ),
              Expanded(
                child: Center(child: _buildStatItem('총 페이지', '$totalPages쪽')),
              ),
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
            color: DesignTokens.primaryMain,
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
