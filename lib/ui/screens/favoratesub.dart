import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

class FavoritesSubView extends StatelessWidget {
  const FavoritesSubView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final favorites = provider.getFavorites();
    final theme = Theme.of(context);

    return Column(
      children: [
        if (favorites.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "${favorites.length} Liked Tracks",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(Icons.favorite_rounded, color: Colors.redAccent.withValues(alpha: 0.8), size: 24),
              ],
            ),
          ),
        Expanded(
          child: favorites.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 90, top: 8),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    final song = favorites[index];
                    final isCurrent = provider.currentSong?.id == song.id;
                    
                    final artistName = (song.artist == null || song.artist!.toLowerCase() == '<unknown>' || song.artist!.toLowerCase() == 'download' || song.artist!.trim().isEmpty) ? "Unknown Artist" : song.artist!;
                    final titleName = (song.title.toLowerCase() == '<unknown>' || song.title.toLowerCase() == 'download') ? "Unknown Track" : song.title;

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isCurrent ? theme.colorScheme.primary.withValues(alpha: 0.15) : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent ? theme.colorScheme.primary.withValues(alpha: 0.5) : theme.colorScheme.primary.withValues(alpha: 0.05),
                          width: 1,
                        ),
                        boxShadow: [
                          if (isCurrent)
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(alpha: 0.1),
                              blurRadius: 10,
                              spreadRadius: 1,
                            )
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Stack(
                            children: [
                              QueryArtworkWidget(
                                id: song.id,
                                type: ArtworkType.AUDIO,
                                artworkBorder: BorderRadius.circular(12),
                                nullArtworkWidget: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(Icons.music_note_rounded, color: theme.colorScheme.primary),
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.equalizer_rounded, color: Colors.white, size: 24),
                                  ),
                                )
                            ],
                          ),
                        ),
                        title: Text(
                          titleName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                            color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          artistName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isCurrent ? theme.colorScheme.primary.withValues(alpha: 0.8) : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 13,
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite_rounded, color: Colors.redAccent),
                          onPressed: () => provider.toggleFavorite(song.id),
                        ),
                        onTap: () => provider.playSong(song, queue: favorites),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_outline_rounded, size: 80, color: Colors.redAccent.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            "No Favorites Yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap the heart icon on any song to save it here!",
            style: TextStyle(fontSize: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          ),
        ],
      ),
    );
  }
}
