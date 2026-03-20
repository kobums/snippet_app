import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/widgets/glass_bottom_nav.dart';
import 'package:snippet_app/components/app_fab.dart';
import 'package:snippet_app/app/router.dart';

class MainScreen extends StatelessWidget {
  final Widget child;

  const MainScreen({super.key, required this.child});

  static const _tabRoutes = [
    AppRoutes.snippet,
    AppRoutes.dashboard,
    AppRoutes.records,
    AppRoutes.library,
    AppRoutes.profile,
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    for (int i = 0; i < _tabRoutes.length; i++) {
      if (location.startsWith(_tabRoutes[i])) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final index = _currentIndex(context);

    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: false,
      body: child,
      floatingActionButton: _buildFab(context, index),
      bottomNavigationBar: GlassBottomNav(
        currentIndex: index,
        onTap: (i) {
          if (i != index) {
            context.go(_tabRoutes[i]);
          }
        },
      ),
    );
  }

  Widget? _buildFab(BuildContext context, int index) {
    switch (index) {
      case 1: // 대시보드
        return AppFab(
          onPressed: () => context.push(AppRoutes.bookSearch),
        );
      case 3: // 서재
        return AppFab(
          onPressed: () => context.push(AppRoutes.bookSearch),
          label: '책 추가',
          icon: Icons.add_rounded,
        );
      default:
        return null;
    }
  }
}
