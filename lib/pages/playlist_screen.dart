import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';


class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("New Playlist"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "Playlist Name"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                context.read<MusicProvider>().createPlaylist(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text("Create"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final playlistNames = provider.playlistBox.keys.cast<String>().toList();
    final theme = Theme.of(context);

    return Column(
      children: [
        AppBar(
          backgroundColor: theme.colorScheme.surface,
          title: Text(
            "P L A Y L I S T S",
            style: TextStyle(color: theme.colorScheme.inversePrimary, letterSpacing: 2),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showCreateDialog(context),
            ),
          ],
        ),
        Expanded(
          child: playlistNames.isEmpty
              ? Center(
            child: Text(
              "No playlists created yet",
              style: TextStyle(color: theme.colorScheme.inversePrimary),
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: playlistNames.length,
            itemBuilder: (context, index) {
              final name = playlistNames[index];
              final songs = provider.getPlaylistSongs(name);

              return ListTile(
                leading: Icon(Icons.queue_music, color: theme.colorScheme.inversePrimary),
                title: Text(name),
                subtitle: Text("${songs.length} tracks"),
                onTap: () {
                  if (songs.isNotEmpty) {
                    provider.playSong(songs.first, queue: songs);
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}