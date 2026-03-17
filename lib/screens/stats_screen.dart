import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';
import '../widgets/glass_container.dart';
import '../widgets/stats/monthly_chart.dart';
import '../widgets/stats/yearly_summary.dart';
import '../widgets/stats/category_breakdown.dart';
import '../widgets/stats/insights_card.dart';
import '../core/design_tokens.dart';
import '../components/app_app_bar.dart';

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
      body: Column(
        children: [
          // Year Selector
          Container(
            color: const Color(0xFFF0F0F5),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: GlassContainer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: () {
                      statsNotifier.setSelectedYear(
                        statsState.selectedYear - 1,
                      );
                    },
                  ),
                  Text(
                    '${statsState.selectedYear}년',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 1,
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.chevron_right,
                      color: statsState.selectedYear == DateTime.now().year
                          ? Colors.grey.withValues(alpha: 0.3)
                          : null,
                    ),
                    onPressed: statsState.selectedYear == DateTime.now().year
                        ? null
                        : () {
                            statsNotifier.setSelectedYear(
                              statsState.selectedYear + 1,
                            );
                          },
                  ),
                ],
              ),
            ),
          ),

          // Type Tabs
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
                  Tab(text: '월별'),
                  Tab(text: '연도별'),
                  Tab(text: '카테고리'),
                  Tab(text: '인사이트'),
                ],
              ),
            ),
          ),

          // Content
          Expanded(
            child: RefreshIndicator(
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
        ],
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
