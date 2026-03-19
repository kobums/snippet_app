import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/app_refresh_indicator.dart';
import '../models/user_book.dart';
import '../providers/book_provider.dart';
import '../services/calendar_share_service.dart';
import '../widgets/calendar/shareable_reading_calendar.dart';
import '../core/design_tokens.dart';
import '../components/app_button.dart';
import '../components/app_app_bar.dart';
import '../components/month_navigator.dart';

/// 독서 캘린더 전체 화면
///
/// 월별 독서 완료 내역을 캘린더로 보여주고 Instagram 공유 기능을 제공합니다.
class ReadingCalendarScreen extends ConsumerStatefulWidget {
  const ReadingCalendarScreen({super.key});

  @override
  ConsumerState<ReadingCalendarScreen> createState() =>
      _ReadingCalendarScreenState();
}

class _ReadingCalendarScreenState extends ConsumerState<ReadingCalendarScreen> {
  late int _selectedYear;
  late int _selectedMonth;
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
      _isSharing = true;
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
          _isSharing = false;
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
      appBar: const AppAppBar(
        title: '독서 캘린더',
        // bottom: PreferredSize(
        //   preferredSize: const Size.fromHeight(56),
        //   child: _buildMonthNavigation(isCurrentMonth),
        // ),
      ),
      body: AppRefreshIndicator(
        onRefresh: _loadData,
        child: bookState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: MonthNavigator(
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
                      ),
                    ),

                    const SizedBox(height: 16),

                    // 캘린더 프리뷰 (저장되는 이미지와 동일)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: AspectRatio(
                        aspectRatio: 1080 / 1350, // 4:5 비율 (Instagram 피드 최적)
                        child: FittedBox(
                          fit: BoxFit.contain,
                          child: SizedBox(
                            width: 1080, // 실제 저장되는 크기와 동일
                            height: 1350, // 실제 저장되는 크기와 동일 (4:5 비율)
                            child: ShareableReadingCalendar(
                              completedBooks: completedBooks,
                              year: _selectedYear,
                              month: _selectedMonth,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // 안내 텍스트
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: DesignTokens.primaryMain.withValues(
                            alpha: 0.05,
                          ),
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusMd,
                          ),
                          border: Border.all(
                            color: DesignTokens.primaryMain.withValues(
                              alpha: 0.1,
                            ),
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
                    ),

                    const SizedBox(height: 16),

                    // 버튼들
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          // 갤러리에 저장 버튼
                          Expanded(
                            child: AppButton(
                              text: '저장',
                              icon: Icons.save_alt,
                              variant: AppButtonVariant.secondary,
                              size: AppButtonSize.large,
                              isFullWidth: true,
                              isLoading: _isSharing,
                              onPressed: _isSharing
                                  ? null
                                  : () => _saveToGallery(completedBooks),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // 공유 버튼
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
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

}
