import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'records_screen.dart';
import 'archive_screen.dart';
import 'book_search_screen.dart';
import '../widgets/glass_bottom_nav.dart';
import '../widgets/app_drawer.dart';
import '../core/design_tokens.dart';
import '../components/app_app_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ConsumerState<RecordsScreen>> _recordsKey = GlobalKey();

  List<Widget> get _pages => [
    const HomeScreen(),
    const DashboardScreen(),
    RecordsScreen(key: _recordsKey),
    const ArchiveScreen(),
  ];

  final List<String> _pageTitles = [
    'SNIPPET',
    '대시보드',
    '독서 기록',
    '보관함',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        title: _pageTitles[_currentIndex],
        letterSpacing: _currentIndex == 0
            ? DesignTokens.letterSpacingExtraWide
            : DesignTokens.letterSpacingWide,
      ),
      extendBody: false,
      drawer: const AppDrawer(),
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: (_currentIndex == 1 || _currentIndex == 2)
        ? FloatingActionButton(
            onPressed: () {
              if (_currentIndex == 1) {
                // Dashboard tab - Navigate to BookSearchScreen
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const BookSearchScreen(),
                  ),
                );
              } else if (_currentIndex == 2) {
                // Records tab - Show AddRecordBottomSheet
                final recordsState = _recordsKey.currentState;
                if (recordsState != null && recordsState.mounted) {
                  (recordsState as dynamic).showAddRecordSheet(context);
                }
              }
            },
            backgroundColor: DesignTokens.primaryMain,
            child: const Icon(Icons.add, color: Colors.white),
          )
        : null,
      bottomNavigationBar: GlassBottomNav(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
