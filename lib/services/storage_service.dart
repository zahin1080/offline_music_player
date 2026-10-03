import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  late final Box _favoriteBox;
  late final Box _historyBox;
  late final Box _playlistBox;
  late final Box _statsBox;
  late final Box _sessionBox;
  late final Box _titlesBox;

  Future<void> init() async {
    _favoriteBox = Hive.box('favorites');
    _historyBox = Hive.box('history');
    _playlistBox = Hive.box('playlists');
    _statsBox = Hive.box('stats');
    _sessionBox = Hive.box('session');

    _titlesBox = Hive.isBoxOpen('custom_titles')
        ? Hive.box('custom_titles')
        : await Hive.openBox('custom_titles');
  }

  dynamic getSessionValue(String key, {dynamic defaultValue}) =>
      _sessionBox.get(key, defaultValue: defaultValue);
  Future<void> setSessionValue(String key, dynamic value) =>
      _sessionBox.put(key, value);

  String getCustomTitle(int songId, String originalTitle) {
    return _titlesBox.get(songId, defaultValue: originalTitle) as String;
  }

  Future<void> setCustomTitle(int songId, String newTitle) =>
      _titlesBox.put(songId, newTitle);

  bool isFavorite(int songId) => _favoriteBox.containsKey(songId);
  void toggleFavorite(int songId) {
    if (isFavorite(songId)) {
      _favoriteBox.delete(songId);
    } else {
      _favoriteBox.put(songId, true);
    }
  }

  void recordPlayHistory(int songId) {
    _historyBox.put(songId, DateTime.now().millisecondsSinceEpoch);
  }

  void clearHistory() => _historyBox.clear();
  List<dynamic> getHistoryKeys() => _historyBox.keys.toList();
  dynamic getHistoryValue(dynamic key) => _historyBox.get(key);

  void incrementPlayCount(int songId) {
    int currentCount = _statsBox.get(songId, defaultValue: 0) as int;
    _statsBox.put(songId, currentCount + 1);
  }

  int getPlayCount(int songId) =>
      (_statsBox.get(songId, defaultValue: 0) as int?) ?? 0;
  void clearStats() => _statsBox.clear();
  List<dynamic> getStatsKeys() => _statsBox.keys.toList();

  bool hasPlaylist(String name) => _playlistBox.containsKey(name);
  void createPlaylist(String name) {
    if (!hasPlaylist(name)) {
      _playlistBox.put(name, <int>[]);
    }
  }

  void renamePlaylist(String oldName, String newName) {
    if (hasPlaylist(oldName)) {
      final songs = _playlistBox.get(oldName);
      _playlistBox.delete(oldName);
      _playlistBox.put(newName, songs);
    }
  }

  void deletePlaylist(String name) => _playlistBox.delete(name);
  void addSongToPlaylist(String name, int songId) {
    List<dynamic> list = _playlistBox.get(name, defaultValue: <int>[]);
    List<int> updated = List<int>.from(list);
    if (!updated.contains(songId)) {
      updated.add(songId);
      _playlistBox.put(name, updated);
    }
  }

  void removeSongFromPlaylist(String name, int songId) {
    List<dynamic> list = _playlistBox.get(name, defaultValue: <int>[]);
    List<int> updated = List<int>.from(list);
    updated.remove(songId);
    _playlistBox.put(name, updated);
  }

  List<int> getPlaylistSongIds(String name) {
    List<dynamic> ids = _playlistBox.get(name, defaultValue: <int>[]);
    return List<int>.from(ids);
  }
}
