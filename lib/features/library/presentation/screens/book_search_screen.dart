import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:snippet_app/features/library/data/models/book_search.dart';
import 'package:snippet_app/features/library/presentation/providers/book_search_provider.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/features/library/presentation/widgets/add_book_bottom_sheet.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/search_field.dart';

class BookSearchScreen extends ConsumerStatefulWidget {
  const BookSearchScreen({super.key});

  @override
  ConsumerState<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends ConsumerState<BookSearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final searchState = ref.read(bookSearchProvider);
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.9) {
      if (!searchState.isLoadingMore &&
          searchState.results.length >= searchState.currentPage * 10) {
        ref.read(bookSearchProvider.notifier).loadMore();
      }
    }
  }

  void _showAddBookBottomSheet(BookSearchDto book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddBookBottomSheet(book: book),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const AppAppBar(title: '책 검색', letterSpacing: 2),
      body: SearchableScrollLayout(
        controller: _searchController,
        hintText: '책 제목이나 저자를 검색하세요',
        onChanged: (value) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (value == _searchController.text) {
              ref.read(bookSearchProvider.notifier).search(value);
            }
          });
        },
        onClear: () => ref.read(bookSearchProvider.notifier).clearSearch(),
        child: _buildResults(),
      ),
    );
  }

  Widget _buildResults() {
    final searchState = ref.watch(bookSearchProvider);

    if (searchState.isSearching) {
      return const Center(child: CircularProgressIndicator());
    }

    if (searchState.results.isEmpty && searchState.currentQuery.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: Colors.black.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              '책을 검색해보세요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    if (searchState.results.isEmpty && searchState.currentQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: Colors.black.withValues(alpha: 0.2),
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: Colors.black.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 64, left: 16, right: 16, bottom: 16),
      itemCount: searchState.results.length + (searchState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == searchState.results.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
        final book = searchState.results[index];
        return _buildBookCard(book);
      },
    );
  }

  Widget _buildBookCard(BookSearchDto book) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () => _showAddBookBottomSheet(book),
        child: GlassContainer(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: CachedNetworkImage(
                  imageUrl: book.coverUrl,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 90,
                    color: Colors.grey.withValues(alpha: 0.2),
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 90,
                    color: Colors.grey.withValues(alpha: 0.3),
                    child: Icon(
                      Icons.book,
                      color: Colors.grey.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w300,
                        color: Colors.black.withValues(alpha: 0.5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.publisher} · ${book.pubDate}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w300,
                        color: Colors.black.withValues(alpha: 0.4),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    // if (book.totalPage != null) ...[
                    //   const SizedBox(height: 4),
                    //   Text(
                    //     '${book.totalPage}쪽',
                    //     style: TextStyle(
                    //       fontSize: 12,
                    //       fontWeight: FontWeight.w300,
                    //       color: Colors.black.withValues(alpha: 0.4),
                    //     ),
                    //   ),
                    // ],
                  ],
                ),
              ),
              Icon(
                Icons.add_circle_outline,
                color: DesignTokens.primaryMain.withValues(alpha: 0.7),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
