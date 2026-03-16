import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dashboard/dashboard_stats_section.dart';
import '../widgets/dashboard/dashboard_progress_section.dart';
import '../widgets/dashboard/dashboard_library_section.dart';
import '../core/design_tokens.dart';
import '../widgets/glass_container.dart';

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
        Container(
          margin: const EdgeInsets.symmetric(
            horizontal: DesignTokens.space16,
            vertical: DesignTokens.space8,
          ),
          child: GlassContainer(
            child: TabBar(
              controller: _tabController,
              labelColor: DesignTokens.primaryMain,
              unselectedLabelColor: DesignTokens.textTertiary,
              indicatorColor: DesignTokens.primaryMain,
              indicatorWeight: 2,
              dividerHeight: 0,
              labelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              unselectedLabelStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w300,
              ),
              tabs: const [
                Tab(text: '통계'),
                Tab(text: '진행'),
                Tab(text: '서재'),
              ],
            ),
          ),
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
