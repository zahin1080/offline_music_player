import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/pages/fullplayer.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final song = provider.currentSong;
    if (song == null) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const FullPlayerSheet(),
      ),
      child: Container(
        height: 64,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [BoxShadow(color: Colors.black45, blurRadius: 8)],
        ),
        child: Row(
          children: [
            QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: const Icon(Icons.music_note),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            IconButton(
              icon: Icon(
                provider.player.playing ? Icons.pause : Icons.play_arrow,
                color: const Color(0xFF38BDF8),
              ),
              onPressed: provider.togglePlayPause,
            ),
          ],
        ),
      ),
    );
  }
}