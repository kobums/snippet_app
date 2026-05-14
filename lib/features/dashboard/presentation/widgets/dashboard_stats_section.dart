import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/dashboard/presentation/providers/dashboard_stats_provider.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/reading_calendar.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/components/app_book_card.dart';
import 'package:snippet_app/components/month_navigator.dart';
import 'package:snippet_app/components/section_header.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/reading_goal_card.dart';

class DashboardStatsSection extends ConsumerWidget {
  final double headerOpacity;

  const DashboardStatsSection({super.key, this.headerOpacity = 1.0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsState = ref.watch(dashboardStatsProvider);
    final statsNotifier = ref.read(dashboardStatsProvider.notifier);

    final now = DateTime.now();
    final isCurrentMonth =
        statsState.selectedYear == now.year &&
        statsState.selectedMonth == now.month;

    final completedBooks = statsState.books.where((b) {
      if (b.status != BookStatus.completed) return false;
      if (b.endDate.isEmpty) return false;

      try {
        final endDate = DateTime.parse(b.endDate);
        return endDate.year == statsState.selectedYear &&
            endDate.month == statsState.selectedMonth;
      } catch (e) {
        return false;
      }
    }).toList();
    final totalPages = completedBooks.fold<int>(
      0,
      (sum, b) => sum + b.totalPage,
    );

    if (statsState.isLoading && statsState.books.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return AppRefreshIndicator(
      onRefresh: () => statsNotifier.refreshBooks(),
      child: CustomScrollView(
        slivers: [
          // Conditional rendering with placeholder
          if (headerOpacity > 0)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 64,
                child: Center(
                  child: MonthNavigator(
                    year: statsState.selectedYear,
                    month: statsState.selectedMonth,
                    isCurrentMonth: isCurrentMonth,
                    onMonthChanged: statsNotifier.setSelectedMonth,
                  ),
                ),
              ),
            )
          else
            // 빈 공간으로 높이 유지 (부드러운 스크롤)
            const SliverToBoxAdapter(child: SizedBox(height: 64)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const ReadingGoalCard(),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    context.push(AppRoutes.stats);
                  },
                  child: _buildStatsCard(
                    completedBooks.length,
                    totalPages,
                    context.colors,
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    context.push(
                      '${AppRoutes.readingCalendar}?year=${statsState.selectedYear}&month=${statsState.selectedMonth}',
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
                          year: statsState.selectedYear,
                          month: statsState.selectedMonth,
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
                        onTap: () =>
                            context.push(AppRoutes.bookDetail, extra: book),
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

  Widget _buildStatsCard(
    int completedCount,
    int totalPages,
    AppColors appColors,
  ) {
    return GlassContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionHeader('이번 달 통계'),
          const SizedBox(height: 4),
          Row(
            children: [
              Expanded(
                child: Center(
                  child: _buildStatItem('완독', '$completedCount권', appColors),
                ),
              ),
              Container(width: 2, height: 40, color: appColors.border),
              Expanded(
                child: Center(
                  child: _buildStatItem('총 페이지', '$totalPages쪽', appColors),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, AppColors appColors) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.displaySmall.copyWith(
            color: appColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTypography.labelMedium.copyWith(
            color: appColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
