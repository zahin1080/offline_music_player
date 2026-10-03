part of 'playlist_provider.dart';

extension MusicProviderPlaylists on MusicProvider {
  bool isFavorite(int songId) => _favoriteBox.containsKey(songId);

  void toggleFavorite(int songId) {
    if (isFavorite(songId)) {
      _favoriteBox.delete(songId);
    } else {
      _favoriteBox.put(songId, true);
    }
    notifyUI();
  }

  List<AudioModel> getFavorites() =>
      _songs.where((song) => isFavorite(song.id)).toList();

  void createPlaylist(String name) {
    if (!_playlistBox.containsKey(name)) {
      _playlistBox.put(name, <int>[]);
      notifyUI();
    }
  }

  void renamePlaylist(String oldName, String newName) {
    if (_playlistBox.containsKey(oldName)) {
      final songs = _playlistBox.get(oldName);
      _playlistBox.delete(oldName);
      _playlistBox.put(newName, songs);
      notifyUI();
    }
  }

  void deletePlaylist(String name) {
    _playlistBox.delete(name);
    notifyUI();
  }

  void addSongToPlaylist(String name, int songId) {
    List<dynamic> list = _playlistBox.get(name, defaultValue: <int>[]);
    List<int> updated = List<int>.from(list);
    if (!updated.contains(songId)) {
      updated.add(songId);
      _playlistBox.put(name, updated);
      notifyUI();
    }
  }

  void removeSongFromPlaylist(String name, int songId) {
    List<dynamic> list = _playlistBox.get(name, defaultValue: <int>[]);
    List<int> updated = List<int>.from(list);
    updated.remove(songId);
    _playlistBox.put(name, updated);
    notifyUI();
  }

  List<AudioModel> getPlaylistSongs(String name) {
    List<dynamic> ids = _playlistBox.get(name, defaultValue: <int>[]);
    return _songs.where((s) => ids.contains(s.id)).toList();
  }
}
