import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:minimal_music_player/providers/playlist_provider.dart';
class TracksSubView extends StatelessWidget {
  const TracksSubView({super.key});

  void _showRenameDialog(BuildContext context, SongModel song) {
    final provider = context.read<MusicProvider>();
    final controller = TextEditingController(text: provider.getSongTitle(song));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename Song"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: "Song Title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel",style: TextStyle(color: Colors.amberAccent),),


          ),
          ElevatedButton(
            onPressed: () {
              provider.renameSong(song, controller.text);
              Navigator.pop(context);
            },
            child: const Text("Save",style: TextStyle(color: Colors.indigo),),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final songs = provider.songs;

    if (songs.isEmpty) {
      return const Center(child: Text("No tracks found on storage",style: TextStyle(color: Colors.deepOrangeAccent),));
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "${songs.length} Tracks",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.inversePrimary.withValues(alpha: 0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: PopupMenuButton<SongSortOption>(
                  initialValue: provider.currentSort,
                  color: theme.colorScheme.surface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  position: PopupMenuPosition.under,
                  onSelected: (val) => provider.sortSongs(val),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        {
                          SongSortOption.title: "Name",
                          SongSortOption.dateAdded: "Date Added",
                          SongSortOption.artist: "Artist",
                          SongSortOption.playCount: "Most Played",
                          SongSortOption.duration: "Duration",
                        }[provider.currentSort] ?? "Name",
                        style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.sort_rounded, size: 18, color: theme.colorScheme.primary),
                    ],
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: SongSortOption.title, child: Text("Name")),
                    const PopupMenuItem(value: SongSortOption.dateAdded, child: Text("Date Added")),
                    const PopupMenuItem(value: SongSortOption.artist, child: Text("Artist")),
                    const PopupMenuItem(value: SongSortOption.playCount, child: Text("Most Played")),
                    const PopupMenuItem(value: SongSortOption.duration, child: Text("Duration")),
                  ],
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final isSelected = provider.currentSong?.id == song.id;

              return ListTile(
                leading: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  artworkBorder: BorderRadius.circular(8),
                  nullArtworkWidget: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.music_note_rounded, color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                title: Text(
                  provider.getSongTitle(song),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? Theme.of(context).colorScheme.primary : null,
                  ),
                ),
                subtitle: Text(provider.getSongArtist(song), maxLines: 1),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(
                        provider.isFavorite(song.id)
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: provider.isFavorite(song.id)
                            ? Colors.redAccent
                            : Colors.grey,
                      ),
                      onPressed: () => provider.toggleFavorite(song.id),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(Icons.more_vert_rounded, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      color: theme.colorScheme.surface,
                      elevation: 8,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.1), width: 1),
                      ),
                      position: PopupMenuPosition.under,
                      onSelected: (val) {
                        if (val == "rename") {
                          _showRenameDialog(context, song);
                        } else {
                          provider.addSongToPlaylist(val, song.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Added to "$val"'),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              backgroundColor: theme.colorScheme.surface,
                            ),
                          );
                        }
                      },
                      itemBuilder: (context) {
                        final playlistNames = provider.playlistBox.keys.cast<String>().toList();
                        return [
                          PopupMenuItem(
                            value: "rename",
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(Icons.edit_rounded, size: 18, color: theme.colorScheme.primary),
                                ),
                                const SizedBox(width: 16),
                                Text(
                                  "Rename Song",
                                  style: TextStyle(fontWeight: FontWeight.w600, color: theme.colorScheme.onSurface),
                                ),
                              ],
                            ),
                          ),
                          if (playlistNames.isNotEmpty) const PopupMenuDivider(),
                          if (playlistNames.isNotEmpty)
                            PopupMenuItem(
                              enabled: false,
                              height: 30,
                              child: Text(
                                "ADD TO PLAYLIST",
                                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface.withValues(alpha: 0.5), letterSpacing: 1.2),
                              ),
                            ),
                          ...playlistNames.map(
                            (name) => PopupMenuItem(
                              value: name,
                              child: Row(
                                children: [
                                  Icon(Icons.playlist_add_check_circle_rounded, size: 22, color: theme.colorScheme.primary.withValues(alpha: 0.8)),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      name, 
                                      style: TextStyle(fontWeight: FontWeight.w500, color: theme.colorScheme.onSurface.withValues(alpha: 0.9)), 
                                      overflow: TextOverflow.ellipsis
                                    )
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ];
                      },
                    ),
                  ],
                ),
                onTap: () => provider.playSong(song),
              );
            },
          ),
        ),
      ],
    );
  }
}

