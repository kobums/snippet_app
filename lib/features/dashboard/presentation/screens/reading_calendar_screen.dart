import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';
import 'package:snippet_app/features/dashboard/data/datasources/calendar_share_datasource.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/shareable_reading_calendar.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/components/app_button.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/month_navigator.dart';

class ReadingCalendarScreen extends ConsumerStatefulWidget {
  const ReadingCalendarScreen({super.key});

  @override
  ConsumerState<ReadingCalendarScreen> createState() =>
      _ReadingCalendarScreenState();
}

class _ReadingCalendarScreenState extends ConsumerState<ReadingCalendarScreen> {
  late int _selectedYear;
  late int _selectedMonth;
  bool _isSaving = false;
  bool _isSharing = false;

  final CalendarShareService _shareService = CalendarShareService();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedYear = now.year;
    _selectedMonth = now.month;
  }

  Future<void> _loadData() async {
    await ref
        .read(bookProvider.notifier)
        .loadDashboard(_selectedYear, _selectedMonth);
  }

  Future<void> _shareCalendar(List<UserBookDto> completedBooks) async {
    setState(() {
      _isSharing = true;
    });

    try {
      final calendarWidget = ShareableReadingCalendar(
        completedBooks: completedBooks,
        year: _selectedYear,
        month: _selectedMonth,
      );

      if (mounted) {
        await _shareService.captureAndShare(
          context,
          calendarWidget,
          _selectedYear,
          _selectedMonth,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSharing = false;
        });
      }
    }
  }

  Future<void> _saveToGallery(List<UserBookDto> completedBooks) async {
    setState(() {
      _isSaving = true;
    });

    try {
      final calendarWidget = ShareableReadingCalendar(
        completedBooks: completedBooks,
        year: _selectedYear,
        month: _selectedMonth,
      );

      if (mounted) {
        await _shareService.captureAndSaveToGallery(
          context,
          calendarWidget,
          _selectedYear,
          _selectedMonth,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(bookProvider);
    final completedBooks = bookState.books
        .where((book) => book.status == BookStatus.completed)
        .toList();

    final now = DateTime.now();
    final isCurrentMonth =
        _selectedYear == now.year && _selectedMonth == now.month;

    return Scaffold(
      backgroundColor: DesignTokens.bgPrimary,
      appBar: const AppAppBar(title: '독서 캘린더'),
      body: AppRefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: StickyMonthNavigator(
                year: _selectedYear,
                month: _selectedMonth,
                isCurrentMonth: isCurrentMonth,
                onMonthChanged: (year, month) {
                  setState(() {
                    _selectedYear = year;
                    _selectedMonth = month;
                  });
                  _loadData();
                },
                height: 64,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  AspectRatio(
                    aspectRatio: 1080 / 1350,
                    child: FittedBox(
                      fit: BoxFit.contain,
                      child: SizedBox(
                        width: 1080,
                        height: 1350,
                        child: ShareableReadingCalendar(
                          completedBooks: completedBooks,
                          year: _selectedYear,
                          month: _selectedMonth,
                          showTitle: false,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: DesignTokens.primaryMain.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMd,
                      ),
                      border: Border.all(
                        color: DesignTokens.primaryMain.withValues(alpha: 0.1),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: DesignTokens.primaryMain,
                          size: 20,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '저장 버튼으로 갤러리에 저장하거나, 공유 버튼으로 Instagram 등에 공유할 수 있습니다.',
                            style: TextStyle(
                              fontSize: 14,
                              color: DesignTokens.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          text: '저장',
                          icon: Icons.save_alt,
                          variant: AppButtonVariant.secondary,
                          size: AppButtonSize.large,
                          isFullWidth: true,
                          isLoading: _isSaving,
                          onPressed: _isSaving
                              ? null
                              : () => _saveToGallery(completedBooks),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          text: '공유',
                          icon: Icons.share,
                          variant: AppButtonVariant.primary,
                          size: AppButtonSize.large,
                          isFullWidth: true,
                          isLoading: _isSharing,
                          onPressed: _isSharing
                              ? null
                              : () => _shareCalendar(completedBooks),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
