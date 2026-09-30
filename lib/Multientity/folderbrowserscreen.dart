import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/Multientity/foldertrackscreen.dart';
class FolderBrowserScreen extends StatelessWidget {
  const FolderBrowserScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final folderEntries = provider.folders.entries.toList();

    if (folderEntries.isEmpty) {
      return Scaffold(
        backgroundColor: theme.colorScheme.surface,
        appBar: AppBar(title: const Text("FOLDERS"), backgroundColor: theme.colorScheme.surface),
        body: const Center(child: Text("No directories containing audio discovered")),
      );
    }

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(title: const Text("FOLDERS"), backgroundColor: theme.colorScheme.surface),
      body: ListView.separated(
        padding: const EdgeInsets.only(bottom: 90),
        itemCount: folderEntries.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final folder = folderEntries[index];
          return ListTile(
            leading: Icon(Icons.folder, color: theme.colorScheme.inversePrimary),
            title: Text(folder.key, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text("${folder.value.length} audio files"),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FolderTracksScreen(folderName: folder.key, songs: folder.value),
                ),
              );
            },
          );
        },
      ),
    );
  }
}