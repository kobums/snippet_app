import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/presentation/providers/library_provider.dart';
import 'package:snippet_app/features/library/presentation/widgets/book_grid.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/app_fab.dart';
import 'package:snippet_app/components/search_field.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/typography.dart';

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
    context.push(AppRoutes.bookDetail, extra: book);
  }

  Future<void> _refreshBooks() async {
    await ref.read(libraryProvider.notifier).loadAllBooks();
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);
    final filteredBooks = _getFilteredBooks();

    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: AppAppBar(
        title: '빌린 책',
        letterSpacing: 1.5,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(
              child: Text(
                '${filteredBooks.length}권',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w300,
                  color: context.colors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: AppFab(
        onPressed: () {
          context.push(AppRoutes.bookSearch).then((_) => _refreshBooks());
        },
        label: '책 추가',
        icon: Icons.add_rounded,
      ),
      body: SearchableScrollLayout(
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
                  onStatusChange: (book, status) => ref
                      .read(libraryProvider.notifier)
                      .updateBookStatus(book.id, status),
                ),
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
                Icons.auto_stories_outlined,
                size: 64,
                color: context.colors.textDisabled,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isEmpty ? '빌린 책이 없습니다' : '검색 결과가 없습니다',
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.w300,
                  color: context.colors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isEmpty ? '빌린 책을 추가해보세요!' : '다른 검색어를 시도해보세요',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w300,
                  color: context.colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
