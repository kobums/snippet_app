import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';
import 'app_button.dart';

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
      useRootNavigator: true, // 최상위 네비게이터 사용
      elevation: 10, // FAB 및 다른 요소보다 위에 표시
      builder: (BuildContext context) {
        final appColors = context.colors;
        return Container(
          height: 300,
          decoration: BoxDecoration(
            color: appColors.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: DesignTokens.space16,
                  vertical: DesignTokens.space16,
                ),
                child: Center(
                  child: Text(
                    '년월 선택',
                    style: AppTypography.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                      color: appColors.textPrimary,
                    ),
                  ),
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
                              style: AppTypography.h3.copyWith(color: appColors.textPrimary),
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
                              style: AppTypography.h3.copyWith(color: appColors.textPrimary),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.all(DesignTokens.space16),
                decoration: BoxDecoration(color: appColors.surface),
                child: AppButton(
                  text: '완료',
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
                  variant: AppButtonVariant.primary,
                  size: AppButtonSize.large,
                  isFullWidth: true,
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
    final appColors = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space4),
      decoration: BoxDecoration(
        color: appColors.glassDark,
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        border: Border.all(color: appColors.glassBorder, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.chevron_left, size: DesignTokens.iconSm, color: appColors.textPrimary),
            onPressed: _onPreviousMonth,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          InkWell(
            onTap: () => _showMonthPicker(context),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space12, vertical: DesignTokens.space8),
              child: Text(
                '$year년 $month월',
                style: AppTypography.bodyMedium.copyWith(color: appColors.textPrimary),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              size: DesignTokens.iconSm,
              color: isCurrentMonth ? appColors.textDisabled : appColors.textPrimary,
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
  final double topPadding;
  final double paddingProgress; // 0.0 ~ 1.0

  StickyMonthNavigator({
    required this.year,
    required this.month,
    required this.isCurrentMonth,
    required this.onMonthChanged,
    this.height = 64.0,
    this.topPadding = 0.0,
    this.paddingProgress = 0.0,
  });

  @override
  double get minExtent => height + (topPadding * paddingProgress);

  @override
  double get maxExtent => height + (topPadding * paddingProgress);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    // paddingProgress에 따라 점진적으로 패딩 적용 (0.0 ~ 1.0)
    final currentPadding = topPadding * paddingProgress;

    return Container(
      color: context.colors.surface,
      padding: EdgeInsets.only(top: currentPadding),
      child: Center(
        child: MonthNavigator(
          year: year,
          month: month,
          isCurrentMonth: isCurrentMonth,
          onMonthChanged: onMonthChanged,
        ),
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StickyMonthNavigator oldDelegate) {
    return year != oldDelegate.year ||
        month != oldDelegate.month ||
        isCurrentMonth != oldDelegate.isCurrentMonth ||
        paddingProgress != oldDelegate.paddingProgress;
  }
}
