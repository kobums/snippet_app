import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user.dart';
import '../models/auth_params.dart';
import 'snippet_provider.dart';

class AuthState {
  final User? user;
  final bool isLoading;
  final String? error;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  bool get isAuthenticated => user != null;
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    // Check auth on initialization
    _checkAuth();
    return AuthState();
  }

  Future<void> _checkAuth() async {
    final storage = ref.read(storageServiceProvider);
    final token = await storage.getToken();
    final user = await storage.getUser();

    if (token != null && user != null) {
      state = state.copyWith(user: user);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final api = ref.read(apiServiceProvider);
      final storage = ref.read(storageServiceProvider);

      final params = LoginParams(email: email, password: password);
      final user = await api.login(params);

      // Save token and user
      if (user.token != null) {
        await storage.saveToken(user.token!);
      }
      await storage.saveUser(user);

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> register(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final api = ref.read(apiServiceProvider);
      final storage = ref.read(storageServiceProvider);

      final params = RegisterParams(email: email, password: password, name: name);
      final user = await api.register(params);

      // Save token and user, then auto-login
      if (user.token != null) {
        await storage.saveToken(user.token!);
      }
      await storage.saveUser(user);

      state = state.copyWith(user: user, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceAll('Exception: ', ''),
      );
      rethrow;
    }
  }

  Future<void> logout() async {
    final storage = ref.read(storageServiceProvider);
    await storage.clearAuthData();
    state = AuthState(); // Reset to initial state
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(() {
  return AuthNotifier();
});
