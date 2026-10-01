import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/ui/screens/fullplayer.dart';

class MiniPlayerWidget extends StatelessWidget {
  const MiniPlayerWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final song = provider.currentSong;
    if (song == null) return const SizedBox.shrink();
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => const FullPlayerSheet(),
      ),
      child: Container(
        height: 72,
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(28),
              child: QueryArtworkWidget(
                id: song.id,
                type: ArtworkType.AUDIO,
                artworkWidth: 56,
                artworkHeight: 56,
                nullArtworkWidget: Container(
                  width: 56,
                  height: 56,
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  child: Icon(Icons.music_note, color: theme.colorScheme.primary),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.getSongTitle(song),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    provider.getSongArtist(song),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, color: theme.colorScheme.inversePrimary.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
              child: IconButton(
                icon: Icon(
                  provider.player.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
                onPressed: provider.togglePlayPause,
              ),
            ),
            const SizedBox(width: 4),
            IconButton(
              icon: Icon(Icons.close_rounded, color: theme.colorScheme.inversePrimary.withValues(alpha: 0.7), size: 24),
              onPressed: provider.clearQueue,
            ),
          ],
        ),
      ),
    );
  }
}

