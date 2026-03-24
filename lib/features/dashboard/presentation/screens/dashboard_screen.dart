import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_stats_section.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_progress_section.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_library_section.dart';
import 'package:snippet_app/components/app_tab_bar.dart';
import 'package:snippet_app/components/month_navigator.dart';
import 'package:snippet_app/components/search_field.dart';
import 'package:snippet_app/features/library/presentation/providers/library_provider.dart';
import 'package:snippet_app/components/app_segmented_button.dart';
import 'package:snippet_app/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:snippet_app/features/dashboard/presentation/providers/dashboard_stats_provider.dart';

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
  static const double _swipeDetectionThreshold = 0.05;
  static const List<String> _progressSegments = ['대기중', '읽는중', '완독'];

  // ============================================================================
  // State
  // ============================================================================
  late TabController _tabController;
  late List<AnimationController> _scrollAnimationControllers;
  late ScrollController _outerScrollController;

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
    _outerScrollController.dispose();
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
    _outerScrollController = ScrollController();

    // 각 탭마다 독립적인 애니메이션 컨트롤러 생성 (즉시 반영)
    _scrollAnimationControllers = List.generate(
      _tabCount,
      (_) =>
          AnimationController(duration: Duration.zero, vsync: this)
            ..addListener(() => setState(() {})),
    );
  }

  void _setupTabListeners() {
    // 탭 클릭 시 도착 탭의 고정 헤더 리셋
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        final newTab = _tabController.index;
        if (_scrollAnimationControllers[newTab].value > 0) {
          _scrollAnimationControllers[newTab].reset();
          ref
              .read(dashboardProvider.notifier)
              .setFixedHeaderVisible(newTab, false);
        }
      }
      setState(() {});
    });

    // 스와이프 감지 및 헤더 리셋
    _tabController.animation!.addListener(_handleTabSwipe);
  }

  void _handleTabSwipe() {
    final animationValue = _tabController.animation!.value;
    final currentTab = _tabController.index;

    // 스와이프 시작 감지 시 현재 탭의 고정 헤더 즉시 리셋
    if ((animationValue - currentTab).abs() > _swipeDetectionThreshold) {
      if (_scrollAnimationControllers[currentTab].value > 0) {
        _scrollAnimationControllers[currentTab].reset();
        ref
            .read(dashboardProvider.notifier)
            .setFixedHeaderVisible(currentTab, false);
        ref.read(dashboardProvider.notifier).setScrollPosition(currentTab, 0.0);
        setState(() {});
      }
    }
  }

  // ============================================================================
  // Scroll Handling
  // ============================================================================
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;

    // 탭 전환 중 스크롤 알림 무시 (탭 전환 시 스크롤 복원으로 인한 헤더 깜빡임 방지)
    if (_tabController.indexIsChanging) return false;

    final currentTab = _tabController.index;
    final dashState = ref.read(dashboardProvider);
    final metrics = notification.metrics;
    final scrollDelta = notification.scrollDelta ?? 0;

    final pixels = metrics.pixels;
    final isScrollingDown = scrollDelta > 0;
    final lastScrollPixels = dashState.scrollPositions[currentTab] ?? 0.0;
    final isContextSwitch =
        (pixels - lastScrollPixels).abs() > _scrollContextSwitchThreshold;

    final topPadding = MediaQuery.of(context).padding.top;
    final triggerHeight = _fixedHeaderHeight + topPadding;

    // 탭 전환 직후 스크롤 위치 점프는 위치만 갱신하고 헤더 로직 건너뜀
    if (isContextSwitch) {
      ref
          .read(dashboardProvider.notifier)
          .setScrollPosition(currentTab, pixels);
      return false;
    }

    if (isScrollingDown) {
      _handleScrollDown(currentTab, pixels, triggerHeight);
    } else {
      _handleScrollUp(currentTab);
    }

    // 헤더 표시 상태와 애니메이션 동기화
    _syncHeaderAnimation(currentTab);

    ref.read(dashboardProvider.notifier).setScrollPosition(currentTab, pixels);
    return false;
  }

  void _handleScrollDown(int tab, double pixels, double triggerHeight) {
    final dashState = ref.read(dashboardProvider);

    if (pixels >= triggerHeight) {
      ref.read(dashboardProvider.notifier).setFixedHeaderVisible(tab, true);
    }

    if ((dashState.showFixedHeaders[tab] ?? false) &&
        _scrollAnimationControllers[tab].value < 1.0) {
      _scrollAnimationControllers[tab].forward();
    }
  }

  void _handleScrollUp(int tab) {
    if (!_outerScrollController.hasClients) return;

    final outerPixels = _outerScrollController.position.pixels;
    final outerMax = _outerScrollController.position.maxScrollExtent;

    // outer scroll이 펼쳐지기 시작하면 (AppBar가 다시 보이면) 고정 헤더 숨김
    if (outerPixels < (outerMax - 50)) {
      ref.read(dashboardProvider.notifier).setFixedHeaderVisible(tab, false);
      if (_scrollAnimationControllers[tab].value > 0.0) {
        _scrollAnimationControllers[tab].reverse();
      }
    }
  }

  void _syncHeaderAnimation(int tab) {
    final dashState = ref.read(dashboardProvider);

    if (!(dashState.showFixedHeaders[tab] ?? false) &&
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
        controller: _outerScrollController,
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

  Widget _buildFixedHeaders(
    int currentTab,
    double topPadding,
    bool isScrolled,
  ) {
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
    // 탭 변경 중이면 고정 헤더 숨김
    if (_tabController.indexIsChanging) return false;

    final animValue = _tabController.animation!.value;
    final nearestTab = animValue.round();

    // 스와이프 중(탭 인덱스에 안착하지 않은 상태)이면 고정 헤더 숨김
    if ((animValue - nearestTab).abs() > 0.001) return false;

    // 현재 탭이 아니면 고정 헤더 숨김
    if (nearestTab != tab) return false;

    // 스크롤 애니메이션 값이 1.0 이상이면 고정 헤더 표시
    return _scrollAnimationControllers[tab].value >= 1.0;
  }

  // ============================================================================
  // Fixed Header Builders
  // ============================================================================
  Widget _buildFixedMonthNavigator(double topPadding) {
    final statsState = ref.watch(dashboardStatsProvider);
    final statsNotifier = ref.read(dashboardStatsProvider.notifier);
    final now = DateTime.now();
    final isCurrentMonth =
        statsState.selectedYear == now.year &&
        statsState.selectedMonth == now.month;

    return _buildFixedHeaderContainer(
      topPadding: topPadding,
      child: MonthNavigator(
        year: statsState.selectedYear,
        month: statsState.selectedMonth,
        isCurrentMonth: isCurrentMonth,
        onMonthChanged: statsNotifier.setSelectedMonth,
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
      // usePadding: true,
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
