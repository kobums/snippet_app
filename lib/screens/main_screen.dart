import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'dashboard_screen.dart';
import 'records_screen.dart';
import 'archive_screen.dart';
import '../widgets/animated_background.dart';
import '../widgets/glass_bottom_nav.dart';
import '../widgets/app_drawer.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomeScreen(),
    const DashboardScreen(),
    const RecordsScreen(),
    const ArchiveScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Enables glass effect for bottom nav
      drawer: const AppDrawer(),
      body: Stack(
        children: [
          const AnimatedBackground(),
          IndexedStack(
            index: _currentIndex,
            children: _pages,
          ),
        ],
      ),
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
