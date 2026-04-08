import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_app/app/router.dart';
import 'package:snippet_app/components/app_app_bar.dart';
import 'package:snippet_app/components/app_button.dart';
import 'package:snippet_app/core/design_tokens.dart';
import 'package:snippet_app/core/typography.dart';
import 'package:snippet_app/features/records/data/models/ocr_result.dart';

/// 수평 직선 밑줄 데이터
class UnderlineHighlight {
  final String id;
  final Offset startPoint;
  final Offset endPoint;
  final double yPosition;
  final double height;
  final Color color;
  final bool isSelected;

  UnderlineHighlight({
    required this.id,
    required this.startPoint,
    required this.endPoint,
    required this.yPosition,
    required this.height,
    required this.color,
    this.isSelected = false,
  });

  UnderlineHighlight copyWith({
    String? id,
    Offset? startPoint,
    Offset? endPoint,
    double? yPosition,
    double? height,
    Color? color,
    bool? isSelected,
  }) {
    return UnderlineHighlight(
      id: id ?? this.id,
      startPoint: startPoint ?? this.startPoint,
      endPoint: endPoint ?? this.endPoint,
      yPosition: yPosition ?? this.yPosition,
      height: height ?? this.height,
      color: color ?? this.color,
      isSelected: isSelected ?? this.isSelected,
    );
  }
}

/// 수평 밑줄 드로잉을 위한 CustomPainter
class UnderlinePainter extends CustomPainter {
  final List<UnderlineHighlight> underlines;
  final UnderlineHighlight? previewUnderline;

