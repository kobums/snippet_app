import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

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
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(year, month),
      firstDate: DateTime(2000),
      lastDate: now,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: const Color(0xFF6C63FF),
                ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate != null) {
      onMonthChanged(selectedDate.year, selectedDate.month);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      child: Row(
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
      ),
    );
  }
}
