import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
enum SongSortOption {title, artist, dateAdded, duration, playCount }
class MusicProvider extends ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  Map<String, List<SongModel>> _folders = {};
  List<SongModel> _songs = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<SongModel> _currentQueue = [];
  int _currentIndex = -1;

  bool _isLoading = true;
  bool _hasPermissions = false;
  bool _isShiffle = false;
  double _playbackSpeed = 1.0;
  String? _playbackError;
  LoopMode _loopMode = LoopMode.off;
  SongSortOption _currentSort = SongSortOption.title;
  bool _isPermanentlyDenied = false;
  late final Box _favoriteBox;
  late final Box _historyBox;
  late final Box _playlistBox;
  late final Box _statsBox;
  late final Box _sessionBox;
  late final Box _titlesBox;

  List<SongModel> get songs => _songs;
  List<AlbumModel> get albums => _albums;
  List<ArtistModel> get artists => _artists;
  Map<String, List<SongModel>> get folders => _folders;
  List<SongModel> get currentQueue => _currentQueue;
  SongModel? get currentSong => (_currentIndex >= 0 && _currentIndex < _currentQueue.length)
      ? _currentQueue[_currentIndex]
      : null;

  AudioPlayer get player => _audioPlayer;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermissions;
  bool get isPermanentlyDenied => _isPermanentlyDenied;
  bool get isShuffle => _isShiffle;
  LoopMode get loopMode => _loopMode;
  double get playbackSpeed => _playbackSpeed;
  String? get playbackError => _playbackError;
  Box get playlistBox => _playlistBox;
  SongSortOption get currentSort => _currentSort;

  List<SongModel> get downloadedSongs {
    return _songs.where((song) {
      final path = song.data.toLowerCase();
      return path.contains('/download/') || path.contains('/downloads/');
    }).toList();
  }

  MusicProvider() {
    _initStorageAndAudio();
  }

  Future<void> _initStorageAndAudio() async {
    _favoriteBox = Hive.box('favorites');
    _historyBox = Hive.box('history');
    _playlistBox = Hive.box('playlists');
    _statsBox = Hive.box('stats');
    _sessionBox = Hive.box('session');
    _titlesBox = Hive.isBoxOpen('custom_titles')
        ? Hive.box('custom_titles')
        : await Hive.openBox('custom_titles');

    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_loopMode == LoopMode.one) {
          _audioPlayer.seek(Duration.zero);
          _audioPlayer.play();
        } else {
          playNext();
        }
      }
    });

    _audioPlayer.positionStream.listen((position) {
      if (currentSong != null) {
        _sessionBox.put('lastPosition', position.inMilliseconds);
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestPermissionAndFetch();
    });
  }

  Future<void> requestPermissionAndFetch() async {
    _isLoading = true;
    _playbackError = null;
    notifyListeners();

    try {
      if (await Permission.notification.isDenied) {
        await Permission.notification.request();
      }

      bool permissionGranted = false;
      PermissionStatus audioStatus = await Permission.audio.status;
      PermissionStatus storageStatus = await Permission.storage.status;

      if (audioStatus.isGranted || storageStatus.isGranted) {
        permissionGranted = true;
      } else {
        final statuses = await [
          Permission.audio,
          Permission.storage,
        ].request().timeout(const Duration(seconds: 10));

        final aRes = statuses[Permission.audio];
        final sRes = statuses[Permission.storage];

        permissionGranted = (aRes?.isGranted ?? false) || (sRes?.isGranted ?? false);
        _isPermanentlyDenied = (aRes?.isPermanentlyDenied ?? false) ||
            (sRes?.isPermanentlyDenied ?? false);
      }

      _hasPermissions = permissionGranted;

      if (_hasPermissions) {
        await rescanLibrary();
        _restoreLastSession();
      }
    } catch (e) {
      log("Storage/Notification permission error: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> rescanLibrary() async {
    try {
      final rawSongs = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      _songs = rawSongs.where((song) {
        if (song.data.isEmpty) return false;
        try {
          return File(song.data).existsSync();
        } catch (_) {
          return true;
        }
      }).toList();

      _albums = await _audioQuery.queryAlbums();
      _artists = await _audioQuery.queryArtists();

      _buildFolderIndex();
      _applySort();
    } catch (e) {
      log("Scan error: $e");
    }
    notifyListeners();
  }

  void _buildFolderIndex() {
    _folders.clear();
    for (var song in _songs) {
      if (song.data.isNotEmpty) {
        try {
          final file = File(song.data);
          final folderPath = file.parent.path;
          final folderName = folderPath.split(Platform.pathSeparator).last;
          if (folderName.isNotEmpty) {
            _folders.putIfAbsent(folderName, () => []).add(song);
          }
        } catch (_) {
          _folders.putIfAbsent("Internal Audio", () => []).add(song);
        }
      }
    }
  }

  String getSongTitle(SongModel song) {
    return _titlesBox.get(song.id, defaultValue: song.title) as String;
  }

  Future<void> renameSong(SongModel song, String newTitle) async {
    if (newTitle.trim().isEmpty) return;
    await _titlesBox.put(song.id, newTitle.trim());

    try {
      final file = File(song.data);
      if (file.existsSync()) {
        final dir = file.parent.path;
        final extension = song.data.split('.').last;
        final newPath = "$dir/${newTitle.trim()}.$extension";
        if (!File(newPath).existsSync()) {
          await file.rename(newPath);
        }
      }
    } catch (_) {}

    _applySort();
    notifyListeners();
  }

  void sortSongs(SongSortOption sortOption) {
    _currentSort = sortOption;
    _applySort();
    notifyListeners();
  }

  void _applySort() {
    switch (_currentSort) {
      case SongSortOption.title:
        _songs.sort((a, b) => getSongTitle(a).toLowerCase().compareTo(getSongTitle(b).toLowerCase()));
        break;
      case SongSortOption.artist:
        _songs.sort((a, b) => (a.artist ?? '').toLowerCase().compareTo((b.artist ?? '').toLowerCase()));
        break;
      case SongSortOption.dateAdded:
        _songs.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
        break;
      case SongSortOption.duration:
        _songs.sort((a, b) => (b.duration ?? 0).compareTo(a.duration ?? 0));
        break;
      case SongSortOption.playCount:
        _songs.sort((a, b) {
          int countA = _statsBox.get(a.id, defaultValue: 0) as int;
          int countB = _statsBox.get(b.id, defaultValue: 0) as int;
          return countB.compareTo(countA);
        });
        break;
    }
  }

  void _restoreLastSession() {
    final lastSongId = _sessionBox.get('lastSongId');
    final lastPositionMs = _sessionBox.get('lastPosition', defaultValue: 0);

    if (lastSongId != null && _songs.isNotEmpty) {
      final matchIndex = _songs.indexWhere((s) => s.id == lastSongId);
      if (matchIndex != -1) {
        _currentQueue = List.from(_songs);
        _currentIndex = matchIndex;
        final song = _songs[matchIndex];

        final audioSource = AudioSource.uri(
          Uri.parse(song.uri!),
          tag: MediaItem(
            id: song.id.toString(),
            album: song.album ?? "Unknown Album",
            title: getSongTitle(song),
            artist: song.artist ?? "Unknown Artist",
            artUri: Uri.parse("content://media/external/audio/albumart/${song.albumId}"),
          ),
        );
        _audioPlayer.setAudioSource(
          audioSource,
          initialPosition: Duration(milliseconds: lastPositionMs),
        );
      }
    }
  }
  Future<void> playSong(SongModel song, {List<SongModel>? queue, Duration? startPosition}) async {
    _playbackError = null;
    try {
      if (song.data.isNotEmpty) {
        final file = File(song.data);
        if (!file.existsSync()) {
          _playbackError = "Audio file missing or deleted from storage";
          notifyListeners();
          return;
        }
      }

      _currentQueue = queue != null ? List.from(queue) : List.from(_songs);
      _currentIndex = _currentQueue.indexWhere((item) => item.id == song.id);
      final audioSource = AudioSource.uri(
        Uri.parse(song.uri!),
        tag: MediaItem(
          id: song.id.toString(),
          album: (song.album != null && song.album!.trim().isNotEmpty) ? song.album! : "Unknown Album",
          title: getSongTitle(song).trim().isNotEmpty ? getSongTitle(song) : "Unknown Title",
          artist: (song.artist != null && song.artist!.trim().isNotEmpty) ? song.artist! : "Unknown Artist",
          artUri: song.albumId != null
              ? Uri.parse("content://media/external/audio/albumart/${song.albumId}")
              : null,
        ),
      );

      await _audioPlayer.setAudioSource(audioSource, initialPosition: startPosition);
      await _audioPlayer.setSpeed(_playbackSpeed);
      _audioPlayer.play();

      _historyBox.put(song.id, DateTime.now().millisecondsSinceEpoch);
      int currentCount = _statsBox.get(song.id, defaultValue: 0) as int;
      _statsBox.put(song.id, currentCount + 1);

      _sessionBox.put('lastSongId', song.id);

      notifyListeners();
    } catch (e) {
      _playbackError = "Unsupported or corrupted audio track";
      log("Playback exception: $e");
      notifyListeners();
    }
  }

  void togglePlayPause() {
    if (_audioPlayer.playing) {
      _audioPlayer.pause();
    } else {
      _audioPlayer.play();
    }
    notifyListeners();
  }

  void playNext() {
    if (_currentQueue.isEmpty) return;
    if (_currentIndex < _currentQueue.length - 1) {
      _currentIndex++;
      playSong(_currentQueue[_currentIndex], queue: _currentQueue);
    } else if (_loopMode == LoopMode.all) {
      _currentIndex = 0;
      playSong(_currentQueue[0], queue: _currentQueue);
    }
  }

  void playPrevious() {
    if (_currentQueue.isEmpty) return;
    if (_currentIndex > 0) {
      _currentIndex--;
      playSong(_currentQueue[_currentIndex], queue: _currentQueue);
    }
  }

  void seek(Duration pos) => _audioPlayer.seek(pos);
  void forward10() => _audioPlayer.seek(_audioPlayer.position + const Duration(seconds: 10));
  void rewind10() => _audioPlayer.seek(_audioPlayer.position - const Duration(seconds: 10));

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _audioPlayer.setSpeed(speed);
    notifyListeners();
  }

  void toggleShuffle() {
    _isShiffle = !_isShiffle;
    if (_isShiffle && _currentQueue.isNotEmpty) {
      _currentQueue.shuffle();
      if (currentSong != null) {
        _currentIndex = _currentQueue.indexOf(currentSong!);
      }
    }
    notifyListeners();
  }

  void toggleLoop() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }
    notifyListeners();
  }

  void addToQueue(SongModel song) {
    _currentQueue.add(song);
    notifyListeners();
  }

  void playNextInQueue(SongModel song) {
    if (_currentIndex >= 0 && _currentIndex < _currentQueue.length) {
      _currentQueue.insert(_currentIndex + 1, song);
    } else {
      _currentQueue.add(song);
    }
    notifyListeners();
  }

  void removeFromQueue(int index) {
    if (index < _currentQueue.length) {
      _currentQueue.removeAt(index);
      if (index < _currentIndex) _currentIndex--;
      notifyListeners();
    }
  }

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _currentQueue.removeAt(oldIndex);
    _currentQueue.insert(newIndex, item);
    if (currentSong != null) {
      _currentIndex = _currentQueue.indexOf(currentSong!);
    }
    notifyListeners();
  }

  void clearQueue() {
    _currentQueue.clear();
    _currentIndex = -1;
    _audioPlayer.stop();
    notifyListeners();
  }

  bool isFavorite(int songId) => _favoriteBox.containsKey(songId);

  void toggleFavorite(int songId) {
    if (isFavorite(songId)) {
      _favoriteBox.delete(songId);
    } else {
      _favoriteBox.put(songId, true);
    }
    notifyListeners();
  }

  List<SongModel> getFavorites() => _songs.where((song) => isFavorite(song.id)).toList();

  List<SongModel> getRecentlyPlayed({int limit = 20}) {
    final keys = _historyBox.keys.toList();
    keys.sort((a, b) {
      final valA = _historyBox.get(a);
      final valB = _historyBox.get(b);
      final timeA = valA is int ? valA : DateTime.tryParse(valA.toString())?.millisecondsSinceEpoch ?? 0;
      final timeB = valB is int ? valB : DateTime.tryParse(valB.toString())?.millisecondsSinceEpoch ?? 0;
      return timeB.compareTo(timeA);
    });

    final List<SongModel> recents = [];
    for (final key in keys) {
      try {
        final song = _songs.firstWhere((s) => s.id == key);
        recents.add(song);
      } catch (_) {}
    }
    return recents.take(limit).toList();
  }

  List<SongModel> getRecentlyAdded() {
    final sorted = List<SongModel>.from(_songs);
    sorted.sort((a, b) => (b.dateAdded ?? 0).compareTo(a.dateAdded ?? 0));
    return sorted.take(20).toList();
  }

  List<SongModel> getMostPlayed({int limit = 20}) {
    final keys = _statsBox.keys.toList();
    keys.sort((a, b) {
      final countA = (_statsBox.get(a) as int?) ?? 0;
      final countB = (_statsBox.get(b) as int?) ?? 0;
      return countB.compareTo(countA);
    });

    final List<SongModel> mostPlayed = [];
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

  int getSongPlayCount(int songId) => (_statsBox.get(songId, defaultValue: 0) as int?) ?? 0;

  void clearMostPlayed() => clearPlayStatistics();

  void createPlaylist(String name) {
    if (!_playlistBox.containsKey(name)) {
      _playlistBox.put(name, <int>[]);
      notifyListeners();
    }
  }

  void renamePlaylist(String oldName, String newName) {
    if (_playlistBox.containsKey(oldName)) {
      final songs = _playlistBox.get(oldName);
      _playlistBox.delete(oldName);
      _playlistBox.put(newName, songs);
      notifyListeners();
    }
  }

  void deletePlaylist(String name) {
    _playlistBox.delete(name);
    notifyListeners();
  }

  void addSongToPlaylist(String name, int songId) {
    List<dynamic> list = _playlistBox.get(name, defaultValue: <int>[]);
    List<int> updated = List<int>.from(list);
    if (!updated.contains(songId)) {
      updated.add(songId);
      _playlistBox.put(name, updated);
      notifyListeners();
    }
  }

  void removeSongFromPlaylist(String name, int songId) {
    List<dynamic> list = _playlistBox.get(name, defaultValue: <int>[]);
    List<int> updated = List<int>.from(list);
    updated.remove(songId);
    _playlistBox.put(name, updated);
    notifyListeners();
  }

  List<SongModel> getPlaylistSongs(String name) {
    List<dynamic> ids = _playlistBox.get(name, defaultValue: <int>[]);
    return _songs.where((s) => ids.contains(s.id)).toList();
  }

  void clearHistory() {
    _historyBox.clear();
    notifyListeners();
  }

  void clearPlayStatistics() {
    _statsBox.clear();
    notifyListeners();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}