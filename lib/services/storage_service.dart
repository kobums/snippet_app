import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';

class StorageService {
  static const String _likedIdsKey = 'liked_snippet_ids';
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'current_user';

  final _secureStorage = const FlutterSecureStorage();

  Future<List<int>> getLikedIds() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? strings = prefs.getStringList(_likedIdsKey);
    if (strings == null) return [];
    return strings.map((s) => int.parse(s)).toList();
  }

  Future<void> addLikedId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getLikedIds();
    if (!ids.contains(id)) {
      ids.add(id);
      await prefs.setStringList(
        _likedIdsKey,
        ids.map((i) => i.toString()).toList(),
      );
    }
  }

  Future<void> removeLikedId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final ids = await getLikedIds();
    ids.remove(id);
    await prefs.setStringList(
      _likedIdsKey,
      ids.map((i) => i.toString()).toList(),
    );
  }

  // Token management (secure storage)
  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _secureStorage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _secureStorage.delete(key: _tokenKey);
  }

  // User management (shared preferences - non-sensitive data)
  Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(user.toJson()));
  }

  Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return User.fromJson(jsonDecode(userJson));
  }

  Future<void> deleteUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Clear all auth data
  Future<void> clearAuthData() async {
    await deleteToken();
    await deleteUser();
  }
}
