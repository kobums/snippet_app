import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart' show Share, XFile;
import 'package:snippet_app/core/app_colors.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/records/data/models/record.dart';

class NotesExportSection extends StatefulWidget {
  final RecordDto record;
  const NotesExportSection({super.key, required this.record});

  @override
  State<NotesExportSection> createState() => _NotesExportSectionState();
}

class _NotesExportSectionState extends State<NotesExportSection> {
  final _screenshotController = ScreenshotController();
  final _pageController = PageController();
  final _shareButtonKey = GlobalKey();

  bool _isSharing = false;
  int _currentPage = 0;

  // 페이지 분할 결과 캐시
  List<String>? _cachedPages;
  double? _cachedCardW;

  // ── 레이아웃 상수 (논리 px) ──────────────────────────────────────────────────
  static const double _lineH = 26.0;
  static const double _bodyHPad = 20.0;
  static const double _bodyVPad = 14.0;
  static const double _firstHdrH =
      14 + 22 + 12 + 65 + 13.0; // badge/date+title+divider
  static const double _contHdrH = 10 + 20 + 10 + 13.0; // mini header+divider
  static const double _footerH = 1 + 10 + 14 + 16.0; // divider+icon row

  List<String> _getPages(double cardW) {
    if (_cachedCardW != cardW) {
      _cachedPages = _splitIntoPages(widget.record.text, cardW);
      _cachedCardW = cardW;
    }
    return _cachedPages!;
  }

  static int _maxLines(double cardW, bool isFirst) {
    final bodyH =
        cardW * 5 / 4 -
        (isFirst ? _firstHdrH : _contHdrH) -
        _footerH -
        _bodyVPad * 2;
    return (bodyH / _lineH).floor().clamp(1, 999);
  }

  static int _charsPerPage(String text, double bodyW, int maxLines) {
    const textStyle = TextStyle(fontSize: 15.0, height: _lineH / 15.0, letterSpacing: -0.1);
    const strutStyle = StrutStyle(
      fontSize: 15.0,
      height: _lineH / 15.0,
      forceStrutHeight: true,
    );

    bool fits(int len) {
      final p = TextPainter(
        text: TextSpan(text: text.substring(0, len), style: textStyle),
        textDirection: TextDirection.ltr,
        maxLines: maxLines,
        strutStyle: strutStyle,
      )..layout(maxWidth: bodyW);
      return !p.didExceedMaxLines;
    }

    if (fits(text.length)) return text.length;

    int lo = 0, hi = text.length;
    while (lo < hi) {
      final mid = (lo + hi + 1) ~/ 2;
      fits(mid) ? lo = mid : hi = mid - 1;
    }
    return lo;
  }

  static List<String> _splitIntoPages(String text, double cardW) {
    if (text.isEmpty) return [text];
    final bodyW = cardW - _bodyHPad * 2;
    final pages = <String>[];
    String remaining = text;
    bool isFirst = true;

    while (remaining.isNotEmpty) {
      final n = _charsPerPage(remaining, bodyW, _maxLines(cardW, isFirst));
      if (n >= remaining.length) {
        pages.add(remaining);
        break;
      }
      int cut = n;
      if (cut < remaining.length) {
        final lastNL = remaining.lastIndexOf('\n', cut);
        final lastSP = remaining.lastIndexOf(' ', cut);
        final boundary = lastNL > lastSP ? lastNL : lastSP;
        if (boundary > 0) cut = boundary;
      }
      pages.add(remaining.substring(0, cut).trimRight());
      remaining = remaining.substring(cut).trimLeft();
      isFirst = false;
    }

    return pages.isEmpty ? [text] : pages;
  }

