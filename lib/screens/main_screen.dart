import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'snippet_screen.dart';
import 'dashboard_screen.dart';
import 'records_screen.dart';
import 'library_screen.dart';
import 'mypage_screen.dart';
import 'book_search_screen.dart';
import '../widgets/glass_bottom_nav.dart';

import '../core/design_tokens.dart';
import '../components/app_app_bar.dart';
import '../components/app_fab.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<ConsumerState<RecordsScreen>> _recordsKey = GlobalKey();

  List<Widget> get _pages => [
    const SnippetScreen(),
    const DashboardScreen(),
    RecordsScreen(key: _recordsKey),
    const LibraryScreen(),
    const MyPageScreen(),
  ];

  final List<String> _pageTitles = [
    'SNIPPET',
    '대시보드',
    '독서 기록',
    '서재',
    '프로필',
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
      body: IndexedStack(index: _currentIndex, children: _pages),
      floatingActionButton: _buildFab(),
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

  Widget? _buildFab() {
    switch (_currentIndex) {
      case 1: // 대시보드
        return AppFab(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const BookSearchScreen(),
              ),
            );
          },
        );
      case 2: // 기록
        return AppFab(
          onPressed: () {
            final recordsState = _recordsKey.currentState;
            if (recordsState != null && recordsState.mounted) {
              (recordsState as dynamic).showAddRecordSheet(context);
            }
          },
        );
      case 3: // 서재
        return AppFab(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const BookSearchScreen(),
              ),
            );
          },
          label: '책 추가',
          icon: Icons.add_rounded,
        );
      default:
        return null;
    }
  }
}
