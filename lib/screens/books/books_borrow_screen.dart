import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/user_book.dart';
import '../../providers/library_provider.dart';
import '../../widgets/book/book_grid.dart';
import '../../widgets/book/book_detail_bottom_sheet.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/animated_background.dart';
import '../book_search_screen.dart';

class BooksBorrowScreen extends ConsumerStatefulWidget {
  const BooksBorrowScreen({super.key});

  @override
  ConsumerState<BooksBorrowScreen> createState() => _BooksBorrowScreenState();
}

class _BooksBorrowScreenState extends ConsumerState<BooksBorrowScreen> {
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
      return libraryNotifier.getBooksBorrow();
    }

    return libraryNotifier.searchInCategory(BookType.borrow, _searchQuery);
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
      body: Stack(
        children: [
          const AnimatedBackground(),
          SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Back button and title
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back),
                            onPressed: () => Navigator.pop(context),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            '빌린 책',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w300,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${filteredBooks.length}권',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w300,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Add book button
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const BookSearchScreen(),
                            ),
                          ).then((_) => _refreshBooks());
                        },
                        child: GlassContainer(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.add,
                                color: Color(0xFF7C5CBF),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                '책 추가하기',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF7C5CBF),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Search bar
                      GlassContainer(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (value) {
                            setState(() {
                              _searchQuery = value;
                            });
                          },
                          decoration: InputDecoration(
                            hintText: '제목이나 저자로 검색...',
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w300,
                              color: Colors.black.withValues(alpha: 0.4),
                            ),
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear,
                                      color: Colors.black.withValues(alpha: 0.5),
                                    ),
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() {
                                        _searchQuery = '';
                                      });
                                    },
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Book grid
                Expanded(
                  child: RefreshIndicator(
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
                Icons.auto_stories_outlined,
                size: 64,
                color: Colors.black.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty ? '빌린 책이 없습니다' : '검색 결과가 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty ? '빌린 책을 추가해보세요!' : '다른 검색어를 시도해보세요',
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
