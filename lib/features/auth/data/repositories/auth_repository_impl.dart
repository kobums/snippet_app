import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/error/error_handler.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:snippet_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:snippet_app/features/auth/data/models/auth_params.dart';
import 'package:snippet_app/features/auth/data/models/user.dart';
import 'package:snippet_app/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final AuthLocalDataSource _localDataSource;

  AuthRepositoryImpl(this._remoteDataSource, this._localDataSource);

  @override
  Future<Result<User>> login(String email, String password) async {
    try {
      final params = LoginParams(email: email, password: password);
      final user = await _remoteDataSource.login(params);

      if (user.token != null) {
        await _localDataSource.saveToken(user.token!);
      }
      await _localDataSource.saveUser(user);

      return Success(user);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<String>> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final params = RegisterParams(
        email: email,
        password: password,
        name: name,
      );
      final registeredEmail = await _remoteDataSource.register(params);
      return Success(registeredEmail);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void>> sendVerificationCode(String email) async {
    try {
      await _remoteDataSource.sendVerificationCode(email);
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<User>> verifyCode(String email, String code) async {
    try {
      final user = await _remoteDataSource.verifyCode(email, code);
      if (user.token != null) {
        await _localDataSource.saveToken(user.token!);
      }
      await _localDataSource.saveUser(user);
      return Success(user);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<User>> checkAuth() async {
    try {
      final token = await _localDataSource.getToken();
      final user = await _localDataSource.getUser();

      if (token != null && user != null) {
        return Success(user);
      }

      return const Failure(AuthError('인증되지 않았습니다'));
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void>> logout() async {
    try {
      await _localDataSource.clearAuthData();
      return const Success(null);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }

  @override
  Future<Result<void>> deleteAccount() async {
    try {
      await _remoteDataSource.deleteAccount();
      await _localDataSource.clearAuthData();
      return const Success(null);
    } on AppError catch (e) {
      return Failure(e);
    } catch (e) {
      return Failure(ErrorHandler.handleException(e));
    }
  }
}
