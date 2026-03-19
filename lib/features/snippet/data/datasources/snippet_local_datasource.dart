import 'package:shared_preferences/shared_preferences.dart';
import 'package:snippet_app/core/constants.dart';

abstract class SnippetLocalDataSource {
  Future<List<int>> getLikedIds();
  Future<void> addLikedId(int id);
  Future<void> removeLikedId(int id);
}

class SnippetLocalDataSourceImpl implements SnippetLocalDataSource {
  final SharedPreferences _prefs;

  SnippetLocalDataSourceImpl(this._prefs);

  @override
  Future<List<int>> getLikedIds() async {
    final List<String>? strings =
        _prefs.getStringList(StorageConstants.likedIdsKey);
    if (strings == null) return [];
    return strings.map((s) => int.parse(s)).toList();
  }

  @override
  Future<void> addLikedId(int id) async {
    final ids = await getLikedIds();
    if (!ids.contains(id)) {
      ids.add(id);
      await _prefs.setStringList(
        StorageConstants.likedIdsKey,
        ids.map((i) => i.toString()).toList(),
      );
    }
  }

  @override
  Future<void> removeLikedId(int id) async {
    final ids = await getLikedIds();
    ids.remove(id);
    await _prefs.setStringList(
      StorageConstants.likedIdsKey,
      ids.map((i) => i.toString()).toList(),
    );
  }
}
