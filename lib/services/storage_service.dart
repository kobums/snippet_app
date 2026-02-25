import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _likedIdsKey = 'liked_snippet_ids';

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
}
