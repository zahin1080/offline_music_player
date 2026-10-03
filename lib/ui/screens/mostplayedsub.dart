import 'package:minimal_music_player/utils/top_toast.dart';
import 'package:minimal_music_player/widgets/query_artwork_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:media_browser/media_browser.dart';

class MostPlayedSubView extends StatelessWidget {
  const MostPlayedSubView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final mostPlayed = provider.getMostPlayed();
    final theme = Theme.of(context);

    return Column(
      children: [
        if (mostPlayed.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Most Played Tracks",
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => _showClearDialog(context, provider, theme),
                  icon: Icon(
                    Icons.delete_sweep_rounded,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  label: Text(
                    "Clear",
                    style: TextStyle(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: theme.colorScheme.error.withValues(
                      alpha: 0.1,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        Expanded(
          child: mostPlayed.isEmpty
              ? _buildEmptyState(theme)
              : ListView.builder(
                  padding: const EdgeInsets.only(bottom: 90, top: 8),
                  itemCount: mostPlayed.length,
                  itemBuilder: (context, index) {
                    final song = mostPlayed[index];
                    final count = provider.getSongPlayCount(song.id);
                    final isCurrent = provider.currentSong?.id == song.id;

                    final artistName =
                        (song.artist.toLowerCase() == '<unknown>' ||
                            song.artist.toLowerCase() == 'download' ||
                            song.artist.trim().isEmpty)
                        ? "Unknown Artist"
                        : song.artist;
                    final titleName =
                        (song.title.toLowerCase() == '<unknown>' ||
                            song.title.toLowerCase() == 'download')
                        ? "Unknown Track"
                        : song.title;

                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: isCurrent
                            ? theme.colorScheme.primary.withValues(alpha: 0.15)
                            : theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent
                              ? theme.colorScheme.primary.withValues(alpha: 0.5)
                              : theme.colorScheme.primary.withValues(
                                  alpha: 0.05,
                                ),
                          width: 1,
                        ),
                        boxShadow: [
                          if (isCurrent)
                            BoxShadow(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.1,
                              ),
                              blurRadius: 10,
                              spreadRadius: 1,
                            ),
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        leading: SizedBox(
                          width: 50,
                          height: 50,
                          child: Stack(
                            children: [
                              QueryArtworkWidget(
                                id: song.id,
                                type: ArtworkType.audio,
                                artworkBorder: BorderRadius.circular(12),
                                nullArtworkWidget: Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(
                                      alpha: 0.1,
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.music_note_rounded,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              if (isCurrent)
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black.withValues(alpha: 0.5),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Center(
                                    child: Icon(
                                      Icons.equalizer_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        title: Text(
                          titleName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: isCurrent
                                ? FontWeight.bold
                                : FontWeight.w600,
                            color: isCurrent
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          "$artistName • Played $count times",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: isCurrent
                                ? theme.colorScheme.primary.withValues(
                                    alpha: 0.8,
                                  )
                                : theme.colorScheme.onSurface.withValues(
                                    alpha: 0.6,
                                  ),
                            fontSize: 13,
                          ),
                        ),
                        trailing: Icon(
                          Icons.play_arrow_rounded,
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.4,
                          ),
                        ),
                        onTap: () => provider.playSong(song, queue: mostPlayed),
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
          Icon(
            Icons.trending_up_rounded,
            size: 80,
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 16),
          Text(
            "No Top Tracks Yet",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Keep listening to build your stats!",
            style: TextStyle(
              fontSize: 14,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearDialog(
    BuildContext context,
    MusicProvider provider,
    ThemeData theme,
  ) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: theme.colorScheme.error),
              const SizedBox(width: 10),
              const Text(
                "Clear Statistics?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Text(
            "Are you sure you want to permanently reset your most played tracks count?",
            style: TextStyle(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                "Cancel",
                style: TextStyle(color: theme.colorScheme.onSurface),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                provider.clearMostPlayed();
                Navigator.pop(ctx);
                TopToast.show(context, "Statistics cleared!");
},
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "Clear",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}
