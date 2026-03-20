import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:snippet_app/widgets/glass_container.dart';
import 'package:snippet_app/features/library/presentation/widgets/book_detail_bottom_sheet.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/features/dashboard/presentation/widgets/sticky_glass_tab_bar.dart';

class DashboardProgressSection extends ConsumerStatefulWidget {
  const DashboardProgressSection({super.key});

  @override
  ConsumerState<DashboardProgressSection> createState() =>
      _DashboardProgressSectionState();
}

class _DashboardProgressSectionState
    extends ConsumerState<DashboardProgressSection> {
  int _selectedIndex = 1;

  List<UserBookDto> _getFilteredBooks(List<UserBookDto> books, int tabIndex) {
    switch (tabIndex) {
      case 0:
        return books.where((b) => b.status == BookStatus.waiting).toList();
      case 1:
        return books.where((b) => b.status == BookStatus.reading).toList();
      case 2:
        return books.where((b) => b.status == BookStatus.completed).toList();
      default:
        return books;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookState = ref.watch(bookProvider);
    final currentTabBooks = _getFilteredBooks(bookState.books, _selectedIndex);

    return AppRefreshIndicator(
      onRefresh: () => ref.read(bookProvider.notifier).refreshBooks(),
      child: CustomScrollView(
        slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: StickyGlassSegmentedButton(
              selectedIndex: _selectedIndex,
              segments: const ['대기중', '읽는중', '완독'],
              onChanged: (index) {
                setState(() {
                  _selectedIndex = index;
                });
                final controller = PrimaryScrollController.of(context);
                if (controller.hasClients) {
                  controller.jumpTo(0);
                }
              },
              height: 64,
            ),
          ),
          _buildBookListSliver(currentTabBooks),
        ],
      ),
    );
  }

  Widget _buildBookListSliver(List<UserBookDto> books) {
    if (books.isEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.book_outlined,
                size: 64,
                color: Colors.black.withValues(alpha: 0.2),
              ),
              const SizedBox(height: 16),
              Text(
                '책이 없습니다',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: Colors.black.withValues(alpha: 0.5),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8,
        bottom: 20,
      ),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) => _buildBookCard(books[index]),
          childCount: books.length,
        ),
      ),
    );
  }

  Widget _buildBookCard(UserBookDto book) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            useRootNavigator: true,
            backgroundColor: Colors.transparent,
            builder: (context) => BookDetailBottomSheet(book: book),
          );
        },
        child: GlassContainer(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  book.coverUrl,
                  width: 60,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 90,
                      color: Colors.grey.withValues(alpha: 0.3),
                      child: Icon(
                        Icons.book,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                    );
                  },
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
                    const SizedBox(height: 12),
                    if (book.status == BookStatus.reading)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: book.progress,
                              minHeight: 6,
                              backgroundColor: Colors.grey.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: const AlwaysStoppedAnimation<Color>(
                                DesignTokens.primaryMain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${book.readPage} / ${book.totalPage} 페이지 (${(book.progress * 100).toInt()}%)',
                            style: TextStyle(
                              fontSize: 12,
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
  }
}
