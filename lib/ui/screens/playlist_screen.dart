import 'package:flutter/material.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/ui/screens/playlistdetails.dart';

class PlaylistsScreen extends StatelessWidget {
  const PlaylistsScreen({super.key});

  void _showCreateDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("New Playlist"),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: "Playlist Name",
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel",style: TextStyle(color: Colors.blueAccent),),
          ),
          ElevatedButton(
            onPressed: () {
              final name = controller.text.trim();
              if (name.isNotEmpty) {
                context.read<MusicProvider>().createPlaylist(name);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Create",style: TextStyle(color: Colors.blueAccent),),
          ),
        ],
      ),
    );
  }

  void _showPlaylistOptions(BuildContext context, String playlistName) {
    final provider = context.read<MusicProvider>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text("Rename Playlist",style: TextStyle(color: Colors.blueAccent),),
              onTap: () {
                Navigator.pop(ctx);
                _showRenameDialog(context, playlistName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.redAccent),
              title: const Text("Delete Playlist", style: TextStyle(color: Colors.redAccent)),
              onTap: () {
                provider.deletePlaylist(playlistName);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(BuildContext context, String oldName) {
    final controller = TextEditingController(text: oldName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Rename Playlist",style: TextStyle(color: Colors.blueAccent),),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(border: OutlineInputBorder()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel",style: TextStyle(color: Colors.blueAccent),),
          ),
          ElevatedButton(
            onPressed: () {
              final newName = controller.text.trim();
              if (newName.isNotEmpty && newName != oldName) {
                context.read<MusicProvider>().renamePlaylist(oldName, newName);
                Navigator.pop(ctx);
              }
            },
            child: const Text("Save",style: TextStyle(color: Colors.deepOrangeAccent),),
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
          elevation: 0,
          title: Text(
            "P L A Y L I S T S",
            style: TextStyle(
              color: Colors.greenAccent,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              tooltip: "New Playlist",
              onPressed: () => _showCreateDialog(context),
            ),
          ],
        ),
        Expanded(
          child: playlistNames.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.queue_music,
                  size: 64,
                  color: theme.colorScheme.inversePrimary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 12),
                Text(
                  "No playlists created yet",
                  style: TextStyle(
                    color:Colors.blueAccent,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Create First Playlist",style: TextStyle(color: Colors.blueAccent),),
                  onPressed: () => _showCreateDialog(context),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 96, top: 8),
            itemCount: playlistNames.length,
            itemBuilder: (context, index) {
              final name = playlistNames[index];
              final songs = provider.getPlaylistSongs(name);

              return ListTile(
                leading: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: songs.isNotEmpty
                      ? QueryArtworkWidget(
                    id: songs.first.id,
                    type: ArtworkType.AUDIO,
                    artworkWidth: 48,
                    artworkHeight: 48,
                    artworkBorder: BorderRadius.circular(10),
                    nullArtworkWidget: Icon(
                      Icons.queue_music,
                      color: theme.colorScheme.inversePrimary,
                    ),
                  )
                      : Icon(
                    Icons.queue_music,
                    color: theme.colorScheme.inversePrimary,
                  ),
                ),
                title: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text("${songs.length} tracks"),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () => _showPlaylistOptions(context, name),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(playlistName: name),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

