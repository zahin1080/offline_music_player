import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:media_browser/media_browser.dart';

class AudioPlayerService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  
  AudioPlayer get player => _audioPlayer;

  Future<void> setAudioSource(AudioModel song, String title, String artist, String album, {Duration? initialPosition}) async {
    final audioSource = AudioSource.uri(
      Uri.file(song.data),
      tag: MediaItem(
        id: song.id.toString(),
        album: album,
        title: title,
        artist: artist,
        artUri: null,
      ),
    );
    await _audioPlayer.setAudioSource(audioSource, initialPosition: initialPosition);
  }

  Future<void> play() => _audioPlayer.play();
  Future<void> pause() => _audioPlayer.pause();
  Future<void> stop() => _audioPlayer.stop();
  Future<void> seek(Duration position) => _audioPlayer.seek(position);
  Future<void> setSpeed(double speed) => _audioPlayer.setSpeed(speed);
  Future<void> setVolume(double volume) => _audioPlayer.setVolume(volume);

  void dispose() {
    _audioPlayer.dispose();
  }
}
