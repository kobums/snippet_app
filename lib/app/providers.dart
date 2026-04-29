import 'dart:io' show Platform;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snippet_app/core/constants.dart';

// Must be overridden in main() with ProviderScope.overrides
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden in main()');
});

const _themeModeKey = 'themeMode';

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    final saved = prefs.getString(_themeModeKey);
    return switch (saved) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void setMode(ThemeMode mode) {
    state = mode;
    ref.read(sharedPreferencesProvider).setString(
      _themeModeKey,
      switch (mode) {
        ThemeMode.light => 'light',
        ThemeMode.dark => 'dark',
        ThemeMode.system => 'system',
      },
    );
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final dioProvider = Provider<Dio>((ref) {
  final secureStorage = ref.read(secureStorageProvider);

  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 5),
    ),
  );

  try {
    if (Platform.isAndroid && dio.options.baseUrl.contains('localhost')) {
      dio.options.baseUrl = 'http://10.0.2.2:8008/api';
    }
  } catch (e) {
    // Ignored for web
  }

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await secureStorage.read(key: StorageConstants.tokenKey);
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final path = error.requestOptions.path;
          if (!path.contains('/auth/')) {
            await secureStorage.delete(key: StorageConstants.tokenKey);
          }
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
});
