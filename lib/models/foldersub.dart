import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:minimal_music_player/models/playlist_provider.dart';

class FoldersSubView extends StatelessWidget {
  const FoldersSubView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final folders = provider.folders.entries.toList();

    if (folders.isEmpty) return const Center(child: Text("No folders found"));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: folders.length,
      itemBuilder: (context, index) {
        final folder = folders[index];
        return ListTile(
          leading: const Icon(Icons.folder),
          title: Text(folder.key, maxLines: 1),
          subtitle: Text("${folder.value.length} audio files"),
          trailing: const Icon(Icons.arrow_forward_ios, size: 14),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: Text(folder.key)),
                  body: ListView.builder(
                    itemCount: folder.value.length,
                    itemBuilder: (ctx, idx) {
                      final song = folder.value[idx];
                      return ListTile(
                        leading: const Icon(Icons.music_video_outlined),
                        title: Text(provider.getSongTitle(song)),
                        subtitle: Text(song.artist ?? "Unknown",style: TextStyle(color: Colors.green),),
                        onTap: () => provider.playSong(song, queue: folder.value),
                      );
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}