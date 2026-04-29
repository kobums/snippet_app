import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../core/app_colors.dart';
import '../core/design_tokens.dart';
import '../core/typography.dart';

/// Reusable Year Navigator component
class YearNavigator extends StatelessWidget {
  final int year;
  final Function(int year) onYearChanged;
  final bool isCurrentYear;

  const YearNavigator({
    super.key,
    required this.year,
    required this.onYearChanged,
    this.isCurrentYear = false,
  });

  Future<void> _showYearPicker(BuildContext context) async {
    final currentYear = DateTime.now().year;
    final years = List.generate(currentYear - 2000 + 1, (i) => 2000 + i);
    int selectedYear = year;
    final initialIndex = years.indexOf(year);

    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: appColors.border),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        '취소',
                        style: AppTypography.bodyLarge.copyWith(
                          color: appColors.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '년도 선택',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: appColors.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onYearChanged(selectedYear);
                        Navigator.pop(context);
                      },
                      child: Text(
                        '완료',
                        style: AppTypography.bodyLarge.copyWith(
                          color: appColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(initialItem: initialIndex),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) => selectedYear = years[index],
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
            icon: const Icon(Icons.chevron_left, size: DesignTokens.iconSm),
            onPressed: () => onYearChanged(year - 1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          InkWell(
            onTap: () => _showYearPicker(context),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: DesignTokens.space12,
                vertical: DesignTokens.space8,
              ),
              child: Text(
                '$year년',
                style: AppTypography.bodyMedium.copyWith(color: appColors.textPrimary),
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              size: DesignTokens.iconSm,
              color: isCurrentYear ? appColors.textDisabled : appColors.textPrimary,
            ),
            onPressed: isCurrentYear ? null : () => onYearChanged(year + 1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
        ],
      ),
    );
  }
}

/// Sticky Year Navigator Delegate for CustomScrollView
class StickyYearNavigator extends SliverPersistentHeaderDelegate {
  final int year;
  final bool isCurrentYear;
  final Function(int year) onYearChanged;
  final double height;

  StickyYearNavigator({
    required this.year,
    required this.isCurrentYear,
    required this.onYearChanged,
    this.height = 64.0,
  });

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Center(
      child: YearNavigator(
        year: year,
        isCurrentYear: isCurrentYear,
        onYearChanged: onYearChanged,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant StickyYearNavigator oldDelegate) {
    return year != oldDelegate.year || isCurrentYear != oldDelegate.isCurrentYear;
  }
}
