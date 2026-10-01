import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final favorites = provider.getFavorites();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("FAVORITES", style: TextStyle(letterSpacing: 2)),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          if (favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.play_circle_fill, size: 28),
              onPressed: () => provider.playSong(favorites.first, queue: favorites),
            ),
        ],
      ),
      body: favorites.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite_border, size: 64, color: theme.colorScheme.inversePrimary.withValues(alpha: 0.4)),
            const SizedBox(height: 12),
            Text("No favorite songs yet", style: TextStyle(color: theme.colorScheme.inversePrimary)),
          ],
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.only(bottom: 100, top: 8),
        itemCount: favorites.length,
        separatorBuilder: (_, _) => const Divider(height: 1, indent: 72),
        itemBuilder: (context, index) {
          final song = favorites[index];
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
            subtitle: Text((song.artist == null || song.artist == '<unknown>') ? "Unknown Artist" : song.artist!, maxLines: 1),
            trailing: IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () => provider.toggleFavorite(song.id),
            ),
            onTap: () => provider.playSong(song, queue: favorites),
          );
        },
      ),
    );
  }
}