  UnderlinePainter({
    required this.underlines,
    this.previewUnderline,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final allUnderlines = [
      ...underlines,
      if (previewUnderline != null) previewUnderline!,
    ];

    for (final underline in allUnderlines) {
      // 1. 배경 영역 (반투명 사각형)
      final rect = Rect.fromLTRB(
        underline.startPoint.dx,
        underline.yPosition - underline.height / 2,
        underline.endPoint.dx,
        underline.yPosition + underline.height / 2,
      );

      final bgPaint = Paint()
        ..color = underline.color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      canvas.drawRect(rect, bgPaint);

      // 2. 수평 밑줄 (두꺼운 직선)
      final linePaint = Paint()
        ..color = underline.color
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        Offset(underline.startPoint.dx, underline.yPosition),
        Offset(underline.endPoint.dx, underline.yPosition),
        linePaint,
      );

      // 3. 선택된 밑줄 테두리 표시
      if (underline.isSelected) {
        final borderPaint = Paint()
          ..color = Colors.blue
          ..strokeWidth = 2.0
          ..style = PaintingStyle.stroke;
        canvas.drawRect(rect, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(UnderlinePainter oldDelegate) {
    return oldDelegate.underlines != underlines ||
        oldDelegate.previewUnderline != previewUnderline;
  }
}

class ImageHighlighterScreen extends StatefulWidget {
  final String imagePath;

  const ImageHighlighterScreen({super.key, required this.imagePath});

  @override
  State<ImageHighlighterScreen> createState() => _ImageHighlighterScreenState();
}

class _ImageHighlighterScreenState extends State<ImageHighlighterScreen> {
  List<UnderlineHighlight> _underlines = [];
  List<Offset> _tempPoints = [];
  UnderlineHighlight? _previewUnderline;
  String? _selectedId;
  bool _isProcessing = false;
  final GlobalKey _imageKey = GlobalKey();
  final GlobalKey _containerKey = GlobalKey();

  final Color _highlighterColor = Colors.yellow.withValues(alpha: 0.5);

  /// 자유 곡선을 수평 직선 밑줄로 변환
  UnderlineHighlight _convertToStraightLine(List<Offset> points) {
    final minX = points.map((p) => p.dx).reduce(min);
    final maxX = points.map((p) => p.dx).reduce(max);
    final avgY = points.map((p) => p.dy).reduce((a, b) => a + b) / points.length;
    final minY = points.map((p) => p.dy).reduce(min);
    final maxY = points.map((p) => p.dy).reduce(max);
    final yRange = maxY - minY;
    final height = (yRange * 3).clamp(40.0, 80.0);

    return UnderlineHighlight(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      startPoint: Offset(minX, avgY),
      endPoint: Offset(maxX, avgY),
      yPosition: avgY,
      height: height,
      color: _highlighterColor,
      isSelected: false,
    );
  }

  void _handlePanStart(DragStartDetails details) {
    setState(() {
      _tempPoints = [details.localPosition];
      _previewUnderline = null;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    setState(() {
      _tempPoints.add(details.localPosition);
      if (_tempPoints.length >= 2) {
        _previewUnderline = _convertToStraightLine(_tempPoints);
      }
    });
  }

  void _handlePanEnd(DragEndDetails details) {
    setState(() {
      if (_tempPoints.length >= 2) {
        _underlines.add(_convertToStraightLine(_tempPoints));
      }
      _tempPoints = [];
      _previewUnderline = null;
    });
  }

  void _handleTap(TapDownDetails details) {
    final tapPosition = details.localPosition;

    for (final underline in _underlines) {
      final rect = Rect.fromLTRB(
        underline.startPoint.dx,
        underline.yPosition - underline.height / 2,
        underline.endPoint.dx,
        underline.yPosition + underline.height / 2,
      );

      if (rect.contains(tapPosition)) {
        setState(() {
          _selectedId = underline.id;
          _underlines = _underlines
              .map((u) => u.copyWith(isSelected: u.id == underline.id))
              .toList();
        });
        return;
      }
    }

    setState(() {
      _selectedId = null;
      _underlines = _underlines.map((u) => u.copyWith(isSelected: false)).toList();
    });
  }

  void _deleteSelected() {
    if (_selectedId != null) {
      setState(() {
        _underlines.removeWhere((u) => u.id == _selectedId);
        _selectedId = null;
      });
    }
  }

  void _clearAll() {
    setState(() {
      _underlines.clear();
      _tempPoints = [];
      _previewUnderline = null;
      _selectedId = null;
    });
  }

  /// 밑줄 좌표를 이미지 픽셀 좌표로 변환하여 OcrRequest 생성
  Future<void> _handleNext() async {
    if (_underlines.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('밑줄을 먼저 그어주세요'),
          backgroundColor: DesignTokens.errorMain,
        ),
      );
      return;
    }

    setState(() => _isProcessing = true);

    try {
      // 원본 이미지 크기 로드
      final imageBytes = await File(widget.imagePath).readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final originalImage = frame.image;
      final imageWidth = originalImage.width.toDouble();
      final imageHeight = originalImage.height.toDouble();

      // Image.file 위젯 (실제 렌더링된 이미지 크기)
      final imageBox = _imageKey.currentContext?.findRenderObject() as RenderBox?;
      // Stack 위젯 (GestureDetector와 동일한 좌표계)
      final containerBox = _containerKey.currentContext?.findRenderObject() as RenderBox?;
      if (imageBox == null || containerBox == null || !mounted) return;

      // Image.file 위젯의 top-left 위치를 Stack 로컬 좌표계로 변환
      // → 이것이 곧 letterbox 오프셋 (offsetX, offsetY)
      final imageOrigin = containerBox.globalToLocal(imageBox.localToGlobal(Offset.zero));
      final offsetX = imageOrigin.dx;
      final offsetY = imageOrigin.dy;

      // Image.file 위젯 크기 = 실제 렌더링된 이미지 크기 (BoxFit.contain 결과)
      final scaleX = imageWidth / imageBox.size.width;
      final scaleY = imageHeight / imageBox.size.height;

      // GestureDetector 좌표 → 이미지 픽셀 좌표 변환
      final imageRegions = _underlines.map((u) {
        return Rect.fromLTRB(
          ((u.startPoint.dx - offsetX) * scaleX).clamp(0.0, imageWidth),
          ((u.yPosition - u.height / 2 - offsetY) * scaleY).clamp(0.0, imageHeight),
          ((u.endPoint.dx - offsetX) * scaleX).clamp(0.0, imageWidth),
          ((u.yPosition + u.height / 2 - offsetY) * scaleY).clamp(0.0, imageHeight),
        );
      }).toList();

      if (mounted) {
        context.push(
          AppRoutes.ocrResult,
          extra: OcrRequest(imagePath: widget.imagePath, regions: imageRegions),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
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
          if (_underlines.isNotEmpty)
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline, color: DesignTokens.primaryMain, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '손가락으로 텍스트에 밑줄을 그어주세요',
                        style: AppTypography.bodySmall.copyWith(color: DesignTokens.primaryMain),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(left: 28),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• 자동으로 수평선으로 변환됩니다',
                        style: AppTypography.caption.copyWith(color: DesignTokens.primaryMain),
                      ),
                      Text(
                        '• 밑줄을 탭하면 삭제할 수 있습니다',
                        style: AppTypography.caption.copyWith(color: DesignTokens.primaryMain),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 이미지 + 밑줄 레이어
          Expanded(
            child: GestureDetector(
              onPanStart: _handlePanStart,
              onPanUpdate: _handlePanUpdate,
              onPanEnd: _handlePanEnd,
              onTapDown: _handleTap,
              child: Stack(
                key: _containerKey,
                children: [
                  Center(
                    child: Image.file(
                      File(widget.imagePath),
                      key: _imageKey,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned.fill(
                    child: CustomPaint(
                      painter: UnderlinePainter(
                        underlines: _underlines,
                        previewUnderline: _previewUnderline,
                      ),
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
                  if (_selectedId != null)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _deleteSelected,
                      color: DesignTokens.errorMain,
                      tooltip: '선택된 밑줄 삭제',
                    ),
                  if (_underlines.isNotEmpty && _selectedId == null)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _clearAll,
                      tooltip: '전체 지우기',
                    ),
                  Expanded(
                    child: AppButton(
                      text: '취소',
                      onPressed: () => context.pop(),
                      variant: AppButtonVariant.outlined,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: AppButton(
                      text: _underlines.isEmpty
                          ? 'OCR 실행'
                          : 'OCR 실행 (${_underlines.length}개)',
                      onPressed: (_underlines.isEmpty || _isProcessing) ? null : _handleNext,
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
