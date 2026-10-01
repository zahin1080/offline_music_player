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
                  color: Theme.of(context).colorScheme.inversePrimary.withValues(alpha: 0.7),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<SongSortOption>(
                    value: provider.currentSort,
                    icon: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: Icon(Icons.sort_rounded, size: 18, color: Theme.of(context).colorScheme.primary),
                    ),
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    items: const [
                      DropdownMenuItem(value: SongSortOption.title, child: Text("Name")),
                      DropdownMenuItem(value: SongSortOption.dateAdded, child: Text("Date Added")),
                      DropdownMenuItem(value: SongSortOption.artist, child: Text("Artist")),
                      DropdownMenuItem(value: SongSortOption.playCount, child: Text("Most Played")),
                      DropdownMenuItem(value: SongSortOption.duration, child: Text("Duration")),
                    ],
                    onChanged: (val) {
                      if (val != null) provider.sortSongs(val);
                    },
                  ),
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
                      icon: const Icon(Icons.more_vert_rounded),
                      onSelected: (val) {
                        if (val == "rename") {
                          _showRenameDialog(context, song);
                        } else {
                          provider.addSongToPlaylist(val, song.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Added to "$val"')),
                          );
                        }
                      },
                      itemBuilder: (context) {
                        final playlistNames =
                        provider.playlistBox.keys.cast<String>().toList();
                        return [
                          const PopupMenuItem(
                            value: "rename",
                            child: Row(
                              children: [
                                Icon(Icons.edit_rounded, size: 20),
                                SizedBox(width: 8),
                                Text("Rename Song"),
                              ],
                            ),
                          ),
                          const PopupMenuDivider(),
                          ...playlistNames.map(
                                (name) => PopupMenuItem(
                              value: name,
                              child: Text('Add to "$name"'),
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

