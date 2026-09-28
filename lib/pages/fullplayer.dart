import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

import 'package:on_audio_query/on_audio_query.dart';

import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class FullPlayerSheet extends StatelessWidget {
  const FullPlayerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final song = provider.currentSong;
    if (song == null) return const SizedBox.shrink();

    return Container(
      height: MediaQuery.of(context).size.height * 0.92,
      decoration: const BoxDecoration(
        color: Color(0xFF0F172A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Container(height: 4, width: 40, color: Colors.white24),
          const SizedBox(height: 20),
          Expanded(
            child: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkWidth: double.infinity,
              artworkHeight: 300,
              nullArtworkWidget: const Icon(Icons.album, size: 120, color: Colors.white24),
            ),
          ),
          Text(song.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          Text(song.artist ?? "Unknown", style: const TextStyle(color: Colors.white54)),
          const SizedBox(height: 16),
          // Queue Reordering Bottom View
          Expanded(
            child: ReorderableListView.builder(
              itemCount: provider.currentQueue.length,
              onReorder: provider.reorderQueue,
              itemBuilder: (context, index) {
                final track = provider.currentQueue[index];
                return ListTile(
                  key: ValueKey(track.id),
                  dense: true,
                  title: Text(track.title, maxLines: 1),
                  leading: const Icon(Icons.drag_handle, size: 18),
                  trailing: track.id == song.id
                      ? const Icon(Icons.volume_up, color: Color(0xFF38BDF8))
                      : null,
                );
              },
            ),
          ),
          StreamBuilder<Duration>(
            stream: provider.player.positionStream,
            builder: (context, snapshot) {
              final pos = snapshot.data ?? Duration.zero;
              final total = provider.player.duration ?? Duration.zero;
              return Slider(
                value: pos.inMilliseconds.clamp(0, total.inMilliseconds).toDouble(),
                max: total.inMilliseconds > 0 ? total.inMilliseconds.toDouble() : 1.0,
                onChanged: (val) => provider.player.seek(Duration(milliseconds: val.toInt())),
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.shuffle, color: provider.isShiffle ? const Color(0xFF38BDF8) : Colors.grey),
                onPressed: provider.toggleShuffle,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, size: 36),
                onPressed: provider.playPrevious,
              ),
              IconButton(
                icon: Icon(provider.player.playing ? Icons.pause_circle : Icons.play_circle, size: 54),
                onPressed: provider.togglePlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, size: 36),
                onPressed: provider.playNext,
              ),
              IconButton(
                icon: Icon(
                  provider.loopMode == LoopMode.one ? Icons.repeat_one : Icons.repeat,
                  color: provider.loopMode != LoopMode.off ? const Color(0xFF38BDF8) : Colors.grey,
                ),
                onPressed: provider.toggleLoop,
              ),
            ],
          ),
        ],
      ),
    );
  }
}