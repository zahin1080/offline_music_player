import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';

class DownloadsListView extends StatelessWidget {
  const DownloadsListView({super.key});

  String _formatDuration(int? durationMs) {
    if (durationMs == null) return "0:00";
    final d = Duration(milliseconds: durationMs);
    final minutes = d.inMinutes.remainder(60).toString();
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final downloads = provider.downloadedSongs;
    final theme = Theme.of(context);

    if (downloads.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.download_for_offline_outlined,
              size: 72,
              color: theme.colorScheme.inversePrimary.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              "No downloaded music found",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.inversePrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Audio files placed in your phone's 'Download' folder\nwill automatically appear here.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.inversePrimary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96, top: 8),
      itemCount: downloads.length,
      itemBuilder: (context, index) {
        final song = downloads[index];
        final isSelected = provider.currentSong?.id == song.id;

        return ListTile(
          leading: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
            artworkWidth: 48,
            artworkHeight: 48,
            artworkBorder: BorderRadius.circular(8),
            nullArtworkWidget: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.download_done, color: theme.colorScheme.inversePrimary),
            ),
          ),
          title: Text(
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? theme.colorScheme.inversePrimary : null,
            ),
          ),
          subtitle: Text(
            "${song.artist ?? 'Unknown Artist'} • ${_formatDuration(song.duration)}",
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: IconButton(
            icon: Icon(
              provider.isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
              color: provider.isFavorite(song.id) ? Colors.redAccent : Colors.green,
            ),
            onPressed: () => provider.toggleFavorite(song.id),
          ),
          onTap: () {
            provider.playSong(song, queue: downloads);
          },
        );
      },
    );
  }
}

