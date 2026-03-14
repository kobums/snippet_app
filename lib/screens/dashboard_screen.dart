import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/book_provider.dart';
import '../models/user_book.dart';
import '../widgets/glass_container.dart';
import '../widgets/book/book_detail_bottom_sheet.dart';
import 'book_search_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookState = ref.watch(bookProvider);
    final bookNotifier = ref.read(bookProvider.notifier);

    final now = DateTime.now();
    final isCurrentMonth = bookState.selectedYear == now.year &&
                          bookState.selectedMonth == now.month;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '대시보드',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFFF0F0F5),
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () => bookNotifier.refreshBooks(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
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
              _buildStatsCard(bookState.books),
              const SizedBox(height: 16),

              // Reading Progress List
              _buildReadingProgress(context, bookState.books, bookState.isLoading),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BookSearchScreen()),
          );
        },
        backgroundColor: const Color(0xFF7C5CBF),
        child: const Icon(Icons.add, color: Colors.white),
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

  Widget _buildStatsCard(List books) {
    final completedBooks = books.where((b) => b.status == BookStatus.completed).length;
    final totalPages = books
        .where((b) => b.status == BookStatus.completed)
        .fold<int>(0, (sum, b) => sum + (b.totalPage as int));

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
              _buildStatItem('완독', '$completedBooks권'),
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

  Widget _buildReadingProgress(BuildContext context, List books, bool isLoading) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (books.isEmpty) {
      return GlassContainer(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Icon(
                Icons.book_outlined,
                size: 64,
                color: Colors.black.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                '아직 책이 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '첫 책을 추가해보세요!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12),
          child: Text(
            '읽고 있는 책 (${books.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),
        ...books.map((book) => _buildBookCard(context, book)),
      ],
    );
  }

  Widget _buildBookCard(BuildContext context, dynamic book) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            backgroundColor: Colors.transparent,
            builder: (context) => BookDetailBottomSheet(book: book),
          );
        },
        child: GlassContainer(
          child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book cover
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              book.coverUrl,
              width: 60,
              height: 90,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 60,
                  height: 90,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  book.author,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w300,
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                // Progress bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: book.progress,
                        minHeight: 6,
                        backgroundColor: Colors.grey.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF7C5CBF),
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
                ),
              ],
            ),
          ),
        ],
      ),
      ),
      ),
    );
  }
}
