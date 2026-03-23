import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/app_tab_bar.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/components/search_field.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/presentation/providers/library_provider.dart';
import 'package:snippet_app/features/library/presentation/providers/library_tab_provider.dart';
import 'package:snippet_app/features/library/presentation/widgets/book_grid_card.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => LibraryScreenState();
}

class LibraryScreenState extends ConsumerState<LibraryScreen>
    with TickerProviderStateMixin {
  // ============================================================================
  // Constants
  // ============================================================================
  static const int _tabCount = 3;
  static const double _fixedHeaderHeight = 64.0;
  static const double _scrollContextSwitchThreshold = 50.0;
  static const double _tabAnimationThreshold = 0.1;
  static const double _swipeDetectionThreshold = 0.05;

  static const _bookTypes = [
    BookType.have,
    BookType.borrow,
    BookType.wish,
  ];

  // ============================================================================
  // State
  // ============================================================================
  late TabController _tabController;
  late List<AnimationController> _scrollAnimationControllers;

  // TextEditingController는 로컬 유지 (dispose 필요)
  late List<TextEditingController> _searchControllers;

  // ============================================================================
  // Lifecycle
  // ============================================================================
  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupTabListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryProvider.notifier).loadAllBooks();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var controller in _scrollAnimationControllers) {
      controller.dispose();
    }
    for (var controller in _searchControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // ============================================================================
  // Initialization
  // ============================================================================
  void _initializeControllers() {
    _tabController = TabController(length: _tabCount, vsync: this);

    _scrollAnimationControllers = List.generate(
      _tabCount,
      (_) => AnimationController(
        duration: Duration.zero,
        vsync: this,
      )..addListener(() => setState(() {})),
    );

    _searchControllers = List.generate(_tabCount, (_) => TextEditingController());

    // Provider 상태와 TextController 동기화
    for (int i = 0; i < _tabCount; i++) {
      _searchControllers[i].addListener(() {
        ref.read(libraryTabProvider.notifier).setSearchQuery(
          i,
          _searchControllers[i].text,
        );
      });
    }
  }

  void _setupTabListeners() {
    _tabController.addListener(() => setState(() {}));
    _tabController.animation!.addListener(_handleTabSwipe);
  }

  void _handleTabSwipe() {
    final animationValue = _tabController.animation!.value;
    final currentTab = _tabController.index;
    final tabState = ref.read(libraryTabProvider);

    if (animationValue.abs() > _swipeDetectionThreshold) {
      if (_scrollAnimationControllers[currentTab].value > 0) {
        _scrollAnimationControllers[currentTab].reset();
        ref.read(libraryTabProvider.notifier).setFixedHeaderVisible(currentTab, false);
        ref.read(libraryTabProvider.notifier).setScrollPosition(currentTab, 0.0);
        setState(() {});
      }
    }
  }

  // ============================================================================
  // Scroll Handling
  // ============================================================================
  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is! ScrollUpdateNotification) return false;

    final currentTab = _tabController.index;
    final tabState = ref.read(libraryTabProvider);
    final metrics = notification.metrics;
    final scrollDelta = notification.scrollDelta ?? 0;

    final pixels = metrics.pixels;
    final isScrollingDown = scrollDelta > 0;
    final lastScrollPixels = tabState.scrollPositions[currentTab] ?? 0.0;
    final isContextSwitch =
        (pixels - lastScrollPixels).abs() > _scrollContextSwitchThreshold;

    final topPadding = MediaQuery.of(context).padding.top;
    final triggerHeight = _fixedHeaderHeight + topPadding;

    const combinedHeaderHeight = kToolbarHeight + kTextTabBarHeight;
    final isInHeaderScroll = metrics.maxScrollExtent < combinedHeaderHeight + 50;

    if (isScrollingDown) {
      _handleScrollDown(currentTab, pixels, triggerHeight);
    } else {
      _handleScrollUp(
          currentTab, pixels, topPadding, isInHeaderScroll, isContextSwitch);
    }

    _syncHeaderAnimation(currentTab);
    ref.read(libraryTabProvider.notifier).setScrollPosition(currentTab, pixels);
    return false;
  }

  void _handleScrollDown(int tab, double pixels, double triggerHeight) {
    final tabState = ref.read(libraryTabProvider);

    if (pixels >= triggerHeight) {
      ref.read(libraryTabProvider.notifier).setFixedHeaderVisible(tab, true);
    }

    if ((tabState.showFixedHeaders[tab] ?? false) &&
        _scrollAnimationControllers[tab].value < 1.0) {
      _scrollAnimationControllers[tab].forward();
    }
  }

  void _handleScrollUp(
    int tab,
    double pixels,
    double topPadding,
    bool isInHeaderScroll,
    bool isContextSwitch,
  ) {
    final tabState = ref.read(libraryTabProvider);

    if (isInHeaderScroll &&
        !isContextSwitch &&
        pixels < topPadding + _fixedHeaderHeight) {
      ref.read(libraryTabProvider.notifier).setFixedHeaderVisible(tab, false);
      if (_scrollAnimationControllers[tab].value > 0.0) {
        _scrollAnimationControllers[tab].reverse();
      }
    }
  }

  void _syncHeaderAnimation(int tab) {
    final tabState = ref.read(libraryTabProvider);

    if (!(tabState.showFixedHeaders[tab] ?? false) &&
        _scrollAnimationControllers[tab].value > 0.0) {
      _scrollAnimationControllers[tab].reverse();
    }
  }

  // ============================================================================
  // Build
  // ============================================================================
  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final currentTab = _tabController.index;
    final isScrolled = _isHeaderScrolled(currentTab);

    return Stack(
      children: [
        _buildMainContent(isScrolled),
        _buildFixedHeaders(currentTab, topPadding, isScrolled),
      ],
    );
  }

  Widget _buildMainContent(bool isScrolled) {
    final headerOpacity = isScrolled ? 0.0 : 1.0;

    return NotificationListener<ScrollNotification>(
      onNotification: _onScrollNotification,
      child: NestedScrollView(
        headerSliverBuilder: (context, _) => [
          AppAppBar.sliver(
            title: '서재',
            bottom: AppTabBar(
              controller: _tabController,
              tabs: const ['소장', '대출', '위시'],
              margin: EdgeInsets.zero,
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: List.generate(
            _tabCount,
            (index) => _buildTabContent(
              bookType: _bookTypes[index],
              tabIndex: index,
              headerOpacity: headerOpacity,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFixedHeaders(int currentTab, double topPadding, bool isScrolled) {
    if (!isScrolled) return const SizedBox.shrink();

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedOpacity(
        duration: Duration.zero,
        opacity: 1.0,
        child: _buildFixedSearchField(currentTab, topPadding),
      ),
    );
  }

  bool _isHeaderScrolled(int tab) {
    return _scrollAnimationControllers[tab].value >= 1.0 &&
        !_tabController.indexIsChanging &&
        (_tabController.animation!.value - tab).abs() < _tabAnimationThreshold;
  }

  Widget _buildFixedSearchField(int tabIndex, double topPadding) {
    return Container(
      padding: EdgeInsets.only(top: topPadding),
      height: _fixedHeaderHeight + topPadding,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SearchField(
            controller: _searchControllers[tabIndex],
            hintText: '제목이나 저자로 검색...',
            onChanged: (value) {
              ref.read(libraryTabProvider.notifier).setSearchQuery(tabIndex, value);
            },
            onClear: () {
              _searchControllers[tabIndex].clear();
              ref.read(libraryTabProvider.notifier).setSearchQuery(tabIndex, '');
            },
          ),
        ),
      ),
    );
  }

  // ============================================================================
  // Tab Content
  // ============================================================================
  Widget _buildTabContent({
    required BookType bookType,
    required int tabIndex,
    required double headerOpacity,
  }) {
    final libraryState = ref.watch(libraryProvider);
    final libraryNotifier = ref.read(libraryProvider.notifier);
    final tabState = ref.watch(libraryTabProvider);
    final searchQuery = tabState.searchQueries[tabIndex] ?? '';

    final filteredBooks = _getFilteredBooks(bookType, tabIndex);

    const emptyStates = {
      BookType.have: (
        icon: Icons.library_books_outlined,
        text: '소장한 책이 없습니다',
        subText: '첫 책을 추가해보세요!',
      ),
      BookType.borrow: (
        icon: Icons.auto_stories_outlined,
        text: '빌린 책이 없습니다',
        subText: '빌린 책을 추가해보세요!',
      ),
      BookType.wish: (
        icon: Icons.favorite_border,
        text: '위시리스트가 비어있습니다',
        subText: '읽고 싶은 책을 추가해보세요!',
      ),
    };

    final emptyState = emptyStates[bookType]!;

    return AppRefreshIndicator(
      onRefresh: () => libraryNotifier.loadAllBooks(),
      child: CustomScrollView(
        slivers: [
          // Conditional rendering with placeholder
          if (headerOpacity > 0)
            SliverToBoxAdapter(
              child: SizedBox(
                height: _fixedHeaderHeight,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SearchField(
                      controller: _searchControllers[tabIndex],
                      hintText: '제목이나 저자로 검색...',
                      onChanged: (value) {
                        ref.read(libraryTabProvider.notifier).setSearchQuery(tabIndex, value);
                      },
                      onClear: () {
                        _searchControllers[tabIndex].clear();
                        ref.read(libraryTabProvider.notifier).setSearchQuery(tabIndex, '');
                      },
                    ),
                  ),
                ),
              ),
            )
          else
            const SliverToBoxAdapter(
              child: SizedBox(height: 64),
            ),

          // Content
          if (filteredBooks.isEmpty && !libraryState.isLoading)
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildEmptyState(
                emptyState.icon,
                searchQuery.isEmpty
                    ? emptyState.text
                    : '검색 결과가 없습니다',
                searchQuery.isEmpty
                    ? emptyState.subText
                    : '다른 검색어를 시도해보세요',
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width < 600 ? 2 : 3,
                  childAspectRatio: 0.65,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 16,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index >= filteredBooks.length) {
                      return const SizedBox.shrink();
                    }
                    final book = filteredBooks[index];
                    return BookGridCard(
                      book: book,
                      onTap: () =>
                          context.push(AppRoutes.bookDetail, extra: book),
                    );
                  },
                  childCount: filteredBooks.length,
                ),
              ),
            ),

          if (libraryState.isLoading)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  List<UserBookDto> _getFilteredBooks(BookType bookType, int tabIndex) {
    final libraryNotifier = ref.read(libraryProvider.notifier);
    final tabState = ref.read(libraryTabProvider);
    final searchQuery = tabState.searchQueries[tabIndex] ?? '';

    if (searchQuery.isEmpty) {
      switch (bookType) {
        case BookType.have:
          return libraryNotifier.getBooksHave();
        case BookType.borrow:
          return libraryNotifier.getBooksBorrow();
        case BookType.wish:
          return libraryNotifier.getBooksWish();
        default:
          return [];
      }
    }

    return libraryNotifier.searchInCategory(bookType, searchQuery);
  }

  Widget _buildEmptyState(IconData icon, String text, String subText) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: Colors.black.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            text,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w300,
              color: Colors.black.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subText,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w300,
              color: Colors.black.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}
