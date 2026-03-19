import 'package:dio/dio.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/features/auth/data/models/auth_params.dart';
import 'package:snippet_app/features/auth/data/models/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> login(LoginParams params);
  Future<User> register(RegisterParams params);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<User> login(LoginParams params) async {
    try {
      final response = await _dio.post(
        ApiConstants.authLogin,
        data: params.toJson(),
      );
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw const ServerError('로그인에 실패했습니다');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }

  @override
  Future<User> register(RegisterParams params) async {
    try {
      final response = await _dio.post(
        ApiConstants.authRegister,
        data: params.toJson(),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return User.fromJson(response.data);
      }
      throw const ServerError('회원가입에 실패했습니다');
    } on DioException catch (e) {
      throw ErrorHandler.handleDioError(e);
    }
  }
}
