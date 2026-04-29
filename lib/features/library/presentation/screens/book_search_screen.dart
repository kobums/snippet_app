import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:snippet_app/features/library/data/models/book_search.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/features/library/presentation/providers/book_search_provider.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/features/library/presentation/widgets/add_book_bottom_sheet.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/search_field.dart';

class BookSearchScreen extends ConsumerStatefulWidget {
  final BookType? initialBookType;

  const BookSearchScreen({super.key, this.initialBookType});

  @override
  ConsumerState<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends ConsumerState<BookSearchScreen> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  final _searchFocusNode = FocusNode();
  BookSearchNotifier? _searchNotifier;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _searchNotifier = ref.read(bookSearchProvider.notifier);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _searchFocusNode.dispose();
    Future(() => _searchNotifier?.clearSearch());
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

  void _showAddBookBottomSheet(BookSearchDto book) async {
    // 키보드 내리기
    _searchFocusNode.unfocus();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddBookBottomSheet(
        book: book,
        initialBookType: widget.initialBookType,
      ),
    );

    // BottomSheet 닫힌 후에도 키보드가 올라오지 않도록 focus 제거
    if (mounted) {
      _searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.surface,
      appBar: const AppAppBar(title: '책 검색', letterSpacing: 2),
      body: SearchableScrollLayout(
        controller: _searchController,
        focusNode: _searchFocusNode,
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
            Icon(Icons.search, size: 64, color: context.colors.textDisabled),
            const SizedBox(height: 16),
            Text(
              '책을 검색해보세요',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w300,
                color: context.colors.textSecondary,
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
              color: context.colors.textDisabled,
            ),
            const SizedBox(height: 16),
            Text(
              '검색 결과가 없습니다',
              style: AppTypography.bodyLarge.copyWith(
                fontWeight: FontWeight.w300,
                color: context.colors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 64, left: 16, right: 16, bottom: 16),
      itemCount:
          searchState.results.length + (searchState.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == searchState.results.length) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(DesignTokens.space16),
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
                borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
                child: CachedNetworkImage(
                  imageUrl: book.coverUrl,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    width: 60,
                    height: 90,
                    color: context.colors.surfaceSecondary,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    width: 60,
                    height: 90,
                    color: context.colors.border,
                    child: Icon(
                      Icons.book,
                      color: context.colors.iconSecondary,
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
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w400,
                        color: context.colors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.author,
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w300,
                        color: context.colors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.publisher} · ${book.pubDate}',
                      style: AppTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w300,
                        color: context.colors.textTertiary,
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
                color: context.colors.primary.withValues(alpha: 0.7),
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
