import 'package:minimal_music_player/album_artist/albumartist.dart';
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
part 'music_provider_init.dart';
part 'music_provider_library.dart';
part 'music_provider_playback.dart';
part 'music_provider_playlists.dart';
part 'music_provider_stats.dart';

enum SongSortOption { title, artist, dateAdded, duration, playCount }

class MusicProvider extends ChangeNotifier {
  final MediaBrowser _mediaBrowser = MediaBrowser();
  final LibraryService _libraryService = LibraryService();
  final AudioPlayerService _audioService = AudioPlayerService();
  final Map<String, List<AudioModel>> _folders = {};
  List<AudioModel> _songs = [];
  List<Album1> _albums = [];
  List<Artist1> _artists = [];
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

  static const String customFolderRoot =
      '/storage/emulated/0/Music/MinimalMusicPlayer';
  static const String _legacyCustomFolderRoot = '/storage/emulated/0/Music';

  List<AudioModel> get songs => _songs;
  List<Album1> get albums => _albums;
  List<Artist1> get artists => _artists;
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
  void notifyUI() => notifyListeners();

  @override
  void dispose() {
    _audioService.player.dispose();
    super.dispose();
  }
}
