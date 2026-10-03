part of 'playlist_provider.dart';

extension MusicProviderStats on MusicProvider {
  List<AudioModel> getRecentlyPlayed({int limit = 20}) {
    final keys = _historyBox.keys.toList();
    keys.sort((a, b) {
      final valA = _historyBox.get(a);
      final valB = _historyBox.get(b);
      final timeA = valA is int
          ? valA
          : DateTime.tryParse(valA.toString())?.millisecondsSinceEpoch ?? 0;
      final timeB = valB is int
          ? valB
          : DateTime.tryParse(valB.toString())?.millisecondsSinceEpoch ?? 0;
      return timeB.compareTo(timeA);
    });

    final List<AudioModel> recents = [];
    for (final key in keys) {
      try {
        final song = _songs.firstWhere((s) => s.id == key);
        recents.add(song);
      } catch (_) {}
    }
    return recents.take(limit).toList();
  }

  List<AudioModel> getRecentlyAdded() {
    final sorted = List<AudioModel>.from(_songs);
    sorted.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
    return sorted.take(20).toList();
  }

  List<AudioModel> getMostPlayed({int limit = 20}) {
    final keys = _statsBox.keys.toList();
    keys.sort((a, b) {
      final countA = (_statsBox.get(a) as int?) ?? 0;
      final countB = (_statsBox.get(b) as int?) ?? 0;
      return countB.compareTo(countA);
    });

    final List<AudioModel> mostPlayed = [];
    for (final key in keys) {
      try {
        final song = _songs.firstWhere((s) => s.id == key);
        if (((_statsBox.get(key) as int?) ?? 0) > 0) {
          mostPlayed.add(song);
        }
      } catch (_) {}
    }
    return mostPlayed.take(limit).toList();
  }

  int getSongPlayCount(int songId) =>
      (_statsBox.get(songId, defaultValue: 0) as int?) ?? 0;

  void clearMostPlayed() => clearPlayStatistics();

  void clearHistory() {
    _historyBox.clear();
    notifyUI();
  }

  void clearPlayStatistics() {
    _statsBox.clear();
    notifyUI();
  }
}
