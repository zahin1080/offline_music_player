import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

class SmartSectionsView extends StatelessWidget {
  const SmartSectionsView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final recentSongs = provider.getRecentlyPlayed();
    final mostPlayedSongs = provider.getMostPlayed();

    return ListView(
      padding: const EdgeInsets.only(bottom: 120, top: 12),
      children: [
        _buildSection(
          context: context,
          title: "Recently Played",
          songs: recentSongs,
          onClear: recentSongs.isNotEmpty ? () => provider.clearHistory() : null,
        ),

        const SizedBox(height: 16),

        _buildSection(
          context: context,
          title: "Most Played",
          songs: mostPlayedSongs,
          onClear: mostPlayedSongs.isNotEmpty ? () => provider.clearPlayStatistics() : null,
        ),
      ],
    );
  }

  Widget _buildSection({
    required BuildContext context,
    required String title,
    required List<SongModel> songs,
    VoidCallback? onClear,
  }) {
    if (songs.isEmpty) return const SizedBox.shrink();
    final provider = context.read<MusicProvider>();
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              if (onClear != null)
                TextButton(
                  onPressed: onClear,
                  child: const Text("Clear", style: TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 175,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return GestureDetector(
                onTap: () => provider.playSong(song, queue: songs),
                child: Container(
                  width: 120,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        artworkWidth: 120,
                        artworkHeight: 120,
                        artworkBorder: BorderRadius.circular(12),
                        nullArtworkWidget: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.secondary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.music_off_sharp, size: 40, color: Colors.amberAccent),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        (song.artist == null || song.artist == '<unknown>') ? "Unknown Artist" : song.artist!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 11, color: theme.colorScheme.inversePrimary.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

