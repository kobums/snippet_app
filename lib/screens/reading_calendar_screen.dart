import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_book.dart';
import '../providers/book_provider.dart';
import '../services/calendar_share_service.dart';
import '../widgets/calendar/shareable_reading_calendar.dart';
import '../core/design_tokens.dart';

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

  void _previousMonth() {
    setState(() {
      if (_selectedMonth == 1) {
        _selectedMonth = 12;
        _selectedYear--;
      } else {
        _selectedMonth--;
      }
    });
    _loadData();
  }

  void _nextMonth() {
    final now = DateTime.now();
    final isCurrentMonth =
        _selectedYear == now.year && _selectedMonth == now.month;

    if (!isCurrentMonth) {
      setState(() {
        if (_selectedMonth == 12) {
          _selectedMonth = 1;
          _selectedYear++;
        } else {
          _selectedMonth++;
        }
      });
      _loadData();
    }
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
      appBar: AppBar(
        title: const Text('독서 캘린더'),
        backgroundColor: DesignTokens.bgSecondary,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: bookState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    // 월/년도 네비게이션
                    _buildMonthNavigation(isCurrentMonth),

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

                    const SizedBox(height: 100), // FAB 공간 확보
                  ],
                ),
              ),
      ),
      floatingActionButton: _isSharing
          ? const FloatingActionButton(
              onPressed: null,
              backgroundColor: DesignTokens.neutral300,
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 갤러리에 저장 버튼
                FloatingActionButton.extended(
                  heroTag: 'save',
                  onPressed: () => _saveToGallery(completedBooks),
                  backgroundColor: Colors.green,
                  icon: const Icon(Icons.save_alt),
                  label: const Text('갤러리에 저장'),
                ),
                const SizedBox(height: 12),
                // 공유 버튼
                FloatingActionButton.extended(
                  heroTag: 'share',
                  onPressed: () => _shareCalendar(completedBooks),
                  backgroundColor: DesignTokens.primaryMain,
                  icon: const Icon(Icons.share),
                  label: const Text('공유하기'),
                ),
              ],
            ),
    );
  }

  Widget _buildMonthNavigation(bool isCurrentMonth) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: DesignTokens.bgSecondary,
        boxShadow: DesignTokens.shadowSm,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: _previousMonth,
            color: DesignTokens.primaryMain,
          ),
          Text(
            '$_selectedYear년 $_selectedMonth월',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: DesignTokens.textPrimary,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: isCurrentMonth ? null : _nextMonth,
            color: isCurrentMonth
                ? DesignTokens.neutral300
                : DesignTokens.primaryMain,
          ),
        ],
      ),
    );
  }
}
