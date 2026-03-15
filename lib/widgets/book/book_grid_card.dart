import 'package:flutter/material.dart';
import '../../models/user_book.dart';
import '../glass_container.dart';

class BookGridCard extends StatelessWidget {
  final UserBookDto book;
  final VoidCallback onTap;

  const BookGridCard({
    super.key,
    required this.book,
    required this.onTap,
  });

  Color _getStatusColor(BookStatus status) {
    switch (status) {
      case BookStatus.waiting:
        return Colors.grey;
      case BookStatus.reading:
        return const Color(0xFF7C5CBF);
      case BookStatus.completed:
        return const Color(0xFF34C759);
      case BookStatus.dropped:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(BookStatus status) {
    switch (status) {
      case BookStatus.waiting:
        return '대기중';
      case BookStatus.reading:
        return '읽는중';
      case BookStatus.completed:
        return '완독';
      case BookStatus.dropped:
        return '중단';
      default:
        return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      book.coverUrl,
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: double.infinity,
                          color: Colors.grey.withValues(alpha: 0.3),
                          child: Icon(
                            Icons.book,
                            size: 48,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                        );
                      },
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(book.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getStatusText(book.status),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // Book title
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

            // Author
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

            // Progress bar (if reading)
            if (book.status == BookStatus.reading) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(3),
                child: LinearProgressIndicator(
                  value: book.progress,
                  minHeight: 4,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF7C5CBF),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${(book.progress * 100).toInt()}%',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w300,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
