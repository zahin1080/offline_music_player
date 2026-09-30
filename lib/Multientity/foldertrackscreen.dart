import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
class FolderTracksScreen extends StatelessWidget {
  final String folderName;
  final List<SongModel> songs;
  const FolderTracksScreen({super.key, required this.folderName, required this.songs});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(folderName),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: () => provider.playSong(songs.first, queue: songs),
          )
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.only(bottom: 90),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];
          return ListTile(
            leading: QueryArtworkWidget(id: song.id, type: ArtworkType.AUDIO),
            title: Text(song.title, maxLines: 1),
            subtitle: Text(song.artist ?? "Unknown"),
            onTap: () => provider.playSong(song, queue: songs),
          );
        },
      ),
    );
  }
}