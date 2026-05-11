import 'package:flutter/material.dart';
import 'package:snippet_app/features/records/data/models/record.dart';

class NotesExportCard extends StatelessWidget {
  final RecordDto record;
  final bool isDark;

  static const Color _notesYellow = Color(0xFFFFCC00);
  static const Color _yellowLabel = Color(0xFF8B6914);
  static const Color _darkBg = Color(0xFF1C1C1E);
  static const Color _darkFooterBg = Color(0xFF2C2C2E);

  const NotesExportCard({super.key, required this.record, required this.isDark});

  String _formatDate(String isoDate) {
    try {
      final d = DateTime.parse(isoDate);
      return '${d.year}년 ${d.month}월 ${d.day}일';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? _darkBg : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final textSecondary = isDark ? const Color(0xFF8E8E93) : const Color(0xFF6C6C70);
    final divider = isDark ? const Color(0xFF38383A) : const Color(0xFFE5E5EA);
    final lineColor = isDark ? const Color(0xFF252527) : const Color(0xFFF0F0F5);
    final footerBg = isDark ? _darkFooterBg : const Color(0xFFF2F2F7);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Notes yellow accent bar
            Container(height: 4, color: _notesYellow),

            // Header: type badge + date
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _notesYellow.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      record.type.label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: _yellowLabel,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  Text(
                    _formatDate(record.createDate),
                    style: TextStyle(
                      fontSize: 11,
                      color: textSecondary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ],
              ),
            ),

            // Book title + author
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.bookTitle,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                      height: 1.2,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (record.bookAuthor.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                      record.bookAuthor,
                      style: TextStyle(
                        fontSize: 13,
                        color: textSecondary,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Divider
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Divider(color: divider, height: 1, thickness: 1),
            ),

            // Body text with ruled lines
            _RuledBody(text: record.text, textColor: textPrimary, lineColor: lineColor),

            // Divider
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Divider(color: divider, height: 1, thickness: 1),
            ),

            // Footer
            Container(
              color: footerBg,
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Row(
                children: [
                  if (record.tag != null && record.tag!.isNotEmpty) ...[
                    Text(
                      '#${record.tag}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: _yellowLabel,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 12, color: divider),
                    const SizedBox(width: 8),
                  ],
                  if (record.relatedPage != null) ...[
                    Text(
                      'p. ${record.relatedPage}',
                      style: TextStyle(fontSize: 12, color: textSecondary),
                    ),
                    const SizedBox(width: 8),
                    Container(width: 1, height: 12, color: divider),
                    const SizedBox(width: 8),
                  ],
                  const Spacer(),
                  // Snippet watermark
                  Row(
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(textSecondary, BlendMode.srcIn),
                        child: Image.asset(
                          'images/snippetbook-removebg.png',
                          width: 14,
                          height: 14,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'snippet',
                        style: TextStyle(
                          fontSize: 11,
                          color: textSecondary,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.4,
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
    );
  }
}

class _RuledBody extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color lineColor;

  static const double _lineHeight = 26.0;
  static const double _fontSize = 15.0;
  static const double _hPad = 20.0;
  static const double _vPad = 14.0;

  const _RuledBody({required this.text, required this.textColor, required this.lineColor});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinedPaperPainter(lineColor: lineColor),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_hPad, _vPad, _hPad, _vPad),
        child: Text(
          text,
          style: TextStyle(
            fontSize: _fontSize,
            height: _lineHeight / _fontSize,
            color: textColor,
            letterSpacing: -0.1,
          ),
        ),
      ),
    );
  }
}

class _LinedPaperPainter extends CustomPainter {
  final Color lineColor;
  const _LinedPaperPainter({required this.lineColor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = lineColor
      ..strokeWidth = 1.0;

    const topPad = _RuledBody._vPad;
    const step = _RuledBody._lineHeight;

    double y = topPad + step;
    while (y < size.height - topPad / 2) {
      canvas.drawLine(
        Offset(_RuledBody._hPad, y),
        Offset(size.width - _RuledBody._hPad, y),
        paint,
      );
      y += step;
    }
  }

  @override
  bool shouldRepaint(_LinedPaperPainter old) => old.lineColor != lineColor;
}
