import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

class CalendarShareService {
  final ScreenshotController _screenshotController = ScreenshotController();

  ScreenshotController get controller => _screenshotController;

  Future<void> captureAndShare(
    BuildContext context,
    Widget calendarWidget,
    int year,
    int month,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final imageBytes = await _screenshotController.captureFromWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: calendarWidget,
        ),
        targetSize: const Size(1080, 1350),
        delay: const Duration(milliseconds: 500),
      );

      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath =
          '${directory.path}/reading_calendar_${year}_${month}_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      final shareText = '$year년 $month월 독서 기록 📚 #Snippet #독서';

      if (context.mounted) {
        final box = context.findRenderObject() as RenderBox?;
        final sharePositionOrigin = box != null
            ? box.localToGlobal(Offset.zero) & box.size
            : const Rect.fromLTWH(0, 0, 10, 10);

        await Share.shareXFiles(
          [XFile(filePath)],
          text: shareText,
          sharePositionOrigin: sharePositionOrigin,
        );
      }

      await Future.delayed(const Duration(seconds: 2));
      if (await file.exists()) {
        await file.delete();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('캘린더를 공유했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('공유 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  Future<void> captureAndSaveToGallery(
    BuildContext context,
    Widget calendarWidget,
    int year,
    int month,
  ) async {
    try {
      await Future.delayed(const Duration(milliseconds: 500));

      final imageBytes = await _screenshotController.captureFromWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: calendarWidget,
        ),
        targetSize: const Size(1080, 1350),
        delay: const Duration(milliseconds: 500),
      );

      await Gal.putImageBytes(imageBytes, album: 'Snippet');

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('독서 캘린더가 갤러리에 저장되었습니다.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e, stackTrace) {
      String errorMessage = '갤러리 저장 중 오류가 발생했습니다';
      if (e.toString().contains('permission') ||
          e.toString().contains('Permission')) {
        errorMessage = '사진 라이브러리 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.';
      } else if (e.toString().contains('denied')) {
        errorMessage = '권한이 거부되었습니다. 설정에서 권한을 허용해주세요.';
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$errorMessage\n\n상세: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
