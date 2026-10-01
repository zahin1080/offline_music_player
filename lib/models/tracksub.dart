import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:minimal_music_player/models/playlist_provider.dart';
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

    return ListView.builder(
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
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.music_note),
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
          subtitle: Text(song.artist ?? "Unknown Artist", maxLines: 1),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  provider.isFavorite(song.id)
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: provider.isFavorite(song.id)
                      ? Colors.redAccent
                      : Colors.grey,
                ),
                onPressed: () => provider.toggleFavorite(song.id),
              ),
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
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
                          Icon(Icons.edit, size: 20),
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
    );
  }
}