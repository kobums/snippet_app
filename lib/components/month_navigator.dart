import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/glass_container.dart';
import '../core/design_tokens.dart';

/// Reusable Month Navigator component
class MonthNavigator extends StatelessWidget {
  final int year;
  final int month;
  final Function(int year, int month) onMonthChanged;
  final bool isCurrentMonth;

  const MonthNavigator({
    super.key,
    required this.year,
    required this.month,
    required this.onMonthChanged,
    this.isCurrentMonth = false,
  });

  void _onPreviousMonth() {
    if (month == 1) {
      onMonthChanged(year - 1, 12);
    } else {
      onMonthChanged(year, month - 1);
    }
  }

  void _onNextMonth() {
    if (month == 12) {
      onMonthChanged(year + 1, 1);
    } else {
      onMonthChanged(year, month + 1);
    }
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final currentYear = DateTime.now().year;
    final currentMonth = DateTime.now().month;
    final years = List.generate(
      currentYear - 2000 + 1,
      (index) => 2000 + index,
    );
    final months = List.generate(12, (index) => index + 1);

    int selectedYear = year;
    int selectedMonth = month;

    final yearInitialIndex = years.indexOf(year);
    final monthInitialIndex = month - 1;

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: 300,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: DesignTokens.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Text(
                      '년월 선택',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // 미래 날짜 선택 방지
                        if (selectedYear > currentYear ||
                            (selectedYear == currentYear &&
                                selectedMonth > currentMonth)) {
                          // 현재 월로 설정
                          selectedYear = currentYear;
                          selectedMonth = currentMonth;
                        }
                        onMonthChanged(selectedYear, selectedMonth);
                        Navigator.pop(context);
                      },
                      child: const Text(
                        '완료',
                        style: TextStyle(
                          color: DesignTokens.primaryMain,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Pickers
              Expanded(
                child: Row(
                  children: [
                    // Year Picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: yearInitialIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          selectedYear = years[index];
                        },
                        children: years.map((y) {
                          return Center(
                            child: Text(
                              '$y년',
                              style: const TextStyle(
                                fontSize: 20,
                                color: DesignTokens.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    // Month Picker
                    Expanded(
                      child: CupertinoPicker(
                        scrollController: FixedExtentScrollController(
                          initialItem: monthInitialIndex,
                        ),
                        itemExtent: 40,
                        onSelectedItemChanged: (index) {
                          selectedMonth = months[index];
                        },
                        children: months.map((m) {
                          return Center(
                            child: Text(
                              '$m월',
                              style: const TextStyle(
                                fontSize: 20,
                                color: DesignTokens.textPrimary,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 20),
            onPressed: _onPreviousMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          InkWell(
            onTap: () => _showMonthPicker(context),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Text(
                '$year년 $month월',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              size: 20,
              color:
                  isCurrentMonth ? Colors.grey.withValues(alpha: 0.3) : null,
            ),
            onPressed: isCurrentMonth ? null : _onNextMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

/// Sticky Month Navigator Delegate for CustomScrollView
///
/// StickyGlassSegmentedButton과 동일한 패턴의 sticky header
class StickyMonthNavigator extends SliverPersistentHeaderDelegate {
  final int year;
  final int month;
  final bool isCurrentMonth;
  final Function(int year, int month) onMonthChanged;
  final double height;

  StickyMonthNavigator({
    required this.year,
    required this.month,
    required this.isCurrentMonth,
    required this.onMonthChanged,
    this.height = 64.0,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Center(
      child: MonthNavigator(
        year: year,
        month: month,
        isCurrentMonth: isCurrentMonth,
        onMonthChanged: onMonthChanged,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StickyMonthNavigator oldDelegate) {
    return year != oldDelegate.year ||
        month != oldDelegate.month ||
        isCurrentMonth != oldDelegate.isCurrentMonth;
  }
}
