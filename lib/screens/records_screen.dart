import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_tab_bar.dart';
import '../providers/record_provider.dart';
import '../providers/book_provider.dart';
import '../models/record.dart';
import '../widgets/glass_container.dart';
import '../widgets/records/add_record_bottom_sheet.dart';
import '../widgets/records/record_card.dart';
import '../components/month_navigator.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      final type = _getTypeFromIndex(_tabController.index);
      ref.read(recordProvider.notifier).setSelectedType(type);
    }
  }

  RecordType? _getTypeFromIndex(int index) {
    switch (index) {
      case 0:
        return RecordType.snippet;
      case 1:
        return RecordType.diary;
      case 2:
        return RecordType.review;
      default:
        return null;
    }
  }

  void showAddRecordSheet(BuildContext context) {
    final bookState = ref.read(bookProvider);

    if (bookState.books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('먼저 책을 추가해주세요'),
          backgroundColor: const Color(0xFFFF3B30),
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height * 0.1,
            left: 16,
            right: 16,
          ),
          duration: const Duration(seconds: 2),
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddRecordBottomSheet(
        books: bookState.books,
        initialType: _getTypeFromIndex(_tabController.index),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final recordState = ref.watch(recordProvider);
    final recordNotifier = ref.read(recordProvider.notifier);

    final now = DateTime.now();
    final isCurrentMonth =
        recordState.selectedYear == now.year &&
        recordState.selectedMonth == now.month;

    return Column(
      children: [
        // TabBar
        AppTabBar(
          controller: _tabController,
          tabs: const ['스니펫', '독서일기', '리뷰'],
          margin: EdgeInsets.zero,
        ),
        // TabBarView
        Expanded(
          child: RefreshIndicator(
            onRefresh: () => recordNotifier.refreshRecords(),
            child: TabBarView(
              controller: _tabController,
              children: [
                // Each tab shows the same content structure
                for (int i = 0; i < 3; i++)
                  SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Month Navigator
                        MonthNavigator(
                          year: recordState.selectedYear,
                          month: recordState.selectedMonth,
                          isCurrentMonth: isCurrentMonth,
                          onMonthChanged: (year, month) {
                            recordNotifier.setSelectedMonth(year, month);
                          },
                        ),
                        const SizedBox(height: 16),

                        // Records List
                        _buildRecordsList(
                          recordState.records,
                          recordState.isLoading,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRecordsList(List<RecordDto> records, bool isLoading) {
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (records.isEmpty) {
      return GlassContainer(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 32),
              Icon(
                Icons.edit_note_rounded,
                size: 64,
                color: Colors.black.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                '아직 기록이 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '첫 기록을 추가해보세요!',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    }

    // Group records by book
    final groupedRecords = <String, List<RecordDto>>{};
    for (final record in records) {
      final key = record.bookTitle;
      if (!groupedRecords.containsKey(key)) {
        groupedRecords[key] = [];
      }
      groupedRecords[key]!.add(record);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12),
          child: Text(
            '기록 (${records.length})',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 1,
              color: Colors.black.withValues(alpha: 0.6),
            ),
          ),
        ),
        ...groupedRecords.entries.map((entry) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Book title header
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 12.0,
                ),
                child: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              // Records for this book
              ...entry.value.map((record) => RecordCard(record: record)),
              const SizedBox(height: 12),
            ],
          );
        }),
      ],
    );
  }
}
