import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/features/library/presentation/providers/library_provider.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/components/app_book_card.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/components/search_field.dart';
import 'package:snippet_app/components/section_header.dart';
import 'package:snippet_app/core/design_tokens.dart';

class DashboardLibrarySection extends ConsumerStatefulWidget {
  final double headerOpacity;
  final TextEditingController searchController;

  const DashboardLibrarySection({
    super.key,
    this.headerOpacity = 1.0,
    required this.searchController,
  });

  @override
  ConsumerState<DashboardLibrarySection> createState() =>
      _DashboardLibrarySectionState();
}

class _DashboardLibrarySectionState
    extends ConsumerState<DashboardLibrarySection> {
  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);
    final libraryNotifier = ref.read(libraryProvider.notifier);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.translucent,
      child: AppRefreshIndicator(
        onRefresh: () => libraryNotifier.refreshBooks(),
        child: CustomScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          slivers: [
          // Conditional rendering with placeholder
          if (widget.headerOpacity > 0)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 64,
                child: Center(
                  child: SearchField(
                    controller: widget.searchController,
                    hintText: '제목이나 저자로 검색...',
                    onChanged: (value) {
                      libraryNotifier.setSearchQuery(value);
                    },
                    onClear: () {
                      widget.searchController.clear();
                      libraryNotifier.setSearchQuery('');
                    },
                  ),
                ),
              ),
            )
          else
            // 빈 공간으로 높이 유지 (부드러운 스크롤)
            const SliverToBoxAdapter(child: SizedBox(height: 64)),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (libraryNotifier.recentBooks.isNotEmpty) ...[
                  const SectionHeader('최근 추가', size: SectionHeaderSize.small),
                  const SizedBox(height: 8),
                  _buildBookList(libraryNotifier.recentBooks),
                  const SizedBox(height: 16),
                ],
                if (libraryNotifier.readingBooks.isNotEmpty) ...[
                  const SectionHeader('읽고 있는 책', size: SectionHeaderSize.small),
                  const SizedBox(height: 8),
                  _buildBookList(libraryNotifier.readingBooks),
                  const SizedBox(height: 16),
                ],
                if (libraryNotifier.completedBooks.isNotEmpty) ...[
                  const SectionHeader('완독한 책', size: SectionHeaderSize.small),
                  const SizedBox(height: 8),
                  _buildBookList(libraryNotifier.completedBooks),
                  const SizedBox(height: 16),
                ],
                if (libraryNotifier.borrowedBooks.isNotEmpty) ...[
                  const SectionHeader('빌린 책', size: SectionHeaderSize.small),
                  const SizedBox(height: 8),
                  _buildBookList(libraryNotifier.borrowedBooks),
                  const SizedBox(height: 16),
                ],
                if (libraryNotifier.wishlistBooks.isNotEmpty) ...[
                  const SectionHeader('위시리스트', size: SectionHeaderSize.small),
                  const SizedBox(height: 8),
                  _buildBookList(libraryNotifier.wishlistBooks),
                  const SizedBox(height: 16),
                ],
                if (libraryState.allBooks.isEmpty && !libraryState.isLoading)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 48),
                        Icon(
                          Icons.library_books_outlined,
                          size: 64,
                          color: Colors.black.withValues(alpha: 0.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '아직 책이 없습니다',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: Colors.black.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '첫 책을 추가해보세요!',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w300,
                            color: Colors.black.withValues(alpha: 0.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (libraryState.isLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(DesignTokens.space32),
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    ),
    );
  }

  Widget _buildBookList(List<UserBookDto> books) {
    return Column(
      children: books.take(5).map((book) => _buildBookCard(book)).toList(),
    );
  }

  Widget _buildBookCard(UserBookDto book) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: AppBookCard(
        book: book,
        size: BookCardSize.small,
        showProgress: true,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        onTap: () {
          context.push(AppRoutes.bookDetail, extra: book);
        },
      ),
    );
  }
}
