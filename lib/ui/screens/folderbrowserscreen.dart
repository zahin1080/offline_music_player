import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/ui/screens/foldertrackscreen.dart';
class FolderBrowserScreen extends StatelessWidget {
  const FolderBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final folderEntries = provider.folders.entries.toList();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: const Text("FOLDERS", style: TextStyle(letterSpacing: 2)),
        backgroundColor: theme.colorScheme.surface,
      ),
      body: folderEntries.isEmpty
          ? Center(
        child: Text(
          "No audio folders found",
          style: TextStyle(color: theme.colorScheme.inversePrimary),
        ),
      )
          : ListView.separated(
        padding: const EdgeInsets.only(bottom: 100, top: 8),
        itemCount: folderEntries.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final folder = folderEntries[index];
          final folderName = folder.key;
          final songs = folder.value;

          return ListTile(
            leading: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.folder, color: theme.colorScheme.inversePrimary),
            ),
            title: Text(
              folderName,
              style: const TextStyle(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text("${songs.length} audio files"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FolderTracksScreen(
                    folderName: folderName,
                    songs: songs,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

