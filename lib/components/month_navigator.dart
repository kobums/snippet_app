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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _onPreviousMonth,
        ),
        InkWell(
          onTap: () => _showMonthPicker(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '$year년 $month월',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w400,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        IconButton(
          icon: Icon(
            Icons.chevron_right,
            color: isCurrentMonth ? Colors.grey.withValues(alpha: 0.3) : null,
          ),
          onPressed: isCurrentMonth ? null : _onNextMonth,
        ),
      ],
    );
  }
}
