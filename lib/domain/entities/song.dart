import 'package:minimal_music_player/utils/top_toast.dart';
import 'package:minimal_music_player/widgets/query_artwork_widget.dart';
import 'package:flutter/material.dart';
import 'package:media_browser/media_browser.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class SongsListView extends StatelessWidget {
  const SongsListView({super.key});

  void _showRenameDialog(BuildContext context, AudioModel song) {
    final provider = context.read<MusicProvider>();
    final controller = TextEditingController(text: provider.getSongTitle(song));

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename Song"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: "Song Title",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                provider.renameSong(song, controller.text.trim());
              }
              Navigator.pop(context);
            },
            child: const Text("Save"),
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
      return Center(
        child: Text(
          "No tracks found on device",
          style: TextStyle(color: theme.colorScheme.inversePrimary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 96),
      itemCount: songs.length,
      itemBuilder: (context, index) {
        final song = songs[index];
        final isSelected = provider.currentSong?.id == song.id;

        return ListTile(
          leading: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.audio,
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
              child: Icon(Icons.music_note, color: theme.colorScheme.inversePrimary),
            ),
          ),
          title: Text(
            provider.getSongTitle(song),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? const Color(0xFF38BDF8) : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            (song.artist == '<unknown>') ? "Unknown Artist" : song.artist,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(
                  provider.isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
                  color: provider.isFavorite(song.id) ? Colors.redAccent : Colors.grey,
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
                    TopToast.show(context, 'Added to "$val"');
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
                    if (playlistNames.isEmpty)
                      const PopupMenuItem(
                        enabled: false,
                        child: Text("No playlists created yet"),
                      )
                    else
                      ...playlistNames.map(
                            (name) => PopupMenuItem<String>(
                          value: name,
                          child: Text('Add to "$name"'),
                        ),
                      ),
                  ];
                },
              ),
            ],
          ),
          onTap: () => provider.playSong(song, queue: songs),
        );
      },
    );
  }
}

