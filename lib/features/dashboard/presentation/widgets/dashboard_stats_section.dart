import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/reading_calendar.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/components/app_book_card.dart';
import 'package:snippet_app/components/month_navigator.dart';
import 'package:snippet_app/components/section_header.dart';

class DashboardStatsSection extends ConsumerWidget {
  final double paddingProgress;

  const DashboardStatsSection({
    super.key,
    this.paddingProgress = 0.0,
  });

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

    final topPadding = MediaQuery.of(context).padding.top;

    return AppRefreshIndicator(
      onRefresh: () => bookNotifier.refreshBooks(),
      child: CustomScrollView(
        slivers: [
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
              topPadding: topPadding,
              paddingProgress: paddingProgress,
            ),
          ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  GestureDetector(
                    onTap: () {
                      context.push(AppRoutes.stats);
                    },
                    child: _buildStatsCard(completedBooks.length, totalPages),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      context.push(AppRoutes.readingCalendar);
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
                  if (completedBooks.isNotEmpty) ...[
                    SectionHeader(
                      '완독한 책 (${completedBooks.length})',
                      size: SectionHeaderSize.large,
                      padding: const EdgeInsets.only(left: 8.0, bottom: 12),
                    ),
                    ...completedBooks.map(
                      (book) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: AppBookCard(
                          book: book,
                          size: BookCardSize.medium,
                          showTotalPage: true,
                        ),
                      ),
                    ),
                  ],
                ]),
              ),
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
}
