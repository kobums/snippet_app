import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/library_provider.dart';
import '../../models/user_book.dart';
import '../glass_container.dart';
import '../layout/bottom_nav_layout.dart';
import '../book/book_detail_bottom_sheet.dart';

class DashboardLibrarySection extends ConsumerWidget {
  const DashboardLibrarySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final libraryState = ref.watch(libraryProvider);
    final libraryNotifier = ref.read(libraryProvider.notifier);

    return BottomNavLayout(
      hasFloatingActionButton: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Search Bar
          _buildSearchBar(libraryState.searchQuery, libraryNotifier),
          const SizedBox(height: 16),

          // Recent Books Section
          if (libraryNotifier.recentBooks.isNotEmpty) ...[
            _buildSectionHeader('최근 추가'),
            const SizedBox(height: 8),
            _buildBookList(libraryNotifier.recentBooks),
            const SizedBox(height: 16),
          ],

          // Reading Books Section
          if (libraryNotifier.readingBooks.isNotEmpty) ...[
            _buildSectionHeader('읽고 있는 책'),
            const SizedBox(height: 8),
            _buildBookList(libraryNotifier.readingBooks),
            const SizedBox(height: 16),
          ],

          // Borrowed Books Section
          if (libraryNotifier.borrowedBooks.isNotEmpty) ...[
            _buildSectionHeader('빌린 책'),
            const SizedBox(height: 8),
            _buildBookList(libraryNotifier.borrowedBooks),
            const SizedBox(height: 16),
          ],

          // Wishlist Books Section
          if (libraryNotifier.wishlistBooks.isNotEmpty) ...[
            _buildSectionHeader('위시리스트'),
            const SizedBox(height: 8),
            _buildBookList(libraryNotifier.wishlistBooks),
            const SizedBox(height: 16),
          ],

          // Empty state
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

          // Loading state
          if (libraryState.isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(String query, LibraryNotifier notifier) {
    return GlassContainer(
      child: TextField(
        onChanged: (value) => notifier.setSearchQuery(value),
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
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          letterSpacing: 1,
          color: Colors.black.withValues(alpha: 0.6),
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
    return Builder(builder: (context) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: () {
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => BookDetailBottomSheet(book: book),
            );
          },
          child: GlassContainer(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Book cover
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Image.network(
                    book.coverUrl,
                    width: 45,
                    height: 68,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 45,
                        height: 68,
                        color: Colors.grey.withValues(alpha: 0.3),
                        child: Icon(
                          Icons.book,
                          size: 20,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Book info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.author,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w300,
                          color: Colors.black.withValues(alpha: 0.5),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),

                      // Progress (if reading)
                      if (book.status == BookStatus.reading)
                        Row(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: book.progress,
                                  minHeight: 4,
                                  backgroundColor:
                                      Colors.grey.withValues(alpha: 0.2),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                    Color(0xFF7C5CBF),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(book.progress * 100).toInt()}%',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w300,
                                color: Colors.black.withValues(alpha: 0.4),
                              ),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
