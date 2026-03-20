import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/app_tab_bar.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/features/records/presentation/providers/record_provider.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/presentation/screens/add_record_screen.dart';
import 'package:snippet_app/app/router.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/features/records/presentation/widgets/record_card.dart';
import 'package:snippet_app/components/month_navigator.dart';
import 'package:snippet_app/components/section_header.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  static const _tabTypes = [
    RecordType.snippet,
    RecordType.diary,
    RecordType.review,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

    context.push(
      AppRoutes.addRecord,
      extra: AddRecordScreenParams(
        books: bookState.books,
        initialType: _tabTypes[_tabController.index],
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

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        AppAppBar.sliver(
          title: '독서 기록',
          bottom: AppTabBar(
            controller: _tabController,
            tabs: const ['스니펫', '독서일기', '리뷰'],
            margin: EdgeInsets.zero,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: [
          for (final type in _tabTypes)
            _buildTabContent(type, recordState, recordNotifier, isCurrentMonth),
        ],
      ),
    );
  }

  Widget _buildTabContent(
    RecordType type,
    RecordState recordState,
    RecordNotifier recordNotifier,
    bool isCurrentMonth,
  ) {
    final filteredRecords = recordState.allRecords
        .where((r) => r.type == type)
        .toList();

    return AppRefreshIndicator(
      onRefresh: () => recordNotifier.refreshRecords(),
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyMonthNavigator(
              year: recordState.selectedYear,
              month: recordState.selectedMonth,
              isCurrentMonth: isCurrentMonth,
              onMonthChanged: (year, month) {
                recordNotifier.setSelectedMonth(year, month);
              },
              height: 64,
            ),
          ),
          _buildRecordsSliver(filteredRecords, recordState.isLoading),
        ],
      ),
    );
  }

  Widget _buildRecordsSliver(List<RecordDto> records, bool isLoading) {
    if (records.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
            ],
          ),
        ),
      );
    }

    final groupedRecords = <String, List<RecordDto>>{};
    for (final record in records) {
      final key = record.bookTitle;
      if (!groupedRecords.containsKey(key)) {
        groupedRecords[key] = [];
      }
      groupedRecords[key]!.add(record);
    }

    final widgets = <Widget>[
      Padding(
        padding: const EdgeInsets.only(left: 8.0, bottom: 12, top: 8),
        child: SectionHeader(
          '기록 (${records.length})',
          size: SectionHeaderSize.small,
          padding: EdgeInsets.zero,
        ),
      ),
      ...groupedRecords.entries.expand(
        (entry) => [
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
          ...entry.value.map((record) => RecordCard(record: record)),
          const SizedBox(height: 12),
        ],
      ),
    ];

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => widgets[index],
          childCount: widgets.length,
        ),
      ),
    );
  }
}
