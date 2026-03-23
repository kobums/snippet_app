import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_stats_section.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_progress_section.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/dashboard_library_section.dart';
import 'package:snippet_app/components/app_tab_bar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _scrollAnimationController;
  late Animation<double> _paddingAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _paddingAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _scrollAnimationController,
            curve: Curves.easeInOut,
          ),
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

  /// 스크롤 진행률을 출력하는 헬퍼 메서드
  // void _printScrollProgress(ScrollMetrics metrics) {
  //   final pixels = metrics.pixels;
  //   final maxScroll = metrics.maxScrollExtent;
  //   final minScroll = metrics.minScrollExtent;
  //   final viewportDimension = metrics.viewportDimension;

  //   // 스크롤 진행률 계산 (0.0 ~ 1.0)
  //   final progress = maxScroll > 0 ? (pixels / maxScroll).clamp(0.0, 1.0) : 0.0;
  //   final progressPercent = (progress * 100).toStringAsFixed(1);

  //   print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  //   print('📊 스크롤 진행률: $progressPercent%');
  //   print('📍 현재 위치: ${pixels.toStringAsFixed(1)}px');
  //   print('🔝 최소 위치: ${minScroll.toStringAsFixed(1)}px');
  //   print('🔽 최대 위치: ${maxScroll.toStringAsFixed(1)}px');
  //   print('📱 화면 높이: ${viewportDimension.toStringAsFixed(1)}px');
  //   print('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  // }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollUpdateNotification) {
      // 스크롤 진행률 출력
      // _printScrollProgress(notification.metrics);

      final shouldShow = notification.metrics.pixels > 0;
      if (shouldShow && _scrollAnimationController.value < 1.0) {
        _scrollAnimationController.forward();
      } else if (!shouldShow && _scrollAnimationController.value > 0.0) {
        _scrollAnimationController.reverse();
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
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
            DashboardStatsSection(paddingProgress: _paddingAnimation.value),
            const DashboardProgressSection(),
            const DashboardLibrarySection(),
          ],
        ),
      ),
    );
  }
}
