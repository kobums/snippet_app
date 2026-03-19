import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_tab_bar.dart';
import '../components/app_refresh_indicator.dart';
import '../providers/stats_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/stats/monthly_chart.dart';
import '../widgets/stats/yearly_summary.dart';
import '../widgets/stats/category_breakdown.dart';
import '../widgets/stats/insights_card.dart';
import '../core/design_tokens.dart';
import '../components/app_app_bar.dart';
import '../components/year_navigator.dart';

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(statsProvider);
    final statsNotifier = ref.read(statsProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        title: '통계',
        letterSpacing: 2,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.05),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverToBoxAdapter(
            child: AppTabBar(
              controller: _tabController,
              tabs: const ['월별', '연도별', '카테고리', '인사이트'],
              margin: EdgeInsets.zero,
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyYearNavigator(
              year: statsState.selectedYear,
              isCurrentYear: statsState.selectedYear == DateTime.now().year,
              onYearChanged: (year) => statsNotifier.setSelectedYear(year),
              height: 64,
            ),
          ),
        ],
        body: AppRefreshIndicator(
          onRefresh: () => statsNotifier.refreshStats(),
          child: TabBarView(
            controller: _tabController,
            children: [
              // Monthly tab
              _buildContent(
                statsState.isLoading,
                statsState.error,
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      GlassContainer(
                        child: MonthlyChart(stats: statsState.monthlyStats),
                      ),
                    ],
                  ),
                ),
              ),

              // Yearly tab
              _buildContent(
                statsState.isLoading,
                statsState.error,
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: YearlySummary(stats: statsState.yearlyStats),
                ),
              ),

              // Category tab
              _buildContent(
                statsState.isLoading,
                statsState.error,
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: CategoryBreakdown(stats: statsState.categoryStats),
                ),
              ),

              // Insights tab
              _buildContent(
                statsState.isLoading,
                statsState.error,
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  child: InsightsCard(insights: statsState.insights),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(bool isLoading, String? error, Widget content) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.black.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return content;
  }
}
