import 'package:dio/dio.dart';
import '../models/snippet.dart';
import '../models/snippet_archive.dart';
import '../models/user.dart';
import '../models/auth_params.dart';
import 'storage_service.dart';
import 'dart:io' show Platform;

class ApiService {
  final Dio _dio;
  final StorageService _storage;

  // Public getter for Dio instance
  Dio get dio => _dio;

  ApiService(this._storage)
    : _dio = Dio(
        BaseOptions(
          // Use Mac's local IP for real device testing
          baseUrl: 'http://10.0.1.14:8008/api',
          // baseUrl: 'https://snippetapi.gowoobro.com/api',
          connectTimeout: const Duration(seconds: 5),
        ),
      ) {
    try {
      if (Platform.isAndroid && _dio.options.baseUrl.contains('localhost')) {
        _dio.options.baseUrl = 'http://10.0.2.2:8008/api';
      }
    } catch (e) {
      // Ignored for web
    }

    // Add request interceptor to inject auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Handle 401 errors (token expired or invalid)
          if (error.response?.statusCode == 401) {
            // Clear auth data on 401 (except for auth endpoints)
            final path = error.requestOptions.path;
            if (!path.contains('/auth/')) {
              await _storage.clearAuthData();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<List<Snippet>> fetchSnippets(int count) async {
    try {
      final response = await _dio.get(
        '/snippets/cards',
        queryParameters: {'count': count},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => Snippet.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('API fetch error: $e');
      return [];
    }
  }

  Future<List<SnippetArchive>> fetchArchive(List<int> ids) async {
    if (ids.isEmpty) return [];
    try {
      final idsParam = ids.join(',');
      final response = await _dio.get(
        '/snippets/archive',
        queryParameters: {'ids': idsParam},
      );
      if (response.statusCode == 200) {
        final List data = response.data;
        return data.map((e) => SnippetArchive.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Archive API error: $e');
      return [];
    }
  }

  // Authentication endpoints
  Future<User> login(LoginParams params) async {
    try {
      final response = await _dio.post('/auth/login', data: params.toJson());
      if (response.statusCode == 200) {
        return User.fromJson(response.data);
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Login failed',
      );
    } on DioException catch (e) {
      print('Login error: $e');
      throw Exception(
        e.response?.data['message'] ?? 'Login failed. Please try again.',
      );
    }
  }

  Future<User> register(RegisterParams params) async {
    try {
      final response = await _dio.post('/auth/register', data: params.toJson());
      if (response.statusCode == 200 || response.statusCode == 201) {
        return User.fromJson(response.data);
      }
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        error: 'Registration failed',
      );
    } on DioException catch (e) {
      print('Register error: $e');
      throw Exception(
        e.response?.data['message'] ?? 'Registration failed. Please try again.',
      );
    }
  }
}
