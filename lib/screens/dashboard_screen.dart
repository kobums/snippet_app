import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dashboard/dashboard_stats_section.dart';
import '../widgets/dashboard/dashboard_progress_section.dart';
import '../widgets/dashboard/dashboard_library_section.dart';
import '../components/app_tab_bar.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // TabBar
        AppTabBar(
          controller: _tabController,
          tabs: const ['통계', '진행', '서재'],
          margin: EdgeInsets.zero,
        ),
        // TabBarView
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: const [
              DashboardStatsSection(), // Tab 1: 통계
              DashboardProgressSection(), // Tab 2: 진행
              DashboardLibrarySection(), // Tab 3: 서재
            ],
          ),
        ),
      ],
    );
  }
}
