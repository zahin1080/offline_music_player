import 'package:minimal_music_player/models/music_models.dart';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:media_browser/media_browser.dart' hide PermissionStatus;
import 'package:permission_handler/permission_handler.dart';
import 'package:minimal_music_player/services/library_service.dart';
import 'package:minimal_music_player/services/audio_service.dart';

enum SongSortOption { title, artist, dateAdded, duration, playCount }

class MusicProvider extends ChangeNotifier {
  final MediaBrowser _mediaBrowser = MediaBrowser();
  final LibraryService _libraryService = LibraryService();
  final AudioPlayerService _audioService = AudioPlayerService();
  final Map<String, List<AudioModel>> _folders = {};
  List<AudioModel> _songs = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<AudioModel> _currentQueue = [];
  int _currentIndex = -1;

  bool _isLoading = true;
  bool _hasPermissions = false;
  bool _isShiffle = false;
  double _playbackSpeed = 1.0;
  int _seekDuration = 10;
  int get seekDuration => _seekDuration;
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

  List<AudioModel> get songs => _songs;
  List<AlbumModel> get albums => _albums;
  List<ArtistModel> get artists => _artists;
  Map<String, List<AudioModel>> get folders => _folders;
  List<AudioModel> get currentQueue => _currentQueue;
  AudioModel? get currentSong =>
      (_currentIndex >= 0 && _currentIndex < _currentQueue.length)
      ? _currentQueue[_currentIndex]
      : null;

  AudioPlayer get player => _audioService.player;
  bool get isLoading => _isLoading;
  bool get hasPermission => _hasPermissions;
  bool get isPermanentlyDenied => _isPermanentlyDenied;
  bool get isShuffle => _isShiffle;
  LoopMode get loopMode => _loopMode;
  double get playbackSpeed => _playbackSpeed;
  String? get playbackError => _playbackError;
  Box get playlistBox => _playlistBox;
  SongSortOption get currentSort => _currentSort;

