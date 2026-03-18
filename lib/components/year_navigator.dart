import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../widgets/glass_container.dart';
import '../core/design_tokens.dart';

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
                      child: const Text(
                        '취소',
                        style: TextStyle(
                          color: DesignTokens.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    const Text(
                      '년도 선택',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: DesignTokens.textPrimary,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        onYearChanged(selectedYear);
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
          onPressed: () => onYearChanged(year - 1),
        ),
        InkWell(
          onTap: () => _showYearPicker(context),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              '$year년',
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
            color: isCurrentYear ? Colors.grey.withValues(alpha: 0.3) : null,
          ),
          onPressed: isCurrentYear ? null : () => onYearChanged(year + 1),
        ),
      ],
    );
  }
}
