import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/user_book.dart';

class ReadingCalendar extends StatefulWidget {
  final List<UserBookDto> completedBooks;
  final int year;
  final int month;

  const ReadingCalendar({
    super.key,
    required this.completedBooks,
    required this.year,
    required this.month,
  });

  @override
  State<ReadingCalendar> createState() => _ReadingCalendarState();
}

class _ReadingCalendarState extends State<ReadingCalendar> {
  DateTime? _selectedDay;
  late DateTime _focusedDay;

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime(widget.year, widget.month, 1);
  }

  @override
  void didUpdateWidget(ReadingCalendar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.year != widget.year || oldWidget.month != widget.month) {
      _focusedDay = DateTime(widget.year, widget.month, 1);
    }
  }

  List<UserBookDto> _getBooksCompletedOnDate(DateTime date) {
    return widget.completedBooks.where((book) {
      if (book.endDate.isEmpty) return false;
      final endDate = DateTime.tryParse(book.endDate);
      if (endDate == null) return false;
      return endDate.year == date.year &&
          endDate.month == date.month &&
          endDate.day == date.day;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return TableCalendar(
      firstDay: DateTime(widget.year, widget.month, 1),
      lastDay: DateTime(widget.year, widget.month + 1, 0),
      focusedDay: _focusedDay,
      selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
      onDaySelected: (selectedDay, focusedDay) {
        setState(() {
          _selectedDay = selectedDay;
          _focusedDay = focusedDay;
        });

        // Show books completed on this day
        final booksOnDay = _getBooksCompletedOnDate(selectedDay);
        if (booksOnDay.isNotEmpty) {
          _showBooksDialog(context, selectedDay, booksOnDay);
        }
      },
      calendarFormat: CalendarFormat.month,
      availableCalendarFormats: const {
        CalendarFormat.month: 'Month',
      },
      headerVisible: false, // We're showing month in the parent
      calendarStyle: CalendarStyle(
        // Today
        todayDecoration: BoxDecoration(
          color: const Color(0xFF7C5CBF).withValues(alpha: 0.3),
          shape: BoxShape.circle,
        ),
        todayTextStyle: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
        // Selected day
        selectedDecoration: const BoxDecoration(
          color: Color(0xFF7C5CBF),
          shape: BoxShape.circle,
        ),
        selectedTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
        // Days with completed books
        markerDecoration: const BoxDecoration(
          color: Color(0xFF34C759),
          shape: BoxShape.circle,
        ),
        markersMaxCount: 3,
        // Default text style
        defaultTextStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
        ),
        weekendTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: Colors.red.withValues(alpha: 0.7),
        ),
      ),
      daysOfWeekStyle: DaysOfWeekStyle(
        weekdayStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.black.withValues(alpha: 0.6),
        ),
        weekendStyle: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: Colors.red.withValues(alpha: 0.7),
        ),
      ),
      eventLoader: (day) {
        // Return list of books completed on this day for markers
        return _getBooksCompletedOnDate(day);
      },
    );
  }

  void _showBooksDialog(
      BuildContext context, DateTime date, List<UserBookDto> books) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          '${date.month}월 ${date.day}일 완독',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    book.coverUrl,
                    width: 40,
                    height: 60,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 40,
                        height: 60,
                        color: Colors.grey.withValues(alpha: 0.3),
                        child: const Icon(Icons.book, size: 24),
                      );
                    },
                  ),
                ),
                title: Text(
                  book.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  book.author,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w300,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
        ],
      ),
    );
  }
}
