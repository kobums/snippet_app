import 'dart:io';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gal/gal.dart';

/// 독서 캘린더 스크린샷 캡처 및 공유 서비스
class CalendarShareService {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// 캘린더 위젯을 이미지로 캡처하고 공유합니다.
  ///
  /// [context]: BuildContext (SnackBar 표시용)
  /// [calendarWidget]: 캡처할 캘린더 위젯
  /// [year]: 년도
  /// [month]: 월
  Future<void> captureAndShare(
    BuildContext context,
    Widget calendarWidget,
    int year,
    int month,
  ) async {
    try {
      // 1. 이미지 로딩을 위한 약간의 지연
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. 위젯을 고해상도 이미지로 캡처
      final imageBytes = await _screenshotController.captureFromWidget(
        calendarWidget,
        pixelRatio: 3.0, // 고해상도 렌더링 (Retina 디스플레이 대응)
        context: context,
        delay: const Duration(milliseconds: 100), // 렌더링 대기
      );

      // 2. 임시 디렉토리에 파일 저장
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath =
          '${directory.path}/reading_calendar_${year}_${month}_$timestamp.png';
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      // 3. 공유 메시지 생성
      final shareText = '$year년 $month월 독서 기록 📚 #Snippet #독서';

      // 4. 네이티브 공유 시트 호출
      if (context.mounted) {
        // iOS iPad에서 공유 시트 위치 지정
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

      // 5. 공유 완료 후 임시 파일 삭제
      // 약간의 지연을 두어 공유가 완료될 시간을 줌
      await Future.delayed(const Duration(seconds: 2));
      if (await file.exists()) {
        await file.delete();
      }

      // 6. 성공 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('캘린더를 공유했습니다.'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e, stackTrace) {
      // 에러 발생 시 사용자에게 알림
      print('공유 오류: $e');
      print('스택 트레이스: $stackTrace');

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

  /// 캘린더 위젯을 이미지로 캡처하고 갤러리에 저장합니다.
  ///
  /// [context]: BuildContext (SnackBar 표시용)
  /// [calendarWidget]: 캡처할 캘린더 위젯
  /// [year]: 년도
  /// [month]: 월
  Future<void> captureAndSaveToGallery(
    BuildContext context,
    Widget calendarWidget,
    int year,
    int month,
  ) async {
    try {
      // 1. 이미지 로딩을 위한 약간의 지연
      await Future.delayed(const Duration(milliseconds: 500));

      // 2. 위젯을 고해상도 이미지로 캡처
      final imageBytes = await _screenshotController.captureFromWidget(
        calendarWidget,
        pixelRatio: 3.0,
        context: context,
        delay: const Duration(milliseconds: 100), // 렌더링 대기
      );

      // 2. 갤러리에 저장
      await Gal.putImageBytes(imageBytes, album: 'Snippet');

      // 3. 성공 메시지 표시
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
      // 에러 발생 시 사용자에게 알림
      print('갤러리 저장 오류: $e');
      print('스택 트레이스: $stackTrace');

      // 권한 관련 에러 확인
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

  /// ScreenshotController를 외부에서 접근할 수 있도록 제공
  ScreenshotController get controller => _screenshotController;
}
