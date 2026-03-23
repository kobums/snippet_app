import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_stats_section.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_progress_section.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_library_section.dart';
import 'package:snippet_app/components/app_tab_bar.dart';
import 'package:snippet_app/components/month_navigator.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';
import 'package:snippet_app/components/search_field.dart';
import 'package:snippet_app/features/library/presentation/providers/library_provider.dart';
import 'package:snippet_app/components/app_segmented_button.dart';
import 'package:snippet_app/features/dashboard/presentation/providers/dashboard_provider.dart';

/// 대시보드 화면
///
/// 3개 탭으로 구성 (통계/진행/서재)되며, 각 탭마다 독립적인 sticky header를 지원합니다.
/// 스크롤 시 헤더가 상단에 고정되며, 탭 전환 시 자동으로 숨겨집니다.
class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  // ============================================================================
  // Constants
  // ============================================================================
  static const int _tabCount = 3;
  static const double _fixedHeaderHeight = 64.0;
  static const double _scrollContextSwitchThreshold = 50.0;
  static const double _tabAnimationThreshold = 0.1;
  static const double _swipeDetectionThreshold = 0.05;
  static const List<String> _progressSegments = ['대기중', '읽는중', '완독'];

  // ============================================================================
  // State
  // ============================================================================
  late TabController _tabController;
  late List<AnimationController> _scrollAnimationControllers;

  // 스크롤 추적 (각 탭별로 독립적 관리)
  final List<double> _lastScrollPixels = List.filled(_tabCount, 0.0);
  final List<bool> _shouldShowFixedHeader = List.filled(_tabCount, false);

  // 2번 탭: 검색 컨트롤러 (고정 헤더와 본문 헤더 동기화용)
  final TextEditingController _searchController = TextEditingController();

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
    _searchController.dispose();
    super.dispose();
  }

  // ============================================================================
  // Initialization
  // ============================================================================
  void _initializeControllers() {
    _tabController = TabController(length: _tabCount, vsync: this);

    // 각 탭마다 독립적인 애니메이션 컨트롤러 생성 (즉시 반영)
    _scrollAnimationControllers = List.generate(
      _tabCount,
      (_) => AnimationController(
        duration: Duration.zero,
        vsync: this,
      )..addListener(() => setState(() {})),
    );
  }

  void _setupTabListeners() {
    // 탭 변경 시 UI 업데이트
    _tabController.addListener(() => setState(() {}));

    // 스와이프 감지 및 헤더 리셋
    _tabController.animation!.addListener(_handleTabSwipe);
  }

  void _handleTabSwipe() {
    final animationValue = _tabController.animation!.value;
    final currentTab = _tabController.index;

    // 스와이프 시작 감지 시 현재 탭의 고정 헤더 즉시 리셋
    if (animationValue.abs() > _swipeDetectionThreshold) {
      if (_scrollAnimationControllers[currentTab].value > 0) {
        _scrollAnimationControllers[currentTab].reset();
        _shouldShowFixedHeader[currentTab] = false;
        _lastScrollPixels[currentTab] = 0.0;
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
    final metrics = notification.metrics;
    final scrollDelta = notification.scrollDelta ?? 0;

    final pixels = metrics.pixels;
    final isScrollingDown = scrollDelta > 0;
    final isContextSwitch =
        (pixels - _lastScrollPixels[currentTab]).abs() > _scrollContextSwitchThreshold;

    final topPadding = MediaQuery.of(context).padding.top;
    final triggerHeight = _fixedHeaderHeight + topPadding;

    // Header/Body 스크롤 구분
    const combinedHeaderHeight = kToolbarHeight + kTextTabBarHeight;
    final isInHeaderScroll = metrics.maxScrollExtent < combinedHeaderHeight + 50;

    if (isScrollingDown) {
      _handleScrollDown(currentTab, pixels, triggerHeight);
    } else {
      _handleScrollUp(currentTab, pixels, topPadding, isInHeaderScroll, isContextSwitch);
    }

    // 헤더 표시 상태와 애니메이션 동기화
    _syncHeaderAnimation(currentTab);

    _lastScrollPixels[currentTab] = pixels;
    return false;
  }

  void _handleScrollDown(int tab, double pixels, double triggerHeight) {
    if (pixels >= triggerHeight) {
      _shouldShowFixedHeader[tab] = true;
    }

    if (_shouldShowFixedHeader[tab] &&
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
    // Header 영역 스크롤 중이고 컨텍스트 전환이 아닐 때만 숨김
    if (isInHeaderScroll &&
        !isContextSwitch &&
        pixels < topPadding + _fixedHeaderHeight) {
      _shouldShowFixedHeader[tab] = false;
      if (_scrollAnimationControllers[tab].value > 0.0) {
        _scrollAnimationControllers[tab].reverse();
      }
    }
  }

  void _syncHeaderAnimation(int tab) {
    if (!_shouldShowFixedHeader[tab] &&
        _scrollAnimationControllers[tab].value > 0.0) {
      _scrollAnimationControllers[tab].reverse();
    }
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
            title: '대시보드',
            bottom: AppTabBar(
              controller: _tabController,
              tabs: const ['통계', '진행', '서재'],
              margin: EdgeInsets.zero,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            DashboardStatsSection(headerOpacity: headerOpacity),
            DashboardProgressSection(headerOpacity: headerOpacity),
            DashboardLibrarySection(
              headerOpacity: headerOpacity,
              searchController: _searchController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedHeaders(int currentTab, double topPadding, bool isScrolled) {
    if (!isScrolled) return const SizedBox.shrink();

    final headers = [
      _buildFixedMonthNavigator(topPadding),
      _buildFixedSegmentedButton(topPadding),
      _buildFixedSearchField(topPadding),
    ];

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: Duration.zero,
        opacity: 1.0,
        child: headers[currentTab],
      ),
    );
  }

  bool _isHeaderScrolled(int tab) {
    return _scrollAnimationControllers[tab].value >= 1.0 &&
        !_tabController.indexIsChanging &&
        (_tabController.animation!.value - tab).abs() < _tabAnimationThreshold;
  }

  // ============================================================================
  // Fixed Header Builders
  // ============================================================================
  Widget _buildFixedMonthNavigator(double topPadding) {
    final bookState = ref.watch(bookProvider);
    final bookNotifier = ref.read(bookProvider.notifier);
    final now = DateTime.now();
    final isCurrentMonth = bookState.selectedYear == now.year &&
        bookState.selectedMonth == now.month;

    return _buildFixedHeaderContainer(
      topPadding: topPadding,
      child: MonthNavigator(
        year: bookState.selectedYear,
        month: bookState.selectedMonth,
        isCurrentMonth: isCurrentMonth,
        onMonthChanged: bookNotifier.setSelectedMonth,
      ),
    );
  }

  Widget _buildFixedSegmentedButton(double topPadding) {
    final dashboardState = ref.watch(dashboardProvider);
    final dashboardNotifier = ref.read(dashboardProvider.notifier);

    return _buildFixedHeaderContainer(
      topPadding: topPadding,
      child: AppSegmentedButton(
        selectedIndex: dashboardState.selectedProgressFilter,
        segments: _progressSegments,
        onChanged: dashboardNotifier.setProgressFilter,
      ),
    );
  }

  Widget _buildFixedSearchField(double topPadding) {
    final libraryNotifier = ref.read(libraryProvider.notifier);

    return _buildFixedHeaderContainer(
      topPadding: topPadding,
      usePadding: true,
      child: SearchField(
        controller: _searchController,
        hintText: '제목이나 저자로 검색...',
        onChanged: libraryNotifier.setSearchQuery,
        onClear: () {
          _searchController.clear();
          libraryNotifier.setSearchQuery('');
        },
      ),
    );
  }

  /// 고정 헤더를 위한 공통 컨테이너
  Widget _buildFixedHeaderContainer({
    required double topPadding,
    required Widget child,
    bool usePadding = false,
  }) {
    return Container(
      padding: EdgeInsets.only(top: topPadding),
      height: _fixedHeaderHeight + topPadding,
      child: Center(
        child: usePadding
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: child,
              )
            : child,
      ),
    );
  }
}
