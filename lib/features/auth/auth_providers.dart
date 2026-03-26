import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/app/providers.dart';
import 'package:snippet_app/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:snippet_app/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:snippet_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:snippet_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:snippet_app/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:snippet_app/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:snippet_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:snippet_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:snippet_app/features/auth/domain/usecases/register_usecase.dart';

// DataSources
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  final dio = ref.read(dioProvider);
  return AuthRemoteDataSourceImpl(dio);
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  final secureStorage = ref.read(secureStorageProvider);
  final prefs = ref.read(sharedPreferencesProvider);
  return AuthLocalDataSourceImpl(secureStorage, prefs);
});

// Repository
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final remote = ref.read(authRemoteDataSourceProvider);
  final local = ref.read(authLocalDataSourceProvider);
  return AuthRepositoryImpl(remote, local);
});

// UseCases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.read(authRepositoryProvider));
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  return RegisterUseCase(ref.read(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.read(authRepositoryProvider));
});

final checkAuthUseCaseProvider = Provider<CheckAuthUseCase>((ref) {
  return CheckAuthUseCase(ref.read(authRepositoryProvider));
});

final deleteAccountUseCaseProvider = Provider<DeleteAccountUseCase>((ref) {
  return DeleteAccountUseCase(ref.read(authRepositoryProvider));
});
