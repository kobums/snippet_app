import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_stats_section.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_progress_section.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_library_section.dart';
import 'package:snippet_app/components/app_tab_bar.dart';
import 'package:snippet_app/components/month_navigator.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/components/search_field.dart';
import 'package:snippet_app/features/library/presentation/providers/library_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late List<AnimationController> _scrollAnimationControllers;

  // 스크롤 추적 변수 (각 탭별로 관리)
  final List<double> _lastPixels = [0.0, 0.0, 0.0];
  final List<bool> _hasShownNavigator = [false, false, false];

  // 1번 탭 (진행) SegmentedButton 상태
  int _selectedProgressIndex = 1;

  // 2번 탭 (서재) SearchField 상태
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // 각 탭마다 독립적인 AnimationController 생성
    _scrollAnimationControllers = List.generate(
      3,
      (index) =>
          AnimationController(
            duration: const Duration(milliseconds: 0),
            vsync: this,
          )..addListener(() {
            setState(() {});
          }),
    );

    _tabController.addListener(() {
      setState(() {});
    });

    // 스와이프 애니메이션 중에도 감지
    _tabController.animation!.addListener(() {
      final animationValue = _tabController.animation!.value;
      final currentTab = _tabController.index;

      // 현재 탭에서 스와이프 시작 시 즉시 리셋
      if (animationValue.abs() > 0.05) {
        if (_scrollAnimationControllers[currentTab].value > 0) {
          _scrollAnimationControllers[currentTab].reset();
          _hasShownNavigator[currentTab] = false;
          _lastPixels[currentTab] = 0.0;
          setState(() {});
        }
      }
    });
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

  bool _onScrollNotification(ScrollNotification notification) {
    final currentTab = _tabController.index;

    if (notification is ScrollUpdateNotification) {
      final pixels = notification.metrics.pixels;
      final scrollDelta = notification.scrollDelta ?? 0;
      final maxScrollExtent = notification.metrics.maxScrollExtent;

      // 스크롤 방향: 양수 = 아래로, 음수 = 위로
      final isScrollingDown = scrollDelta > 0;

      // Context 전환 감지 (pixels가 급격히 변함)
      final isContextSwitch = (pixels - _lastPixels[currentTab]).abs() > 50;

      // 기기별 동적 높이 계산
      final topPadding = MediaQuery.of(context).padding.top;
      const kHeaderHeight = 64.0;
      const appBarHeight = kToolbarHeight; // 56.0
      const tabBarHeight = kTextTabBarHeight; // 46.0
      const headerHeight = appBarHeight + tabBarHeight; // 102.0

      // Header/Body scroll 구분 (maxScrollExtent로 판단)
      final isInHeaderScroll = maxScrollExtent < headerHeight + 50;

      final fixedHeaderHeight = kHeaderHeight + topPadding;

      if (isScrollingDown) {
        // 아래로 스크롤 중
        if (pixels >= fixedHeaderHeight) {
          _hasShownNavigator[currentTab] = true;
        }
        // Context 전환이어도 이미 나타난 상태면 유지
        if (_hasShownNavigator[currentTab] &&
            _scrollAnimationControllers[currentTab].value < 1.0) {
          _scrollAnimationControllers[currentTab].forward();
        }
      } else {
        // 위로 스크롤 중
        if (isInHeaderScroll &&
            !isContextSwitch &&
            pixels < topPadding + kHeaderHeight) {
          _hasShownNavigator[currentTab] = false;
          if (_scrollAnimationControllers[currentTab].value > 0.0) {
            _scrollAnimationControllers[currentTab].reverse();
          }
        }
      }

      // 나타나지 않은 상태에서 숨김 처리
      if (!_hasShownNavigator[currentTab] &&
          _scrollAnimationControllers[currentTab].value > 0.0) {
        _scrollAnimationControllers[currentTab].reverse();
      }

      _lastPixels[currentTab] = pixels;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final currentTab = _tabController.index;

    // 완전히 전환되었을 때만 true (탭 스와이프 중이 아닐 때)
    final isScrolled =
        _scrollAnimationControllers[currentTab].value >= 1.0 &&
        !_tabController.indexIsChanging &&
        (_tabController.animation!.value - currentTab).abs() < 0.1;

    return Stack(
      children: [
        // 메인 NestedScrollView
        NotificationListener<ScrollNotification>(
          onNotification: _onScrollNotification,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) => [
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
                DashboardStatsSection(headerOpacity: isScrolled ? 0.0 : 1.0),
                DashboardProgressSection(headerOpacity: isScrolled ? 0.0 : 1.0),
                DashboardLibrarySection(headerOpacity: isScrolled ? 0.0 : 1.0),
              ],
            ),
          ),
        ),

        // 상단 고정 헤더들 (각 탭별로)
        if (currentTab == 0 && isScrolled)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 0),
                opacity: 1.0,
                child: _buildFixedMonthNavigator(topPadding),
              ),
            ),
          ),

        if (currentTab == 1 && isScrolled)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 0),
                opacity: 1.0,
                child: _buildFixedSegmentedButton(topPadding),
              ),
            ),
          ),

        if (currentTab == 2 && isScrolled)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: false,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 0),
                opacity: 1.0,
                child: _buildFixedSearchField(topPadding),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildFixedMonthNavigator(double topPadding) {
    final bookState = ref.watch(bookProvider);
    final bookNotifier = ref.read(bookProvider.notifier);

    final now = DateTime.now();
    final isCurrentMonth =
        bookState.selectedYear == now.year &&
        bookState.selectedMonth == now.month;

    return Container(
      padding: EdgeInsets.only(top: topPadding),
      height: 64 + topPadding,
      child: Center(
        child: MonthNavigator(
          year: bookState.selectedYear,
          month: bookState.selectedMonth,
          isCurrentMonth: isCurrentMonth,
          onMonthChanged: (year, month) {
            bookNotifier.setSelectedMonth(year, month);
          },
        ),
      ),
    );
  }

  Widget _buildFixedSegmentedButton(double topPadding) {
    const segments = ['대기중', '읽는중', '완독'];

    return Container(
      padding: EdgeInsets.only(top: topPadding),
      height: 64 + topPadding,
      alignment: Alignment.center,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: DesignTokens.neutral100,
            borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(
            children: List.generate(segments.length, (index) {
              final isSelected = index == _selectedProgressIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedProgressIndex = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: DesignTokens.durationNormal,
                    curve: DesignTokens.curveEaseInOut,
                    decoration: isSelected
                        ? BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              DesignTokens.radiusSm,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          )
                        : null,
                    alignment: Alignment.center,
                    child: AnimatedDefaultTextStyle(
                      duration: DesignTokens.durationNormal,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: isSelected
                            ? FontWeight.w500
                            : FontWeight.w400,
                        color: isSelected
                            ? DesignTokens.textPrimary
                            : DesignTokens.textTertiary,
                      ),
                      child: Text(segments[index]),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedSearchField(double topPadding) {
    final libraryNotifier = ref.read(libraryProvider.notifier);

    return Container(
      padding: EdgeInsets.only(top: topPadding),
      height: 64 + topPadding,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchField(
            controller: _searchController,
            hintText: '제목이나 저자로 검색...',
            onChanged: (value) {
              libraryNotifier.setSearchQuery(value);
            },
            onClear: () {
              _searchController.clear();
              libraryNotifier.setSearchQuery('');
            },
          ),
        ),
      ),
    );
  }
}
