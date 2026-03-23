import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/app_tab_bar.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/features/records/presentation/providers/record_provider.dart';
import 'package:snippet_app/features/records/presentation/providers/records_tab_provider.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';
import 'package:snippet_app/features/records/data/models/record.dart';
import 'package:snippet_app/features/records/presentation/screens/add_record_screen.dart';
import 'package:snippet_app/app/router.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/features/records/presentation/widgets/record_card.dart';
import 'package:snippet_app/components/month_navigator.dart';
import 'package:snippet_app/components/section_header.dart';
import 'package:snippet_app/core/design_tokens.dart';

class RecordsScreen extends ConsumerStatefulWidget {
  const RecordsScreen({super.key});

  @override
  ConsumerState<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends ConsumerState<RecordsScreen>
    with TickerProviderStateMixin {
  // ============================================================================
  // Constants
  // ============================================================================
  static const int _tabCount = 3;
  static const double _fixedHeaderHeight = 64.0;
  static const double _scrollContextSwitchThreshold = 50.0;
  static const double _tabAnimationThreshold = 0.1;
  static const double _swipeDetectionThreshold = 0.05;

  static const _tabTypes = [
    RecordType.snippet,
    RecordType.diary,
    RecordType.review,
  ];

  // ============================================================================
  // State
  // ============================================================================
  late TabController _tabController;
  late List<AnimationController> _scrollAnimationControllers;

  // ============================================================================
  // Lifecycle
  // ============================================================================
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupTabListeners();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _scrollAnimationControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // ============================================================================
  // Initialization
  // ============================================================================
  void _initializeControllers() {
    _tabController = TabController(length: _tabCount, vsync: this);

    _scrollAnimationControllers = List.generate(
      _tabCount,
      (_) => AnimationController(
        duration: Duration.zero,
        vsync: this,
      )..addListener(() => setState(() {})),
    );
  }

  void _setupTabListeners() {
    _tabController.addListener(() => setState(() {}));
    _tabController.animation!.addListener(_handleTabSwipe);
  }

  void _handleTabSwipe() {
    final animationValue = _tabController.animation!.value;
    final currentTab = _tabController.index;

    if (animationValue.abs() > _swipeDetectionThreshold) {
      if (_scrollAnimationControllers[currentTab].value > 0) {
        _scrollAnimationControllers[currentTab].reset();
        ref.read(recordsTabProvider.notifier).setFixedHeaderVisible(currentTab, false);
        ref.read(recordsTabProvider.notifier).setScrollPosition(currentTab, 0.0);
        setState(() {});
      }
    }
  }

  // ============================================================================
  // Scroll Handling
  // ============================================================================
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;

    final currentTab = _tabController.index;
    final tabState = ref.read(recordsTabProvider);
    final metrics = notification.metrics;
    final scrollDelta = notification.scrollDelta ?? 0;

    final pixels = metrics.pixels;
    final isScrollingDown = scrollDelta > 0;
    final lastScrollPixels = tabState.scrollPositions[currentTab] ?? 0.0;
    final isContextSwitch =
        (pixels - lastScrollPixels).abs() > _scrollContextSwitchThreshold;

    final topPadding = MediaQuery.of(context).padding.top;
    final triggerHeight = _fixedHeaderHeight + topPadding;

    const combinedHeaderHeight = kToolbarHeight + kTextTabBarHeight;
    final isInHeaderScroll = metrics.maxScrollExtent < combinedHeaderHeight + 50;

    if (isScrollingDown) {
      _handleScrollDown(currentTab, pixels, triggerHeight);
    } else {
      _handleScrollUp(
          currentTab, pixels, topPadding, isInHeaderScroll, isContextSwitch);
    }

    _syncHeaderAnimation(currentTab);
    ref.read(recordsTabProvider.notifier).setScrollPosition(currentTab, pixels);
    return false;
  }

  void _handleScrollDown(int tab, double pixels, double triggerHeight) {
    final tabState = ref.read(recordsTabProvider);

    if (pixels >= triggerHeight) {
      ref.read(recordsTabProvider.notifier).setFixedHeaderVisible(tab, true);
    }

    if ((tabState.showFixedHeaders[tab] ?? false) &&
        _scrollAnimationControllers[tab].value < 1.0) {
      _scrollAnimationControllers[tab].forward();
    }
  }

