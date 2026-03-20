import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/app_tab_bar.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/features/snippet/presentation/screens/home_screen.dart';
import 'package:snippet_app/features/snippet/presentation/screens/archive_screen.dart';

class SnippetScreen extends ConsumerStatefulWidget {
  const SnippetScreen({super.key});

  @override
  ConsumerState<SnippetScreen> createState() => _SnippetScreenState();
}

class _SnippetScreenState extends ConsumerState<SnippetScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) => [
        AppAppBar.sliver(
          title: 'SNIPPET',
          letterSpacing: DesignTokens.letterSpacingExtraWide,
          bottom: AppTabBar(
            controller: _tabController,
            tabs: const ['스와이프', '보관함'],
            margin: EdgeInsets.zero,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: const [HomeScreen(), ArchiveScreen()],
      ),
    );
  }
}
