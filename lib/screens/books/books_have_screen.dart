import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/app_refresh_indicator.dart';
import '../../models/user_book.dart';
import '../../providers/library_provider.dart';
import '../../widgets/book/book_grid.dart';
import '../../widgets/book/book_detail_bottom_sheet.dart';
import '../book_search_screen.dart';
import '../../components/app_app_bar.dart';
import '../../components/app_fab.dart';
import '../../components/search_field.dart';
import '../../core/design_tokens.dart';

class BooksHaveScreen extends ConsumerStatefulWidget {
  const BooksHaveScreen({super.key});

  @override
  ConsumerState<BooksHaveScreen> createState() => _BooksHaveScreenState();
}

class _BooksHaveScreenState extends ConsumerState<BooksHaveScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(libraryProvider.notifier).loadAllBooks();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserBookDto> _getFilteredBooks() {
    final libraryNotifier = ref.read(libraryProvider.notifier);

    if (_searchQuery.isEmpty) {
      return libraryNotifier.getBooksHave();
    }

    return libraryNotifier.searchInCategory(BookType.have, _searchQuery);
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        title: '소장한 책',
        letterSpacing: 1.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${filteredBooks.length}권',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: DesignTokens.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AppFab(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const BookSearchScreen()),
          ).then((_) => _refreshBooks());
        },
        label: '책 추가',
        icon: Icons.add_rounded,
      ),
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search bar
                SearchField(
                  controller: _searchController,
                  hintText: '제목이나 저자로 검색...',
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Book grid
          Expanded(
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
          ),
        ],
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
                Icons.library_books_outlined,
                size: 64,
                color: Colors.black.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty ? '소장한 책이 없습니다' : '검색 결과가 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty ? '첫 책을 추가해보세요!' : '다른 검색어를 시도해보세요',
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
