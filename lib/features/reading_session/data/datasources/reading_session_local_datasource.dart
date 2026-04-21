import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

const _kSessionKey = 'active_reading_session';

class PersistedSessionData {
  final int userBookId;
  final int bookId;
  final String bookTitle;
  final String bookCoverUrl;
  final String bookAuthor;
  final int totalPage;
  final int startPage;

  const PersistedSessionData({
    required this.userBookId,
    required this.bookId,
    required this.bookTitle,
    required this.bookCoverUrl,
    required this.bookAuthor,
    required this.totalPage,
    required this.startPage,
  });

  Map<String, dynamic> toJson() => {
        'userBookId': userBookId,
        'bookId': bookId,
        'bookTitle': bookTitle,
        'bookCoverUrl': bookCoverUrl,
        'bookAuthor': bookAuthor,
        'totalPage': totalPage,
        'startPage': startPage,
      };

  factory PersistedSessionData.fromJson(Map<String, dynamic> json) {
    return PersistedSessionData(
      userBookId: json['userBookId'] as int,
      bookId: json['bookId'] as int,
      bookTitle: json['bookTitle'] as String,
      bookCoverUrl: json['bookCoverUrl'] as String? ?? '',
      bookAuthor: json['bookAuthor'] as String? ?? '',
      totalPage: json['totalPage'] as int,
      startPage: json['startPage'] as int,
    );
  }
}

abstract class ReadingSessionLocalDataSource {
  Future<void> saveSession(PersistedSessionData data);
  Future<PersistedSessionData?> loadSession();
  Future<void> clearSession();
}

class ReadingSessionLocalDataSourceImpl implements ReadingSessionLocalDataSource {
  final SharedPreferences _prefs;

  ReadingSessionLocalDataSourceImpl(this._prefs);

  @override
  Future<void> saveSession(PersistedSessionData data) async {
    await _prefs.setString(_kSessionKey, jsonEncode(data.toJson()));
  }

  @override
  Future<PersistedSessionData?> loadSession() async {
    final raw = _prefs.getString(_kSessionKey);
    if (raw == null) return null;
    try {
      return PersistedSessionData.fromJson(jsonDecode(raw));
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> clearSession() async {
    await _prefs.remove(_kSessionKey);
    await _prefs.remove('rs_elapsed');
    await _prefs.remove('rs_paused');
  }
}
