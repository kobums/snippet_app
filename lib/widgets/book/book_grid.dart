import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/user_book.dart';
import 'book_grid_card.dart';

class BookGrid extends StatelessWidget {
  final List<UserBookDto> books;
  final bool loading;
  final Function(UserBookDto) onBookTap;

  const BookGrid({
    super.key,
    required this.books,
    required this.loading,
    required this.onBookTap,
  });

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return _buildLoadingGrid(context);
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    return GridView.builder(
      padding: const EdgeInsets.only(top: 64, left: 16, right: 16, bottom: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: books.length,
      itemBuilder: (context, index) {
        return BookGridCard(
          book: books[index],
          onTap: () => onBookTap(books[index]),
        );
      },
    );
  }

  Widget _buildLoadingGrid(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 2 : 3;

    return GridView.builder(
      padding: const EdgeInsets.only(top: 64, left: 16, right: 16, bottom: 16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 16,
      ),
      itemCount: 6, // Show 6 skeleton cards
      itemBuilder: (context, index) {
        return _buildSkeletonCard();
      },
    );
  }

  Widget _buildSkeletonCard() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.withValues(alpha: 0.3),
      highlightColor: Colors.grey.withValues(alpha: 0.1),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
