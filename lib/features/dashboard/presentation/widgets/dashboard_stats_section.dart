import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/library_providers.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/reading_calendar.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/components/app_book_card.dart';
import 'package:snippet_app/components/month_navigator.dart';
import 'package:snippet_app/components/section_header.dart';

class DashboardStatsSection extends ConsumerStatefulWidget {
  final double headerOpacity;

  const DashboardStatsSection({super.key, this.headerOpacity = 1.0});

  @override
  ConsumerState<DashboardStatsSection> createState() =>
      _DashboardStatsSectionState();
}

class _DashboardStatsSectionState extends ConsumerState<DashboardStatsSection> {
  late int _selectedYear;
  late int _selectedMonth;
  List<UserBookDto> _books = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
    _loadBooks();
  }

  Future<void> _loadBooks() async {
    setState(() => _isLoading = true);

    final useCase = ref.read(fetchMonthlyBooksUseCaseProvider);
    final result = await useCase(_selectedYear, _selectedMonth);

    if (mounted) {
      result.when(
        success: (books) {
          setState(() {
            _books = books;
            _isLoading = false;
          });
        },
        failure: (error) {
          setState(() => _isLoading = false);
        },
      );
    }
  }

  void _setSelectedMonth(int year, int month) {
    setState(() {
      _selectedYear = year;
      _selectedMonth = month;
    });
    _loadBooks();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final isCurrentMonth = _selectedYear == now.year && _selectedMonth == now.month;

    final completedBooks = _books
        .where((b) => b.status == BookStatus.completed)
        .toList();
    final totalPages = completedBooks.fold<int>(
      0,
      (sum, b) => sum + b.totalPage,
    );

    return AppRefreshIndicator(
      onRefresh: _loadBooks,
      child: CustomScrollView(
        slivers: [
          // Conditional rendering with placeholder
          if (widget.headerOpacity > 0)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 64,
                child: Center(
                  child: MonthNavigator(
                    year: _selectedYear,
                    month: _selectedMonth,
                    isCurrentMonth: isCurrentMonth,
                    onMonthChanged: _setSelectedMonth,
                  ),
                ),
              ),
            )
          else
            // 빈 공간으로 높이 유지 (부드러운 스크롤)
            const SliverToBoxAdapter(
              child: SizedBox(height: 64),
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
                    context.push(
                      '${AppRoutes.readingCalendar}?year=$_selectedYear&month=$_selectedMonth',
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
                          year: _selectedYear,
                          month: _selectedMonth,
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
