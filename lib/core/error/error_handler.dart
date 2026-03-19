import 'package:dio/dio.dart';
import 'app_error.dart';

class ErrorHandler {
  static AppError handleDioError(DioException e) {
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return NetworkError('연결 시간이 초과되었습니다', details: e.message);
    }

    if (e.type == DioExceptionType.connectionError) {
      return NetworkError('네트워크 연결을 확인해주세요', details: e.message);
    }

    if (e.response != null) {
      final statusCode = e.response!.statusCode;
      final message = _extractMessage(e.response!.data);

      if (statusCode == 401 || statusCode == 403) {
        return AuthError(message ?? '인증에 실패했습니다', details: e.message);
      }

      if (statusCode != null && statusCode >= 400 && statusCode < 500) {
        return ValidationError(
          message ?? '요청이 잘못되었습니다',
          details: e.message,
        );
      }

      if (statusCode != null && statusCode >= 500) {
        return ServerError(
          message ?? '서버 오류가 발생했습니다',
          statusCode: statusCode,
          details: e.message,
        );
      }
    }

    return UnknownError('알 수 없는 오류가 발생했습니다', details: e.message);
  }

  static AppError handleException(Object e) {
    if (e is DioException) return handleDioError(e);
    if (e is AppError) return e;
    return UnknownError(e.toString());
  }

  static String? _extractMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] as String?;
    }
    return null;
  }
}