  List<AudioModel> get downloadedSongs {
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
    _seekDuration = _sessionBox.get('seekDuration', defaultValue: 10);
    _titlesBox = Hive.isBoxOpen('custom_titles')
        ? Hive.box('custom_titles')
        : await Hive.openBox('custom_titles');

    _audioService.player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (_loopMode == LoopMode.one) {
          _audioService.player.seek(Duration.zero);
          _audioService.player.play();
        } else {
          playNext();
        }
      }
    });

    _audioService.player.positionStream.listen((position) {
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
          Permission.manageExternalStorage,
        ].request().timeout(const Duration(seconds: 10));

        final aRes = statuses[Permission.audio];
        final sRes = statuses[Permission.storage];
        final mRes = statuses[Permission.manageExternalStorage];

        permissionGranted =
            (aRes?.isGranted ?? false) ||
            (sRes?.isGranted ?? false) ||
            (mRes?.isGranted ?? false);
        _isPermanentlyDenied =
            (aRes?.isPermanentlyDenied ?? false) ||
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

  static const String customFolderRoot = '/storage/emulated/0/Music';
  static const String _legacyCustomFolderRoot = '/storage/emulated/0/Download';

  List<String> get _customFolderNames {
    final List<dynamic> raw = _sessionBox.get(
      'customFolders',
      defaultValue: <String>[],
    );
    return raw.cast<String>().toList();
  }

  String customFolderPath(String name) {
    final musicDir = Directory('$customFolderRoot/$name');
    if (musicDir.existsSync()) return musicDir.path;
    final legacyDir = Directory('$_legacyCustomFolderRoot/$name');
    if (legacyDir.existsSync()) return legacyDir.path;
    return musicDir.path;
  }

  bool isCustomFolder(String name) => _customFolderNames.contains(name);

  List<AudioModel> songsForAlbum(String albumName) =>
      _songs.where((s) => LibraryService.albumNameOf(s) == albumName).toList();

  List<AudioModel> songsForArtist(String artistName) => _songs
      .where((s) => LibraryService.artistNameOf(s) == artistName)
      .toList();

  Future<void> rescanLibrary() async {
    try {
      await _libraryService.clearScanCache();
      final result = await _libraryService.scanLibrary(_customFolderNames);
      _songs = result.songs;
      _albums = result.albums;
      _artists = result.artists;
      _buildFolderIndex();
      _applySort();
    } catch (e) {
      log("Scan error: ");
    }
    notifyListeners();
  }

  void _buildFolderIndex() {
    _folders.clear();
    for (final name in _customFolderNames) {
      _folders[name] = [];
    }
    for (final song in _songs) {
      if (song.data.isEmpty) continue;
      try {
        final folderName = File(song.data).parent.path.split('/').last;
        if (folderName.isNotEmpty) {
          _folders.putIfAbsent(folderName, () => []).add(song);
        }
      } catch (_) {
        _folders.putIfAbsent("Internal Audio", () => []).add(song);
      }
    }
  }

  Future<String?> createCustomFolder(String name) async {
    final clean = name.trim().replaceAll(RegExp(r'[\\/:*?"<>|]'), '');
    if (clean.isEmpty) return 'Please enter a valid folder name';
    if (_folders.containsKey(clean)) return "Folder '$clean' already exists";

    try {
      if (!await Permission.manageExternalStorage.isGranted) {
        await Permission.manageExternalStorage.request();
      }
      final dir = Directory('$customFolderRoot/$clean');
      if (!dir.existsSync()) dir.createSync(recursive: true);
    } catch (e) {
      return 'Could not create folder. Allow "All files access" for this app.';
    }

    final names = _customFolderNames..add(clean);
    await _sessionBox.put('customFolders', names);
    _folders[clean] = [];
    notifyListeners();
    return null;
  }

  Future<int> addFilesToFolder(
    String folderName,
    List<String> sourcePaths,
  ) async {
    if (!await Permission.manageExternalStorage.isGranted) {
      await Permission.manageExternalStorage.request();
    }

    final targetDir = Directory(customFolderPath(folderName));
    if (!targetDir.existsSync()) targetDir.createSync(recursive: true);

    int copied = 0;
    for (final source in sourcePaths) {
      try {
        final src = File(source);
        if (!src.existsSync()) continue;
        String fileName = src.path.split('/').last;
        String targetPath = '${targetDir.path}/$fileName';

        if (src.absolute.path == File(targetPath).absolute.path) continue;

        int n = 1;
        while (File(targetPath).existsSync()) {
          final dot = fileName.lastIndexOf('.');
          final base = dot > 0 ? fileName.substring(0, dot) : fileName;
          final ext = dot > 0 ? fileName.substring(dot) : '';
          targetPath = '${targetDir.path}/$base ($n)$ext';
          n++;
        }

        await src.copy(targetPath);
        copied++;
        try {
          await _mediaBrowser.scanMedia(targetPath);
        } catch (_) {}
      } catch (e) {
        log('Copy error: $e');
      }
    }

    await rescanLibrary();
    return copied;
  }

  String getSongTitle(AudioModel song) {
    String title = _titlesBox.get(song.id, defaultValue: song.title) as String;
    if (title == '<unknown>') return 'Unknown Track';
    return title;
  }

  String getSongArtist(AudioModel song) {
    String artist = song.artist;
    if (artist == '<unknown>') return 'Unknown Artist';
    return artist;
  }

  Future<void> renameSong(AudioModel song, String newTitle) async {
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
        _songs.sort(
          (a, b) => getSongTitle(
            a,
          ).toLowerCase().compareTo(getSongTitle(b).toLowerCase()),
        );
        break;
      case SongSortOption.artist:
        _songs.sort(
          (a, b) =>
              (a.artist).toLowerCase().compareTo((b.artist).toLowerCase()),
        );
        break;
      case SongSortOption.dateAdded:
        _songs.sort((a, b) => (b.dateAdded).compareTo(a.dateAdded));
        break;
      case SongSortOption.duration:
        _songs.sort((a, b) => (b.duration).compareTo(a.duration));
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
          Uri.file(song.data),
          tag: MediaItem(
            id: song.id.toString(),
            album: song.album,
            title: getSongTitle(song),
            artist: (song.artist == '<unknown>')
                ? "Unknown Artist"
                : song.artist,
            artUri: Uri.parse(
              "content://media/external/audio/albumart/${song.id}",
            ),
          ),
        );
        _audioService.player.setAudioSource(
          audioSource,
          initialPosition: Duration(milliseconds: lastPositionMs),
        );
      }
    }
  }

  Future<void> playSong(
    AudioModel song, {
    List<AudioModel>? queue,
    Duration? startPosition,
  }) async {
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
        Uri.file(song.data),
        tag: MediaItem(
          id: song.id.toString(),
          album: LibraryService.albumNameOf(song),
          title: getSongTitle(song).trim().isNotEmpty
              ? getSongTitle(song)
              : "Unknown Title",
          artist: getSongArtist(song),
          artUri: null,
        ),
      );

      await _audioService.player.setAudioSource(
        audioSource,
        initialPosition: startPosition,
      );
      await _audioService.player.setSpeed(_playbackSpeed);
      _audioService.player.play();

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
    if (_audioService.player.playing) {
      _audioService.player.pause();
    } else {
      _audioService.player.play();
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

  void seek(Duration pos) => _audioService.player.seek(pos);
  void seekForward() => _audioService.player.seek(
    _audioService.player.position + Duration(seconds: _seekDuration),
  );
  void seekRewind() => _audioService.player.seek(
    _audioService.player.position - Duration(seconds: _seekDuration),
  );

  void setSeekDuration(int seconds) {
    _seekDuration = seconds;
    _sessionBox.put('seekDuration', seconds);
    notifyListeners();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _audioService.player.setSpeed(speed);
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

  void addToQueue(AudioModel song) {
    _currentQueue.add(song);
    notifyListeners();
  }

  void playNextInQueue(AudioModel song) {
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
    _audioService.player.stop();
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

  List<AudioModel> getFavorites() =>
      _songs.where((song) => isFavorite(song.id)).toList();

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
    sorted.sort((a, b) => (b.dateAdded).compareTo(a.dateAdded));
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

  List<AudioModel> getPlaylistSongs(String name) {
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
    _audioService.player.dispose();
    super.dispose();
  }

  double get volume => _audioService.player.volume;

  Future<void> setVolume(double vol) async {
    await _audioService.player.setVolume(vol.clamp(0.0, 1.0));
    notifyListeners();
  }
}