  Future<void> _export(List<String> pages, double cardW, bool isDark) async {
    final box =
        _shareButtonKey.currentContext?.findRenderObject() as RenderBox?;
    final origin = box != null
        ? box.localToGlobal(Offset.zero) & box.size
        : Rect.fromLTWH(0, MediaQuery.of(context).size.height / 2, 1, 1);
    final captureContext = context;

    setState(() => _isSharing = true);
    try {
      final dir = await getTemporaryDirectory();
      final ts = DateTime.now().millisecondsSinceEpoch;
      final files = <XFile>[];

      for (int i = 0; i < pages.length; i++) {
        final bytes = await _screenshotController.captureFromWidget(
          SizedBox(
            width: cardW,
            child: AspectRatio(
              aspectRatio: 4 / 5,
              child: _NotesPageCard(
                record: widget.record,
                bodyText: pages[i],
                isDark: isDark,
                isFirstPage: i == 0,
                pageIndex: i,
                totalPages: pages.length,
              ),
            ),
          ),
          pixelRatio: 3.0,
          context: captureContext,
        );

        final path = '${dir.path}/notes_${ts}_${i + 1}.png';
        await File(path).writeAsBytes(bytes);
        files.add(XFile(path));
      }

      await Share.shareXFiles(files, sharePositionOrigin: origin);
    } finally {
      if (mounted) setState(() => _isSharing = false);
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.isDark;
    final cardW = MediaQuery.of(context).size.width - DesignTokens.space24 * 2;
    final pages = _getPages(cardW);
    final cardH = cardW * 5 / 4;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 헤더
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '메모 이미지',
                  style: AppTypography.h4.copyWith(
                    color: context.colors.textPrimary,
                  ),
                ),
                if (pages.length > 1)
                  Text(
                    '총 ${pages.length}장',
                    style: AppTypography.captionSmall.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
              ],
            ),
          ],
        ),
        const SizedBox(height: DesignTokens.space16),

        // 좌우 스크롤 미리보기
        SizedBox(
          height: cardH,
          child: PageView.builder(
            controller: _pageController,
            itemCount: pages.length,
            onPageChanged: (i) => setState(() => _currentPage = i),
            itemBuilder: (_, i) => _NotesPageCard(
              record: widget.record,
              bodyText: pages[i],
              isDark: isDark,
              isFirstPage: i == 0,
              pageIndex: i,
              totalPages: pages.length,
            ),
          ),
        ),

        // 페이지 도트
        if (pages.length > 1) ...[
          const SizedBox(height: DesignTokens.space12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(pages.length, (i) {
              final active = i == _currentPage;
              return GestureDetector(
                onTap: () => _pageController.animateToPage(
                  i,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: active ? 16 : 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    color: active
                        ? context.colors.primary
                        : context.colors.border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
        const SizedBox(height: DesignTokens.space20),

        // 내보내기 버튼
        _isSharing
            ? const Center(child: CircularProgressIndicator())
            : SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: _shareButtonKey,
                  onPressed: () => _export(pages, cardW, isDark),
                  icon: const Icon(Icons.ios_share_rounded),
                  label: Text(
                    pages.length > 1 ? '${pages.length}장으로 내보내기' : '이미지로 내보내기',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: context.colors.primary,
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.space16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        DesignTokens.radiusMd,
                      ),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}

// ── 4:5 단일 페이지 카드 ──────────────────────────────────────────────────────

class _NotesPageCard extends StatelessWidget {
  final RecordDto record;
  final String bodyText;
  final bool isDark;
  final bool isFirstPage;
  final int pageIndex;
  final int totalPages;

  static const Color _yellow = Color(0xFFFFCC00);
  static const Color _yellowLabel = Color(0xFF8B6914);

  const _NotesPageCard({
    required this.record,
    required this.bodyText,
    required this.isDark,
    required this.isFirstPage,
    required this.pageIndex,
    required this.totalPages,
  });

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.year}년 ${d.month}월 ${d.day}일';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? const Color(0xFF1C1C1E) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1C1C1E);
    final textSecondary = isDark
        ? const Color(0xFF8E8E93)
        : const Color(0xFF6C6C70);
    final dividerColor = isDark
        ? const Color(0xFF38383A)
        : const Color(0xFFE5E5EA);
    final lineColor = isDark
        ? const Color(0xFF252527)
        : const Color(0xFFF0F0F5);

    return ClipRect(
      child: Container(
        color: bg,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            if (isFirstPage) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: _yellow.withValues(alpha: 0.18),
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
            ] else ...[
              // 이어지는 페이지: 미니 헤더
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        record.bookTitle,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: textPrimary,
                          letterSpacing: -0.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${pageIndex + 1} / $totalPages',
                      style: TextStyle(fontSize: 11, color: textSecondary),
                    ),
                  ],
                ),
              ),
            ],

            // 구분선
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Divider(color: dividerColor, height: 1, thickness: 1),
            ),

            // 본문 (남은 공간 채움)
            Expanded(
              child: _RuledBody(
                text: bodyText,
                textColor: textPrimary,
                lineColor: lineColor,
              ),
            ),

            // 하단 구분선
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: Divider(color: dividerColor, height: 1, thickness: 1),
            ),

            // 푸터: 페이지 번호 + 아이콘 + 앱 이름
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ColorFiltered(
                    colorFilter: ColorFilter.mode(
                      textSecondary,
                      BlendMode.srcIn,
                    ),
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
            ),
          ],
        ),
      ),
    );
  }
}

// ── 줄지어진 본문 ─────────────────────────────────────────────────────────────

class _RuledBody extends StatelessWidget {
  final String text;
  final Color textColor;
  final Color lineColor;

  static const double _lineH = 26.0;
  static const double _fontSize = 15.0;
  static const double _hPad = 20.0;
  static const double _vPad = 14.0;

  const _RuledBody({
    required this.text,
    required this.textColor,
    required this.lineColor,
  });

  // 선을 텍스트 descender 바로 아래에 맞추기 위한 오프셋
  // lineH 박스 하단 기준으로 halfLeading만큼 위로 올림
  static const double _lineOffset = (_lineH - _fontSize) * 0.45; // ≈ 5.0

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _LinedPaperPainter(lineColor: lineColor),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_hPad, _vPad, _hPad, _vPad),
        child: SizedBox(
          width: double.infinity,
          child: Text(
            text,
            style: const TextStyle(
              fontSize: _fontSize,
              height: _lineH / _fontSize,
              letterSpacing: -0.1,
            ).copyWith(color: textColor),
            strutStyle: const StrutStyle(
              fontSize: _fontSize,
              height: _lineH / _fontSize,
              forceStrutHeight: true, // 폰트 메트릭 무관하게 정확히 26px 고정 → drift 제거
            ),
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
    // 선을 박스 하단이 아닌 descender 직후(_lineOffset만큼 위로)에 그림
    double y = _RuledBody._vPad + _RuledBody._lineH - _RuledBody._lineOffset;
    while (y < size.height - _RuledBody._vPad / 2) {
      canvas.drawLine(
        Offset(_RuledBody._hPad, y),
        Offset(size.width - _RuledBody._hPad, y),
        paint,
      );
      y += _RuledBody._lineH;
    }
  }

  @override
  bool shouldRepaint(_LinedPaperPainter old) => old.lineColor != lineColor;
}
