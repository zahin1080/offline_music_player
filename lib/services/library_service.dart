import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:media_browser/media_browser.dart';
import 'package:minimal_music_player/album_artist/albumartist.dart';

class LibraryScanResult {
  final List<AudioModel> songs;
  final List<Album1> albums;
  final List<Artist1> artists;

  LibraryScanResult({
    required this.songs,
    required this.albums,
    required this.artists,
  });
}

class LibraryService {
  final MediaBrowser _mediaBrowser = MediaBrowser();

  Future<void> clearScanCache() async {
    try {
      await _mediaBrowser.clearScanCache();
    } catch (_) {
      /* ignore */
    }
  }

  Future<LibraryScanResult> scanLibrary(List<String> customFolderNames) async {
    final rawSongs = await _mediaBrowser.queryAudios(
      options: const AudioQueryOptions(
        sortType: AudioSortType.title,
        sortOrder: SortOrder.ascending,
        ignoreCase: true,
      ),
    );
    return await compute(_processLibraryData, {
      'rawSongs': rawSongs.map((s) => s.toMap()).toList(),
      'customFolderNames': customFolderNames,
    });
  }

  static const String customFolderRoot = '/storage/emulated/0/Music';
  static const String _legacyCustomFolderRoot = '/storage/emulated/0/Download';
  static const Set<String> _audioExtensions = {
    'mp3',
    'm4a',
    'aac',
    'wav',
    'flac',
    'ogg',
    'opus',
    'amr',
    'wma',
    '3gp',
  };

  static String customFolderPath(String name) {
    final musicDir = Directory('$customFolderRoot/$name');
    if (musicDir.existsSync()) return musicDir.path;
    final legacyDir = Directory('$_legacyCustomFolderRoot/$name');
    if (legacyDir.existsSync()) return legacyDir.path;
    return musicDir.path;
  }

  static bool _isInCustomFolder(String path, List<String> folderNames) {
    final lower = path.toLowerCase();
    for (final name in folderNames) {
      if (lower.startsWith('${customFolderPath(name).toLowerCase()}/')) {
        return true;
      }
    }
    return false;
  }

  static bool _isAudioFile(String path) =>
      _audioExtensions.contains(path.split('.').last.toLowerCase());

  static String albumNameOf(AudioModel song) {
    String album = song.album.trim();
    if (album.isEmpty || album.toLowerCase() == '<unknown>') {
      try {
        album = File(song.data).parent.path.split('/').last;
      } catch (_) {
        album = '';
      }
    }
    if (album.isEmpty) return 'Unknown Album';
    if (album.toLowerCase() == 'download') return 'Downloads';
    return album;
  }

  static String artistNameOf(AudioModel song) {
    final artist = song.artist.trim();
    if (artist.isEmpty || artist.toLowerCase() == '<unknown>') {
      return 'Unknown Artist';
    }
    return artist;
  }

  static AudioModel _audioModelFromFile(File file) {
    final fileName = file.path.split('/').last;
    final dot = fileName.lastIndexOf('.');
    final baseName = dot > 0 ? fileName.substring(0, dot) : fileName;
    final ext = dot > 0 ? fileName.substring(dot + 1).toLowerCase() : '';
    final stat = file.statSync();
    final id = (file.path.hashCode & 0x3FFFFFFF) | 0x40000000;

    return AudioModel(
      id: id,
      title: baseName,
      artist: '<unknown>',
      album: file.parent.path.split('/').last,
      genre: '',
      duration: 0,
      data: file.path,
      size: stat.size,
      dateAdded: stat.modified.millisecondsSinceEpoch ~/ 1000,
      dateModified: stat.modified.millisecondsSinceEpoch ~/ 1000,
      track: 0,
      year: 0,
      albumArtist: '',
      composer: '',
      fileExtension: ext,
      displayName: baseName,
      mimeType: 'audio/$ext',
      isMusic: true,
      isRingtone: false,
      isAlarm: false,
      isNotification: false,
      isPodcast: false,
      isAudiobook: false,
    );
  }

  static LibraryScanResult _processLibraryData(Map<String, dynamic> params) {
    final List<dynamic> rawMaps = params['rawSongs'];
    final List<String> folderNames = params['customFolderNames'];

    final List<AudioModel> rawSongs = rawMaps
        .map((e) => AudioModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();

    final Map<String, AudioModel> byPath = {};

    for (final song in rawSongs) {
      if (song.data.isEmpty) continue;
      final lower = song.data.toLowerCase();
      if (!lower.contains('/download/') &&
          !_isInCustomFolder(song.data, folderNames)) {
        continue;
      }
      try {
        if (!File(song.data).existsSync()) continue;
      } catch (_) {
        /* ignore */
      }
      byPath.putIfAbsent(song.data, () => song);
    }

    for (final name in folderNames) {
      final dir = Directory(customFolderPath(name));
      if (!dir.existsSync()) continue;
      try {
        for (final entity in dir.listSync()) {
          if (entity is File &&
              _isAudioFile(entity.path) &&
              !byPath.containsKey(entity.path)) {
            byPath[entity.path] = _audioModelFromFile(entity);
          }
        }
      } catch (e) {
        /* ignore */
      }
    }

    final songs = byPath.values.toList();

    final Map<String, Album1> albumMap = {};
    final Map<String, int> albumCounts = {};
    final Map<String, Artist1> artistMap = {};
    final Map<String, int> artistCounts = {};

    for (final song in songs) {
      final albumName = albumNameOf(song);
      albumCounts[albumName] = (albumCounts[albumName] ?? 0) + 1;
      albumMap.putIfAbsent(
        albumName,
        () => Album1(id: song.id, album: albumName, artist: artistNameOf(song)),
      );

      final artistName = artistNameOf(song);
      artistCounts[artistName] = (artistCounts[artistName] ?? 0) + 1;
      artistMap.putIfAbsent(
        artistName,
        () => Artist1(id: song.id, artist: artistName),
      );
    }

    final albums =
        albumMap.entries
            .map(
              (e) => Album1(
                id: e.value.id,
                album: e.key,
                artist: e.value.artist,
                numOfSongs: albumCounts[e.key]!,
              ),
            )
            .toList()
          ..sort(
            (a, b) => a.album.toLowerCase().compareTo(b.album.toLowerCase()),
          );

    final artists =
        artistMap.entries
            .map(
              (e) => Artist1(
                id: e.value.id,
                artist: e.key,
                numberOfTracks: artistCounts[e.key]!,
              ),
            )
            .toList()
          ..sort(
            (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
          );

    return LibraryScanResult(songs: songs, albums: albums, artists: artists);
  }
}
