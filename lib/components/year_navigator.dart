import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/glass_container.dart';
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
    final years = List.generate(
      currentYear - 2000 + 1,
      (index) => 2000 + index,
    );

    int selectedYear = year;
    final initialIndex = years.indexOf(year);

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
                      child: Text(
                        '취소',
                        style: AppTypography.bodyLarge.copyWith(
                          color: DesignTokens.textSecondary,
                        ),
                      ),
                    ),
                    Text(
                      '년도 선택',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
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
                          color: DesignTokens.primaryMain,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Picker
              Expanded(
                child: CupertinoPicker(
                  scrollController: FixedExtentScrollController(
                    initialItem: initialIndex,
                  ),
                  itemExtent: 40,
                  onSelectedItemChanged: (index) {
                    selectedYear = years[index];
                  },
                  children: years.map((y) {
                    return Center(
                      child: Text(
                        '$y년',
                        style: AppTypography.h3,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
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
            onPressed: () => onYearChanged(year - 1),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          ),
          InkWell(
            onTap: () => _showYearPicker(context),
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: DesignTokens.space12, vertical: DesignTokens.space8),
              child: Text(
                '$year년',
                style: AppTypography.bodyMedium,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.chevron_right,
              size: 20,
              color:
                  isCurrentYear ? Colors.grey.withValues(alpha: 0.3) : null,
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
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
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
    return year != oldDelegate.year ||
        isCurrentYear != oldDelegate.isCurrentYear;
  }
}
