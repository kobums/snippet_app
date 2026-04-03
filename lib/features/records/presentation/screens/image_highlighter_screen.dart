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
import 'package:path_provider/path_provider.dart';

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
  final GlobalKey _imageKey = GlobalKey();

  // 밑줄 색상 (반투명 노란색)
  final Color _highlighterColor = Colors.yellow.withValues(alpha: 0.5);

  /// 자유 곡선을 수평 직선 밑줄로 변환
  UnderlineHighlight _convertToStraightLine(List<Offset> points) {
    // 1. X 범위 (시작점 ~ 끝점)
    final minX = points.map((p) => p.dx).reduce(min);
    final maxX = points.map((p) => p.dx).reduce(max);

    // 2. Y 평균 (수평선 위치)
    final avgY = points.map((p) => p.dy).reduce((a, b) => a + b) / points.length;

    // 3. 밑줄 높이 추정 (Y축 분산도 기반)
    final minY = points.map((p) => p.dy).reduce(min);
    final maxY = points.map((p) => p.dy).reduce(max);
    final yRange = maxY - minY;
    final height = (yRange * 3).clamp(40.0, 80.0); // 한글 텍스트 라인 고려

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
      // 실시간 직선 변환 미리보기
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
          // 선택 상태 업데이트
          _underlines = _underlines
              .map((u) => u.copyWith(isSelected: u.id == underline.id))
              .toList();
        });
        return;
      }
    }

    // 빈 곳 탭 시 선택 해제
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

  Future<List<String>> _cropAndProcessMultiple() async {
    if (_underlines.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('밑줄을 먼저 그어주세요'),
            backgroundColor: DesignTokens.errorMain,
          ),
        );
      }
      return [];
    }

    try {
      // 1. 원본 이미지 로드
      final imageFile = File(widget.imagePath);
      final imageBytes = await imageFile.readAsBytes();
      final codec = await ui.instantiateImageCodec(imageBytes);
      final frame = await codec.getNextFrame();
      final originalImage = frame.image;

      // 2. 스케일 계산
      final RenderBox? renderBox =
          _imageKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox == null) return [];

      final displaySize = renderBox.size;
      final imageSize = Size(
        originalImage.width.toDouble(),
        originalImage.height.toDouble(),
      );

      final scaleX = imageSize.width / displaySize.width;
      final scaleY = imageSize.height / displaySize.height;

      // 3. 각 밑줄마다 크롭
      final List<String> croppedPaths = [];
      final directory = await getTemporaryDirectory();

      for (int i = 0; i < _underlines.length; i++) {
        final underline = _underlines[i];

        // 3-1. 바운딩 박스 (화면 좌표)
        final displayRect = Rect.fromLTRB(
          underline.startPoint.dx,
          underline.yPosition - underline.height / 2,
          underline.endPoint.dx,
          underline.yPosition + underline.height / 2,
        );

        // 3-2. 원본 이미지 좌표로 변환
        final cropRect = Rect.fromLTRB(
          (displayRect.left * scaleX).clamp(0.0, imageSize.width),
          (displayRect.top * scaleY).clamp(0.0, imageSize.height),
          (displayRect.right * scaleX).clamp(0.0, imageSize.width),
          (displayRect.bottom * scaleY).clamp(0.0, imageSize.height),
        );

        // 3-3. 크롭
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

        // 3-4. 저장
        final byteData =
            await croppedImage.toByteData(format: ui.ImageByteFormat.png);
        final buffer = byteData!.buffer.asUint8List();

        final timestamp = DateTime.now().millisecondsSinceEpoch;
        final croppedPath = '${directory.path}/underline_${i}_$timestamp.png';
        final croppedFile = File(croppedPath);
        await croppedFile.writeAsBytes(buffer);

        croppedPaths.add(croppedPath);
      }

      return croppedPaths;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('이미지 처리 실패: $e'),
            backgroundColor: DesignTokens.errorMain,
          ),
        );
      }
      return [];
    }
  }

  Future<void> _handleNext() async {
    final croppedPaths = await _cropAndProcessMultiple();
    if (croppedPaths.isNotEmpty && mounted) {
      // 여러 이미지 경로를 전달
      context.push(AppRoutes.ocrResult, extra: croppedPaths);
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
                    const Icon(
                      Icons.info_outline,
                      color: DesignTokens.primaryMain,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '손가락으로 텍스트에 밑줄을 그어주세요',
                        style: AppTypography.bodySmall.copyWith(
                          color: DesignTokens.primaryMain,
                        ),
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
                        style: AppTypography.caption.copyWith(
                          color: DesignTokens.primaryMain,
                        ),
                      ),
                      Text(
                        '• 밑줄을 탭하면 삭제할 수 있습니다',
                        style: AppTypography.caption.copyWith(
                          color: DesignTokens.primaryMain,
                        ),
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
                children: [
                  // 원본 이미지
                  Center(
                    child: Image.file(
                      File(widget.imagePath),
                      key: _imageKey,
                      fit: BoxFit.contain,
                    ),
                  ),

                  // 밑줄 레이어
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
                  // 선택 삭제 버튼
                  if (_selectedId != null)
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: _deleteSelected,
                      color: DesignTokens.errorMain,
                      tooltip: '선택된 밑줄 삭제',
                    ),
                  // 전체 지우기
                  if (_underlines.isNotEmpty && _selectedId == null)
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _clearAll,
                      tooltip: '전체 지우기',
                    ),
                  const Spacer(),
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
                      onPressed: _underlines.isEmpty ? null : _handleNext,
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
