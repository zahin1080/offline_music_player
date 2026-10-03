part of 'playlist_provider.dart';

extension MusicProviderInit on MusicProvider {
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
    notifyUI();

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
      notifyUI();
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
}
