import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_app/core/error/app_error.dart';
import 'package:snippet_app/core/result/result.dart';
import 'package:snippet_app/features/auth/auth_providers.dart';
import 'package:snippet_app/features/auth/data/models/user.dart';
import 'package:snippet_app/features/auth/domain/usecases/check_auth_usecase.dart';
import 'package:snippet_app/features/auth/domain/usecases/delete_account_usecase.dart';
import 'package:snippet_app/features/auth/domain/usecases/login_usecase.dart';
import 'package:snippet_app/features/auth/domain/usecases/logout_usecase.dart';
import 'package:snippet_app/features/auth/domain/usecases/register_usecase.dart';
import 'package:snippet_app/features/auth/domain/usecases/send_verification_code_usecase.dart';
import 'package:snippet_app/features/auth/domain/usecases/verify_email_code_usecase.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final AppError? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    AppError? error,
    bool clearUser = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends Notifier<AuthState> {
  late final CheckAuthUseCase _checkAuthUseCase;
  late final LoginUseCase _loginUseCase;
  late final RegisterUseCase _registerUseCase;
  late final LogoutUseCase _logoutUseCase;
  late final DeleteAccountUseCase _deleteAccountUseCase;
  late final SendVerificationCodeUseCase _sendVerificationCodeUseCase;
  late final VerifyEmailCodeUseCase _verifyEmailCodeUseCase;

  @override
  AuthState build() {
    _checkAuthUseCase = ref.read(checkAuthUseCaseProvider);
    _loginUseCase = ref.read(loginUseCaseProvider);
    _registerUseCase = ref.read(registerUseCaseProvider);
    _logoutUseCase = ref.read(logoutUseCaseProvider);
    _deleteAccountUseCase = ref.read(deleteAccountUseCaseProvider);
    _sendVerificationCodeUseCase = ref.read(sendVerificationCodeUseCaseProvider);
    _verifyEmailCodeUseCase = ref.read(verifyEmailCodeUseCaseProvider);

    _checkAuth();
    return AuthState();
  }

  Future<void> _checkAuth() async {
    final result = await _checkAuthUseCase();
    result.when(
      success: (user) {
        state = state.copyWith(user: user);
      },
      failure: (_) {
        // Silent failure on check
      },
    );
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _loginUseCase(email, password);
    result.when(
      success: (user) {
        state = state.copyWith(user: user, isLoading: false);
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error);
        throw error;
      },
    );
  }

  /// 회원가입 후 이메일 인증 화면으로 이동하기 위해 email을 반환합니다.
  Future<String> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _registerUseCase(email, password, name);
    return result.when(
      success: (registeredEmail) {
        state = state.copyWith(isLoading: false);
        return registeredEmail;
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error);
        throw error;
      },
    );
  }

  Future<void> sendVerificationCode(String email) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _sendVerificationCodeUseCase(email);
    result.when(
      success: (_) {
        state = state.copyWith(isLoading: false);
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error);
        throw error;
      },
    );
  }

  Future<void> verifyCode(String email, String code) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _verifyEmailCodeUseCase(email, code);
    result.when(
      success: (user) {
        state = state.copyWith(user: user, isLoading: false);
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error);
        throw error;
      },
    );
  }

  Future<void> logout() async {
    await _logoutUseCase();
    state = AuthState();
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _deleteAccountUseCase();
    result.when(
      success: (_) {
        state = AuthState(); // 회원탈퇴 성공 시 상태 초기화
      },
      failure: (error) {
        state = state.copyWith(isLoading: false, error: error);
        throw error;
      },
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
