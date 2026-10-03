part of 'playlist_provider.dart';

extension MusicProviderPlayback on MusicProvider {
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
          notifyUI();
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

      notifyUI();
    } catch (e) {
      _playbackError = "Unsupported or corrupted audio track";
      log("Playback exception: $e");
      notifyUI();
    }
  }

  void togglePlayPause() {
    if (_audioService.player.playing) {
      _audioService.player.pause();
    } else {
      _audioService.player.play();
    }
    notifyUI();
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
    notifyUI();
  }

  void setPlaybackSpeed(double speed) {
    _playbackSpeed = speed;
    _audioService.player.setSpeed(speed);
    notifyUI();
  }

  void toggleShuffle() {
    _isShiffle = !_isShiffle;
    if (_isShiffle && _currentQueue.isNotEmpty) {
      _currentQueue.shuffle();
      if (currentSong != null) {
        _currentIndex = _currentQueue.indexOf(currentSong!);
      }
    }
    notifyUI();
  }

  void toggleLoop() {
    if (_loopMode == LoopMode.off) {
      _loopMode = LoopMode.all;
    } else if (_loopMode == LoopMode.all) {
      _loopMode = LoopMode.one;
    } else {
      _loopMode = LoopMode.off;
    }
    notifyUI();
  }

  void addToQueue(AudioModel song) {
    _currentQueue.add(song);
    notifyUI();
  }

  void playNextInQueue(AudioModel song) {
    if (_currentIndex >= 0 && _currentIndex < _currentQueue.length) {
      _currentQueue.insert(_currentIndex + 1, song);
    } else {
      _currentQueue.add(song);
    }
    notifyUI();
  }

  void removeFromQueue(int index) {
    if (index < _currentQueue.length) {
      _currentQueue.removeAt(index);
      if (index < _currentIndex) _currentIndex--;
      notifyUI();
    }
  }

  void reorderQueue(int oldIndex, int newIndex) {
    final item = _currentQueue.removeAt(oldIndex);
    _currentQueue.insert(newIndex, item);
    if (currentSong != null) {
      _currentIndex = _currentQueue.indexOf(currentSong!);
    }
    notifyUI();
  }

  void clearQueue() {
    _currentQueue.clear();
    _currentIndex = -1;
    _audioService.player.stop();
    notifyUI();
  }

  Future<void> setVolume(double vol) async {
    await _audioService.player.setVolume(vol.clamp(0.0, 1.0));
    notifyUI();
  }
}
