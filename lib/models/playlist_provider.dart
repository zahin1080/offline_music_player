import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

class MusicProvider extends ChangeNotifier {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();

  List<SongModel> _songs = [];
  List<AlbumModel> _albums = [];
  List<ArtistModel> _artists = [];
  List<SongModel> _currentQueue = [];
  int _currentIndex = -1;

  bool _isLoading = true;
  bool _hasPermissions = false;
  bool _isShiffle = false;
  LoopMode _loopMode = LoopMode.off;

  late final Box _favoriteBox;
  late final Box _historyBox;
  late final Box _playlistBox;

  List<SongModel> get songs => _songs;
  List<AlbumModel> get albums => _albums;
  List<ArtistModel> get artists => _artists;
  List<SongModel> get currentQueue => _currentQueue;
  SongModel? get currentSong =>
      (_currentIndex >= 0 && _currentIndex < _currentQueue.length)
          ? _currentQueue[_currentIndex]
          : null;
  AudioPlayer get player => _audioPlayer;
  bool get isLoading => _isLoading;
  bool get hasPermissions => _hasPermissions;

  // Both getters supported so UI calls to either spelling never fail
  bool get isShiffle => _isShiffle;
  bool get isShuffle => _isShiffle;

  LoopMode get loopMode => _loopMode;
  Box get playlistBox => _playlistBox;

  MusicProvider() {
    _initStorageAndAudio();
  }

  void _initStorageAndAudio() {
    _favoriteBox = Hive.box('favorites');
    _historyBox = Hive.box('history');
    _playlistBox = Hive.box('playlists');

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

    // Run permission request after initial widget tree attaches
    WidgetsBinding.instance.addPostFrameCallback((_) {
      requestPermissionAndFetch();
    });
  }

  Future<void> requestPermissionAndFetch() async {
    _isLoading = true;
    notifyListeners();

    bool permissionGranted = false;

    try {
      // 1. Check existing permission status first to avoid redundant system popups
      bool audioGranted = await Permission.audio.isGranted;
      bool storageGranted = await Permission.storage.isGranted;

      if (audioGranted || storageGranted) {
        permissionGranted = true;
      } else {
        // Request both simultaneously: Android 13+ responds to audio, Android 12 & below to storage
        final statuses = await [
          Permission.audio,
          Permission.storage,
        ].request().timeout(const Duration(seconds: 8));

        permissionGranted = (statuses[Permission.audio]?.isGranted ?? false) ||
            (statuses[Permission.storage]?.isGranted ?? false);
      }

      _hasPermissions = permissionGranted;

      // 2. Query songs, albums, and artists if permissions are granted
      if (_hasPermissions) {
        _songs = await _audioQuery
            .querySongs(
          sortType: SongSortType.TITLE,
          orderType: OrderType.ASC_OR_SMALLER,
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        )
            .timeout(const Duration(seconds: 12));

        _albums = await _audioQuery.queryAlbums().timeout(const Duration(seconds: 8));
        _artists = await _audioQuery.queryArtists().timeout(const Duration(seconds: 8));
      }
    } catch (e) {
      log("Query scan error: $e");
    } finally {
      // Guaranteed to terminate loading spinner even if query times out or user denies
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playSong(SongModel song, {List<SongModel>? queue}) async {
    try {
      _currentQueue = queue != null ? List.from(queue) : List.from(_songs);
      _currentIndex = _currentQueue.indexWhere((item) => item.id == song.id);

      final audioSource = AudioSource.uri(
        Uri.parse(song.uri!),
        tag: MediaItem(
          id: song.id.toString(),
          album: song.album ?? "Unknown Album",
          title: song.title,
          artist: song.artist ?? "Unknown Artist",
          artUri: Uri.parse("content://media/external/audio/albumart/${song.albumId}"),
        ),
      );

      await _audioPlayer.setAudioSource(audioSource);
      _audioPlayer.play();

      _historyBox.put(song.id, DateTime.now().toIso8601String());
      notifyListeners();
    } catch (e) {
      log("Error during playback initialization: $e");
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

  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) newIndex -= 1;
    final item = _currentQueue.removeAt(oldIndex);
    _currentQueue.insert(newIndex, item);
    if (currentSong != null) {
      _currentIndex = _currentQueue.indexOf(currentSong!);
    }
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

  List<SongModel> getFavorites() =>
      _songs.where((song) => isFavorite(song.id)).toList();

  // Playlists
  void createPlaylist(String name) {
    if (!_playlistBox.containsKey(name)) {
      _playlistBox.put(name, <int>[]);
      notifyListeners();
    }
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

  List<SongModel> getPlaylistSongs(String name) {
    List<dynamic> ids = _playlistBox.get(name, defaultValue: <int>[]);
    return _songs.where((s) => ids.contains(s.id)).toList();
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}