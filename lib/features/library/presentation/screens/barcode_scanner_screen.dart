import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/library/data/models/book_search.dart';
import 'package:snippet_app/features/library/library_providers.dart';
import 'package:snippet_app/features/library/presentation/widgets/add_book_bottom_sheet.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );

  bool _isSearching = false;
  bool _hasDetected = false;
  String? _errorMessage;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isSearching || _hasDetected) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    final isbn = barcode.rawValue!;
    // ISBN-13 또는 ISBN-10만 처리
    if (isbn.length != 13 && isbn.length != 10) return;

    setState(() {
      _isSearching = true;
      _hasDetected = true;
      _errorMessage = null;
    });

    HapticFeedback.mediumImpact();
    await _controller.stop();

    try {
      final searchUseCase = ref.read(searchBooksUseCaseProvider);
      final result = await searchUseCase(isbn, 1);

      result.when(
        success: (books) {
          if (!mounted) return;

          if (books.isEmpty) {
            setState(() {
              _isSearching = false;
              _errorMessage = '해당 ISBN의 책을 찾을 수 없습니다';
            });
            return;
          }

          _showAddBottomSheet(books.first);
        },
        failure: (error) {
          if (!mounted) return;
          setState(() {
            _isSearching = false;
            _errorMessage = '책 정보를 불러오지 못했습니다';
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isSearching = false;
        _errorMessage = '오류가 발생했습니다';
      });
    }
  }

  void _showAddBottomSheet(BookSearchDto book) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AddBookBottomSheet(book: book),
    ).then((_) {
      if (mounted) {
        // 시트 닫힌 후 다시 스캔 가능하도록
        setState(() {
          _isSearching = false;
          _hasDetected = false;
          _errorMessage = null;
        });
        _controller.start();
      }
    });
  }

  void _resetScan() {
    setState(() {
      _isSearching = false;
      _hasDetected = false;
      _errorMessage = null;
    });
    _controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 카메라 뷰
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),

          // 스캔 오버레이
          _ScanOverlay(isSearching: _isSearching),

          // 상단 앱바
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                    color: Colors.white,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Spacer(),
                  Text(
                    '바코드 스캔',
                    style: AppTypography.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  // 손전등 토글
                  IconButton(
                    icon: ValueListenableBuilder(
                      valueListenable: _controller,
                      builder: (_, value, __) => Icon(
                        value.torchState == TorchState.on
                            ? Icons.flash_on_rounded
                            : Icons.flash_off_rounded,
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => _controller.toggleTorch(),
                  ),
                ],
              ),
            ),
          ),

          // 하단 안내 + 상태
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                left: 24,
                right: 24,
                top: 24,
                bottom: MediaQuery.of(context).padding.bottom + 32,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.85),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_isSearching) ...[
                    const SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '책 정보를 검색하는 중...',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ] else if (_errorMessage != null) ...[
                    const Icon(
                      Icons.error_outline_rounded,
                      color: DesignTokens.errorMain,
                      size: 28,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _errorMessage!,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _resetScan,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 10,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            DesignTokens.radiusFull,
                          ),
                        ),
                      ),
                      child: const Text('다시 스캔'),
                    ),
                  ] else ...[
                    Text(
                      '책 뒷면의 바코드를 프레임 안에 맞춰주세요',
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white.withValues(alpha: 0.8),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Scan Frame Overlay
// ============================================================================
class _ScanOverlay extends StatelessWidget {
  final bool isSearching;

  const _ScanOverlay({required this.isSearching});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _ScanFramePainter(isSearching: isSearching),
      child: const SizedBox.expand(),
    );
  }
}

class _ScanFramePainter extends CustomPainter {
  final bool isSearching;

  _ScanFramePainter({required this.isSearching});

  @override
  void paint(Canvas canvas, Size size) {
    // 어두운 오버레이
    final overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.55);

    // 스캔 프레임 영역 (가로로 넓은 직사각형 - 바코드용)
    const frameWidth = 280.0;
    const frameHeight = 140.0;
    final frameLeft = (size.width - frameWidth) / 2;
    final frameTop = (size.height - frameHeight) / 2 - 40;
    final frameRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(frameLeft, frameTop, frameWidth, frameHeight),
      const Radius.circular(12),
    );

    // 전체를 어둡게 칠하고 프레임 영역만 투명하게
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(frameRect)
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, overlayPaint);

    // 프레임 테두리
    final framePaint = Paint()
      ..color = isSearching
          ? DesignTokens.successMain
          : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    canvas.drawRRect(frameRect, framePaint);

    // 네 모서리 강조선
    final cornerPaint = Paint()
      ..color = isSearching
          ? DesignTokens.successMain
          : Colors.white
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 4;

    const cornerLen = 20.0;
    final fl = frameLeft;
    final ft = frameTop;
    final fr = frameLeft + frameWidth;
    final fb = frameTop + frameHeight;

    // 좌상
    canvas.drawLine(Offset(fl, ft + cornerLen), Offset(fl, ft), cornerPaint);
    canvas.drawLine(Offset(fl, ft), Offset(fl + cornerLen, ft), cornerPaint);
    // 우상
    canvas.drawLine(Offset(fr - cornerLen, ft), Offset(fr, ft), cornerPaint);
    canvas.drawLine(Offset(fr, ft), Offset(fr, ft + cornerLen), cornerPaint);
    // 좌하
    canvas.drawLine(Offset(fl, fb - cornerLen), Offset(fl, fb), cornerPaint);
    canvas.drawLine(Offset(fl, fb), Offset(fl + cornerLen, fb), cornerPaint);
    // 우하
    canvas.drawLine(Offset(fr - cornerLen, fb), Offset(fr, fb), cornerPaint);
    canvas.drawLine(Offset(fr, fb), Offset(fr, fb - cornerLen), cornerPaint);
  }

  @override
  bool shouldRepaint(_ScanFramePainter old) => old.isSearching != isSearching;
}
