import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/app_tab_bar.dart';
import '../components/app_refresh_indicator.dart';
import '../components/search_field.dart';
import '../models/user_book.dart';
import '../providers/library_provider.dart';
import '../widgets/book/book_grid.dart';
import '../widgets/book/book_detail_bottom_sheet.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => LibraryScreenState();
}

class LibraryScreenState extends ConsumerState<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryProvider.notifier).loadAllBooks();
    });
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
        SliverToBoxAdapter(
          child: AppTabBar(
            controller: _tabController,
            tabs: const ['소장', '대출', '위시'],
            margin: EdgeInsets.zero,
          ),
        ),
      ],
      body: TabBarView(
        controller: _tabController,
        children: const [
          _LibraryTabContent(
            bookType: BookType.have,
            emptyIcon: Icons.library_books_outlined,
            emptyText: '소장한 책이 없습니다',
            emptySubText: '첫 책을 추가해보세요!',
          ),
          _LibraryTabContent(
            bookType: BookType.borrow,
            emptyIcon: Icons.auto_stories_outlined,
            emptyText: '빌린 책이 없습니다',
            emptySubText: '빌린 책을 추가해보세요!',
          ),
          _LibraryTabContent(
            bookType: BookType.wish,
            emptyIcon: Icons.favorite_border,
            emptyText: '위시리스트가 비어있습니다',
            emptySubText: '읽고 싶은 책을 추가해보세요!',
          ),
        ],
      ),
    );
  }
}

class _LibraryTabContent extends ConsumerStatefulWidget {
  final BookType bookType;
  final IconData emptyIcon;
  final String emptyText;
  final String emptySubText;

  const _LibraryTabContent({
    required this.bookType,
    required this.emptyIcon,
    required this.emptyText,
    required this.emptySubText,
  });

  @override
  ConsumerState<_LibraryTabContent> createState() =>
      _LibraryTabContentState();
}

class _LibraryTabContentState extends ConsumerState<_LibraryTabContent> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserBookDto> _getFilteredBooks() {
    final libraryNotifier = ref.read(libraryProvider.notifier);

    if (_searchQuery.isEmpty) {
      switch (widget.bookType) {
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

    return libraryNotifier.searchInCategory(widget.bookType, _searchQuery);
  }

  void _openBookDetail(UserBookDto book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BookDetailBottomSheet(book: book),
    );
  }

  Future<void> _refreshBooks() async {
    await ref.read(libraryProvider.notifier).loadAllBooks();
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);
    final filteredBooks = _getFilteredBooks();

    return SearchableScrollLayout(
      controller: _searchController,
      hintText: '제목이나 저자로 검색...',
      onChanged: (value) {
        setState(() {
          _searchQuery = value;
        });
      },
      child: AppRefreshIndicator(
        onRefresh: _refreshBooks,
        child: filteredBooks.isEmpty && !libraryState.isLoading
            ? _buildEmptyState()
            : BookGrid(
                books: filteredBooks,
                loading: libraryState.isLoading,
                onBookTap: _openBookDetail,
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.2),
        Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.emptyIcon,
                size: 64,
                color: Colors.black.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty ? widget.emptyText : '검색 결과가 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty ? widget.emptySubText : '다른 검색어를 시도해보세요',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w300,
                  color: Colors.black.withValues(alpha: 0.3),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