  void _handleScrollUp(
    int tab,
    double pixels,
    double topPadding,
    bool isInHeaderScroll,
    bool isContextSwitch,
  ) {
    if (isInHeaderScroll &&
        !isContextSwitch &&
        pixels < topPadding + _fixedHeaderHeight) {
      ref.read(recordsTabProvider.notifier).setFixedHeaderVisible(tab, false);
      if (_scrollAnimationControllers[tab].value > 0.0) {
        _scrollAnimationControllers[tab].reverse();
      }
    }
  }

  void _syncHeaderAnimation(int tab) {
    final tabState = ref.read(recordsTabProvider);

    if (!(tabState.showFixedHeaders[tab] ?? false) &&
        _scrollAnimationControllers[tab].value > 0.0) {
      _scrollAnimationControllers[tab].reverse();
    }
  }

  // ============================================================================
  // Actions
  // ============================================================================
  void showAddRecordSheet(BuildContext context) {
    final bookState = ref.read(bookProvider);

    if (bookState.books.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('먼저 책을 추가해주세요'),
          backgroundColor: DesignTokens.errorMain,
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

  // ============================================================================
  // Build
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final currentTab = _tabController.index;
    final isScrolled = _isHeaderScrolled(currentTab);

    return Stack(
      children: [
        _buildMainContent(isScrolled),
        _buildFixedHeaders(currentTab, topPadding, isScrolled),
      ],
    );
  }

  Widget _buildMainContent(bool isScrolled) {
    final headerOpacity = isScrolled ? 0.0 : 1.0;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => [
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
              _buildTabContent(type, headerOpacity),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedHeaders(int currentTab, double topPadding, bool isScrolled) {
    if (!isScrolled) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: Duration.zero,
        opacity: 1.0,
        child: _buildFixedMonthNavigator(topPadding),
      ),
    );
  }

  bool _isHeaderScrolled(int tab) {
    return _scrollAnimationControllers[tab].value >= 1.0 &&
        !_tabController.indexIsChanging &&
        (_tabController.animation!.value - tab).abs() < _tabAnimationThreshold;
  }

  Widget _buildFixedMonthNavigator(double topPadding) {
    final recordState = ref.watch(recordProvider);
    final recordNotifier = ref.read(recordProvider.notifier);
    final now = DateTime.now();
    final isCurrentMonth = recordState.selectedYear == now.year &&
        recordState.selectedMonth == now.month;

    return Container(
      padding: EdgeInsets.only(top: topPadding),
      height: _fixedHeaderHeight + topPadding,
      child: Center(
        child: MonthNavigator(
          year: recordState.selectedYear,
          month: recordState.selectedMonth,
          isCurrentMonth: isCurrentMonth,
          onMonthChanged: recordNotifier.setSelectedMonth,
        ),
      ),
    );
  }

  // ============================================================================
  // Tab Content
  // ============================================================================
  Widget _buildTabContent(RecordType type, double headerOpacity) {
    final recordState = ref.watch(recordProvider);
    final recordNotifier = ref.read(recordProvider.notifier);
    final now = DateTime.now();
    final isCurrentMonth = recordState.selectedYear == now.year &&
        recordState.selectedMonth == now.month;

    final filteredRecords =
        recordState.allRecords.where((r) => r.type == type).toList();

    return AppRefreshIndicator(
      onRefresh: () => recordNotifier.refreshRecords(),
      child: CustomScrollView(
        slivers: [
          // Conditional rendering with placeholder
          if (headerOpacity > 0)
            SliverToBoxAdapter(
              child: SizedBox(
                height: _fixedHeaderHeight,
                child: Center(
                  child: MonthNavigator(
                    year: recordState.selectedYear,
                    month: recordState.selectedMonth,
                    isCurrentMonth: isCurrentMonth,
                    onMonthChanged: recordNotifier.setSelectedMonth,
                  ),
                ),
              ),
            )
          else
            const SliverToBoxAdapter(
              child: SizedBox(height: 64),
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
