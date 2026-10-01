import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minimal_music_player/pages/queuereordersheet.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class FullPlayerSheet extends StatelessWidget {
  const FullPlayerSheet({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final song = provider.currentSong;

    if (song == null) return const SizedBox.shrink();

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(2))),


          if (provider.playbackError != null)
            Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(8),
              color: Colors.redAccent.withAlpha(50),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(child: Text(provider.playbackError!, style: const TextStyle(color: Colors.redAccent, fontSize: 12))),
                ],
              ),
            ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Album Art
                  Center(
                    child: QueryArtworkWidget(
                      id: song.id,
                      type: ArtworkType.AUDIO,
                      artworkWidth: 240,
                      artworkHeight: 240,
                      artworkBorder: BorderRadius.circular(20),
                      nullArtworkWidget: Container(
                        width: 240,
                        height: 240,
                        decoration: BoxDecoration(color: theme.colorScheme.secondary, borderRadius: BorderRadius.circular(20)),
                        child: const Icon(Icons.music_note, size: 80),
                      ),
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            Text(song.artist ?? "Unknown Artist", maxLines: 1, style: const TextStyle(color: Colors.grey)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(provider.isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
                            color: provider.isFavorite(song.id) ? Colors.redAccent : Colors.grey),
                        onPressed: () => provider.toggleFavorite(song.id),
                      ),
                    ],
                  ),

                  StreamBuilder<Duration>(
                    stream: provider.player.positionStream,
                    builder: (context, snapshot) {
                      final pos = snapshot.data ?? Duration.zero;
                      final total = provider.player.duration ?? Duration.zero;
                      return Column(
                        children: [
                          Slider(
                            min: 0,
                            max: total.inMilliseconds.toDouble() > 0 ? total.inMilliseconds.toDouble() : 1.0,
                            value: pos.inMilliseconds.clamp(0, total.inMilliseconds).toDouble(),
                            onChanged: (val) => provider.seek(Duration(milliseconds: val.toInt())),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_formatDuration(pos), style: const TextStyle(fontSize: 12)),
                              Text(_formatDuration(total), style: const TextStyle(fontSize: 12)),
                            ],
                          ),
                        ],
                      );
                    },
                  ),


                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.shuffle, color: provider.isShuffle ? theme.colorScheme.inversePrimary : Colors.grey),
                        onPressed: () => provider.toggleShuffle(),
                      ),
                      IconButton(icon: const Icon(Icons.replay_10), onPressed: () => provider.rewind10()),
                      IconButton(icon: const Icon(Icons.skip_previous, size: 36), onPressed: () => provider.playPrevious()),
                      IconButton(
                        icon: Icon(provider.player.playing ? Icons.pause_circle_filled : Icons.play_circle_filled, size: 54),
                        onPressed: () => provider.togglePlayPause(),
                      ),
                      IconButton(icon: const Icon(Icons.skip_next, size: 36), onPressed: () => provider.playNext()),
                      IconButton(icon: const Icon(Icons.forward_10), onPressed: () => provider.forward10()),
                      IconButton(
                        icon: Icon(provider.loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                            color: provider.loopMode != LoopMode.off ? theme.colorScheme.inversePrimary : Colors.blueAccent),
                        onPressed: () => provider.toggleLoop(),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          final nextSpeed = provider.playbackSpeed == 1.0 ? 1.5 : (provider.playbackSpeed == 1.5 ? 2.0 : 1.0);
                          provider.setPlaybackSpeed(nextSpeed);
                        },
                        child: Text("${provider.playbackSpeed}x Speed"),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.queue_music),
                        label: const Text("Queue",style: TextStyle(color: Colors.deepOrange),),
                        onPressed: () => _openQueueModal(context),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openQueueModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => const QueueReorderSheet(),
    );
  }
}