import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/components/app_refresh_indicator.dart';
import 'package:snippet_app/features/library/presentation/providers/book_provider.dart';
import 'package:snippet_app/features/library/data/models/user_book.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/components/app_book_card.dart';
import 'package:snippet_app/core/design_tokens.dart';

class DashboardProgressSection extends ConsumerStatefulWidget {
  final double headerOpacity;

  const DashboardProgressSection({super.key, this.headerOpacity = 1.0});

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
          // Conditional rendering with placeholder
          if (widget.headerOpacity > 0)
            SliverToBoxAdapter(
              child: SizedBox(
                height: 64,
                child: Center(
                  child: _buildSegmentedButton(),
                ),
              ),
            )
          else
            // 빈 공간으로 높이 유지 (부드러운 스크롤)
            const SliverToBoxAdapter(
              child: SizedBox(height: 64),
            ),
          _buildBookListSliver(currentTabBooks),
        ],
      ),
    );
  }

  Widget _buildSegmentedButton() {
    const segments = ['대기중', '읽는중', '완독'];

    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: DesignTokens.neutral100,
          borderRadius: BorderRadius.circular(DesignTokens.radiusMd),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: List.generate(segments.length, (index) {
            final isSelected = index == _selectedIndex;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedIndex = index;
                  });
                  final controller = PrimaryScrollController.of(context);
                  if (controller.hasClients) {
                    controller.jumpTo(0);
                  }
                },
                child: AnimatedContainer(
                  duration: DesignTokens.durationNormal,
                  curve: DesignTokens.curveEaseInOut,
                  decoration: isSelected
                      ? BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusSm,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        )
                      : null,
                  alignment: Alignment.center,
                  child: AnimatedDefaultTextStyle(
                    duration: DesignTokens.durationNormal,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected
                          ? FontWeight.w500
                          : FontWeight.w400,
                      color: isSelected
                          ? DesignTokens.textPrimary
                          : DesignTokens.textTertiary,
                    ),
                    child: Text(segments[index]),
                  ),
                ),
              ),
            );
          }),
        ),
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
      child: AppBookCard(
        book: book,
        size: BookCardSize.large,
        showProgress: true,
        onTap: () {
          context.push(AppRoutes.bookDetail, extra: book);
        },
      ),
    );
  }
}
