import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_stats_section.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_progress_section.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_library_section.dart';
import 'package:snippet_app/components/app_tab_bar.dart';
import 'package:snippet_app/components/month_navigator.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _scrollAnimationController;

  // 스크롤 추적 변수
  double _lastPixels = 0.0;
  bool _hasShownNavigator = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollAnimationController =
        AnimationController(
          duration: const Duration(milliseconds: 0),
          vsync: this,
        )..addListener(() {
          setState(() {});
        });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollAnimationController.dispose();
    super.dispose();
  }

  bool _onScrollNotification(ScrollNotification notification) {
    // 0번 탭(통계)일 때만 처리
    if (_tabController.index != 0) {
      // 다른 탭으로 이동 시 상태 초기화
      _hasShownNavigator = false;
      _lastPixels = 0.0;
      return false;
    }

    if (notification is ScrollUpdateNotification) {
      final pixels = notification.metrics.pixels;
      final scrollDelta = notification.scrollDelta ?? 0;

      // 스크롤 방향: 양수 = 아래로, 음수 = 위로
      final isScrollingDown = scrollDelta > 0;

      // Context 전환 감지 (pixels가 급격히 변함)
      final isContextSwitch = (pixels - _lastPixels).abs() > 50;

      const double monthNavigatorHeight = 104;

      if (isScrollingDown) {
        // 아래로 스크롤 중
        if (pixels >= monthNavigatorHeight) {
          // 64px 이상 스크롤됨 → 나타남
          _hasShownNavigator = true;
        }
        // Context 전환이어도 이미 나타난 상태면 유지
        if (_hasShownNavigator && _scrollAnimationController.value < 1.0) {
          _scrollAnimationController.forward();
        }
      } else {
        // 위로 스크롤 중
        // Context 전환이 아니고, 최상단에 가까워지면 사라짐
        if (!isContextSwitch && pixels < 10) {
          _hasShownNavigator = false;
          if (_scrollAnimationController.value > 0.0) {
            _scrollAnimationController.reverse();
          }
        }
      }

      // 나타나지 않은 상태에서 숨김 처리
      if (!_hasShownNavigator && _scrollAnimationController.value > 0.0) {
        _scrollAnimationController.reverse();
      }

      _lastPixels = pixels;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    // 완전히 전환되었을 때만 true (0.3 threshold 대신)
    final isScrolled = _scrollAnimationController.value >= 1.0;

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
                const DashboardProgressSection(),
                const DashboardLibrarySection(),
              ],
            ),
          ),
        ),

        // 상단 고정 MonthNavigator (스크롤 시 나타남)
        if (_tabController.index == 0)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: IgnorePointer(
              ignoring: !isScrolled,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 0),
                opacity: isScrolled ? 1.0 : 0.0,
                child: _buildFixedMonthNavigator(topPadding),
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
}
