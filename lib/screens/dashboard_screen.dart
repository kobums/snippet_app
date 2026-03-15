import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/dashboard/dashboard_stats_section.dart';
import '../widgets/dashboard/dashboard_progress_section.dart';
import '../widgets/dashboard/dashboard_library_section.dart';
import 'book_search_screen.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '대시보드',
          style: TextStyle(
            fontWeight: FontWeight.w300,
            letterSpacing: 2,
          ),
        ),
        backgroundColor: const Color(0xFFF0F0F5),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF7C5CBF),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF7C5CBF),
          indicatorWeight: 3,
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
      body: TabBarView(
        controller: _tabController,
        children: const [
          DashboardStatsSection(),     // Tab 1: 통계
          DashboardProgressSection(),  // Tab 2: 진행
          DashboardLibrarySection(),   // Tab 3: 서재
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const BookSearchScreen()),
          );
        },
        backgroundColor: const Color(0xFF7C5CBF),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
