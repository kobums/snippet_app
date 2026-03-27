import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/app_button.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:path_provider/path_provider.dart';

/// 형광펜 스트로크 데이터
class HighlighterStroke {
  final List<Offset> points;
  final Color color;
  final double width;

  HighlighterStroke({
    required this.points,
    required this.color,
    this.width = 20.0,
  });
}

/// 형광펜 드로잉을 위한 CustomPainter
class HighlighterPainter extends CustomPainter {
  final List<HighlighterStroke> strokes;

  HighlighterPainter(this.strokes);

  @override
  void paint(Canvas canvas, Size size) {
    for (final stroke in strokes) {
      if (stroke.points.isEmpty) continue;

      final paint = Paint()
        ..color = stroke.color
        ..strokeWidth = stroke.width
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < stroke.points.length - 1; i++) {
        canvas.drawLine(stroke.points[i], stroke.points[i + 1], paint);
      }
    }
  }

  @override
  bool shouldRepaint(HighlighterPainter oldDelegate) {
    return oldDelegate.strokes != strokes;
  }
}

class ImageHighlighterScreen extends StatefulWidget {
  final String imagePath;

  const ImageHighlighterScreen({super.key, required this.imagePath});

  @override
  State<ImageHighlighterScreen> createState() => _ImageHighlighterScreenState();
}

class _ImageHighlighterScreenState extends State<ImageHighlighterScreen> {
  final List<HighlighterStroke> _strokes = [];
  List<Offset> _currentStroke = [];
  final GlobalKey _imageKey = GlobalKey();

  // 형광펜 색상 (반투명 노란색)
  final Color _highlighterColor = Colors.yellow.withValues(alpha: 0.5);

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _currentStroke = [details.localPosition];
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _currentStroke.add(details.localPosition);
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      if (_currentStroke.isNotEmpty) {
        _strokes.add(HighlighterStroke(
          points: List.from(_currentStroke),
          color: _highlighterColor,
        ));
        _currentStroke = [];
      }
    });
  }

  void _clearAll() {
    setState(() {
      _strokes.clear();
      _currentStroke = [];
    });
  }

  Rect? _calculateBoundingBox() {
    if (_strokes.isEmpty) return null;

    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final stroke in _strokes) {
      for (final point in stroke.points) {
        minX = point.dx < minX ? point.dx : minX;
        minY = point.dy < minY ? point.dy : minY;
        maxX = point.dx > maxX ? point.dx : maxX;
        maxY = point.dy > maxY ? point.dy : maxY;
      }
    }

    // 여유 공간 추가 (형광펜 굵기의 절반)
    const padding = 10.0;
    return Rect.fromLTRB(
      minX - padding,
      minY - padding,
      maxX + padding,
      maxY + padding,
    );
  }

  Future<String?> _cropAndSave() async {
    if (_strokes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('형광펜으로 영역을 표시해주세요'),
          backgroundColor: DesignTokens.errorMain,
        ),
      );
      return null;
    }

    try {
      // 이미지 로드
      final imageFile = File(widget.imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final originalImage = frame.image;

      // 화면에 표시된 이미지의 크기
      final RenderBox? renderBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return null;

      final displaySize = renderBox.size;
      final imageSize = Size(
        originalImage.width.toDouble(),
        originalImage.height.toDouble(),
      );

      // 스케일 계산
      final scaleX = imageSize.width / displaySize.width;
      final scaleY = imageSize.height / displaySize.height;

      // 바운딩 박스 계산 (화면 좌표)
      final displayBounds = _calculateBoundingBox();
      if (displayBounds == null) return null;

      // 원본 이미지 좌표로 변환
      final cropRect = Rect.fromLTRB(
        (displayBounds.left * scaleX).clamp(0, imageSize.width),
        (displayBounds.top * scaleY).clamp(0, imageSize.height),
        (displayBounds.right * scaleX).clamp(0, imageSize.width),
        (displayBounds.bottom * scaleY).clamp(0, imageSize.height),
      );

      // 이미지 크롭
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);

      canvas.drawImageRect(
        originalImage,
        cropRect,
        Rect.fromLTWH(0, 0, cropRect.width, cropRect.height),
        Paint(),
      );

      final picture = recorder.endRecording();
      final croppedImage = await picture.toImage(
        cropRect.width.toInt(),
        cropRect.height.toInt(),
      );

      // 크롭된 이미지 저장
      final byteData = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
      final buffer = byteData!.buffer.asUint8List();

      final directory = await getTemporaryDirectory();
      final croppedPath = '${directory.path}/cropped_${DateTime.now().millisecondsSinceEpoch}.png';
      final croppedFile = File(croppedPath);
      await croppedFile.writeAsBytes(buffer);

      return croppedPath;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('이미지 처리 실패: $e'),
          backgroundColor: DesignTokens.errorMain,
        ),
      );
      return null;
    }
  }

  Future<void> _handleNext() async {
    final croppedPath = await _cropAndSave();
    if (croppedPath != null && mounted) {
      context.push(AppRoutes.ocrResult, extra: croppedPath);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppAppBar(
        title: '영역 선택',
        letterSpacing: 2,
        actions: [
          if (_strokes.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _clearAll,
              tooltip: '다시 그리기',
            ),
        ],
      ),
      body: Column(
        children: [
          // 안내 메시지
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: DesignTokens.primaryMain.withValues(alpha: 0.1),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: DesignTokens.primaryMain,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '손가락으로 텍스트 위에 형광펜을 그려주세요',
                    style: const TextStyle(
                      color: DesignTokens.primaryMain,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 이미지 + 형광펜 레이어
          Expanded(
            child: GestureDetector(
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              child: Stack(
                children: [
                  // 원본 이미지
                  Center(
                    child: Image.file(
                      File(widget.imagePath),
                      key: _imageKey,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 형광펜 레이어
                  Positioned.fill(
                    child: CustomPaint(
                      painter: HighlighterPainter([
                        ..._strokes,
                        if (_currentStroke.isNotEmpty)
                          HighlighterStroke(
                            points: _currentStroke,
                            color: _highlighterColor,
                          ),
                      ]),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 하단 버튼
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: AppButton(
                      text: '취소',
                      onPressed: () => context.pop(),
                      variant: AppButtonVariant.outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppButton(
                      text: 'OCR 실행',
                      onPressed: _handleNext,
                      variant: AppButtonVariant.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
