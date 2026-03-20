import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/features/library/presentation/providers/library_provider.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/widgets/layout/bottom_nav_layout.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/components/app_book_card.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/components/search_field.dart';
import 'package:snippet_app/components/section_header.dart';

class DashboardLibrarySection extends ConsumerStatefulWidget {
  const DashboardLibrarySection({super.key});

  @override
  ConsumerState<DashboardLibrarySection> createState() =>
      _DashboardLibrarySectionState();
}

class _DashboardLibrarySectionState
    extends ConsumerState<DashboardLibrarySection> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final libraryState = ref.watch(libraryProvider);
    final libraryNotifier = ref.read(libraryProvider.notifier);

    return AppRefreshIndicator(
      onRefresh: () => libraryNotifier.refreshBooks(),
      child: SearchableScrollLayout(
        controller: _searchController,
        hintText: '제목이나 저자로 검색...',
        onChanged: (value) {
          libraryNotifier.setSearchQuery(value);
        },
        child: BottomNavLayout(
          hasFloatingActionButton: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 64),
              if (libraryNotifier.recentBooks.isNotEmpty) ...[
                const SectionHeader(
                  '최근 추가',
                  size: SectionHeaderSize.small,
                  padding: EdgeInsets.only(left: 8.0),
                ),
                const SizedBox(height: 8),
                _buildBookList(libraryNotifier.recentBooks),
                const SizedBox(height: 16),
              ],
              if (libraryNotifier.readingBooks.isNotEmpty) ...[
                const SectionHeader(
                  '읽고 있는 책',
                  size: SectionHeaderSize.small,
                  padding: EdgeInsets.only(left: 8.0),
                ),
                const SizedBox(height: 8),
                _buildBookList(libraryNotifier.readingBooks),
                const SizedBox(height: 16),
              ],
              if (libraryNotifier.borrowedBooks.isNotEmpty) ...[
                const SectionHeader(
                  '빌린 책',
                  size: SectionHeaderSize.small,
                  padding: EdgeInsets.only(left: 8.0),
                ),
                const SizedBox(height: 8),
                _buildBookList(libraryNotifier.borrowedBooks),
                const SizedBox(height: 16),
              ],
              if (libraryNotifier.wishlistBooks.isNotEmpty) ...[
                const SectionHeader(
                  '위시리스트',
                  size: SectionHeaderSize.small,
                  padding: EdgeInsets.only(left: 8.0),
                ),
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
                    padding: EdgeInsets.all(32.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
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
