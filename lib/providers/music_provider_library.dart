part of 'playlist_provider.dart';

extension MusicProviderLibrary on MusicProvider {
  List<String> get _customFolderNames {
    final List<dynamic> raw = _sessionBox.get(
      'customFolders',
      defaultValue: <String>[],
    );
    return raw.cast<String>().toList();
  }

  String customFolderPath(String name) {
    final musicDir = Directory('${MusicProvider.customFolderRoot}/$name');
    if (musicDir.existsSync()) return musicDir.path;
    final legacyDir = Directory(
      '${MusicProvider._legacyCustomFolderRoot}/$name',
    );
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
      log("Scan error: $e");
    }
    notifyUI();
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
      final dir = Directory('${MusicProvider.customFolderRoot}/$clean');
      if (!dir.existsSync()) dir.createSync(recursive: true);
    } catch (e) {
      return 'Could not create folder. Allow "All files access" for this app.';
    }

    final names = _customFolderNames..add(clean);
    await _sessionBox.put('customFolders', names);
    _folders[clean] = [];
    notifyUI();
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
    notifyUI();
  }

  void sortSongs(SongSortOption sortOption) {
    _currentSort = sortOption;
    _applySort();
    notifyUI();
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
          (a, b) => a.artist.toLowerCase().compareTo(b.artist.toLowerCase()),
        );
        break;
      case SongSortOption.dateAdded:
        _songs.sort((a, b) => b.dateAdded.compareTo(a.dateAdded));
        break;
      case SongSortOption.duration:
        _songs.sort((a, b) => b.duration.compareTo(a.duration));
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
}
