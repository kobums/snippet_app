import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:snippet_app/core/constants.dart';
import 'package:snippet_app/features/auth/data/models/user.dart';

abstract class AuthLocalDataSource {
  Future<String?> getToken();
  Future<void> saveToken(String token);
  Future<void> deleteToken();
  Future<User?> getUser();
  Future<void> saveUser(User user);
  Future<void> deleteUser();
  Future<void> clearAuthData();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _secureStorage;
  final SharedPreferences _prefs;

  AuthLocalDataSourceImpl(this._secureStorage, this._prefs);

  @override
  Future<String?> getToken() async {
    return await _secureStorage.read(key: StorageConstants.tokenKey);
  }

  @override
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: StorageConstants.tokenKey, value: token);
  }

  @override
  Future<void> deleteToken() async {
    await _secureStorage.delete(key: StorageConstants.tokenKey);
  }

  @override
  Future<User?> getUser() async {
    final userJson = _prefs.getString(StorageConstants.userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  @override
  Future<void> saveUser(User user) async {
    await _prefs.setString(
      StorageConstants.userKey,
      jsonEncode(user.toJson()),
    );
  }

  @override
  Future<void> deleteUser() async {
    await _prefs.remove(StorageConstants.userKey);
  }

  @override
  Future<void> clearAuthData() async {
    await deleteToken();
    await deleteUser();
  }
}
