import 'package:flutter/material.dart';
import '../widgets/glass_container.dart';

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
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime(year),
      firstDate: DateTime(2000),
      lastDate: DateTime(currentYear),
      initialDatePickerMode: DatePickerMode.year,
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
      onYearChanged(selectedDate.year);
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
      ),
    );
  }
}
