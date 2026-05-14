import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';

/// FCM 초기화 및 토큰 등록 서비스
class FcmService {
  final Dio _dio;

  FcmService(this._dio);

  Future<void> initialize() async {
    final messaging = FirebaseMessaging.instance;

    // 권한 요청 (iOS)
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.denied) return;

    // FCM 토큰 등록
    final token = await messaging.getToken();
    if (token != null) {
      await _registerToken(token);
    }

    // 토큰 갱신 시 재등록
    messaging.onTokenRefresh.listen(_registerToken);

    // 포그라운드 알림 표시 설정 (iOS)
    await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> _registerToken(String token) async {
    try {
      await _dio.post(
        '${ApiConstants.baseUrl}/users/fcmtoken',
        data: {'fcmToken': token},
      );
    } catch (_) {
      // 토큰 등록 실패는 무시 (로그인 전일 수 있음)
    }
  }
}
