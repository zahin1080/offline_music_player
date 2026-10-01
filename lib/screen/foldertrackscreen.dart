import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FolderTracksScreen extends StatelessWidget {
  final String folderName;
  final List<SongModel> songs;

  const FolderTracksScreen({
    super.key,
    required this.folderName,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(folderName, maxLines: 1),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          if (songs.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.play_circle_fill, size: 28),
              onPressed: () => provider.playSong(songs.first, queue: songs),
            ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: songs.length,
        separatorBuilder: (_, __) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final song = songs[index];
          final isCurrent = provider.currentSong?.id == song.id;

          return ListTile(
            leading: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              artworkBorder: BorderRadius.circular(8),
              nullArtworkWidget: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.music_note, color: theme.colorScheme.inversePrimary),
              ),
            ),
            title: Text(
              song.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                color: isCurrent ? theme.colorScheme.primary : null,
              ),
            ),
            subtitle: Text(song.artist ?? "Unknown", maxLines: 1),
            trailing: IconButton(
              icon: Icon(
                provider.isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
                color: provider.isFavorite(song.id) ? Colors.red : Colors.grey,
              ),
              onPressed: () => provider.toggleFavorite(song.id),
            ),
            onTap: () => provider.playSong(song, queue: songs),
          );
        },
      ),
    );
  }
}