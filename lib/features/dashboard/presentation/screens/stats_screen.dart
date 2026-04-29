import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_tab_bar.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/features/dashboard/presentation/providers/stats_provider.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/monthly_chart.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/yearly_summary.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/category_breakdown.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/insights_card.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/year_navigator.dart';
import 'package:snippet_app/core/design_tokens.dart';

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
      backgroundColor: context.colors.surface,
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
                  context.colors.divider,
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
          onRefresh: () => statsNotifier.loadAllStats(),
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildContent(
                statsState.isLoading,
                statsState.error?.toString(),
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(DesignTokens.space16),
                  child: Column(
                    children: [
                      GlassContainer(
                        child: MonthlyChart(stats: statsState.monthlyStats),
                      ),
                    ],
                  ),
                ),
              ),
              _buildContent(
                statsState.isLoading,
                statsState.error?.toString(),
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(DesignTokens.space16),
                  child: YearlySummary(stats: statsState.yearlyStats),
                ),
              ),
              _buildContent(
                statsState.isLoading,
                statsState.error?.toString(),
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(DesignTokens.space16),
                  child: CategoryBreakdown(stats: statsState.categoryStats),
                ),
              ),
              _buildContent(
                statsState.isLoading,
                statsState.error?.toString(),
                SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(DesignTokens.space16),
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
          padding: const EdgeInsets.all(DesignTokens.space32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: context.colors.textDisabled,
              ),
              const SizedBox(height: 16),
              Text(
                error,
                style: AppTypography.bodyMedium.copyWith(
                  color: context.colors.textSecondary,
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
