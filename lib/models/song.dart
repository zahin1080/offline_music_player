import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class SongsListView extends StatelessWidget {
  const SongsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);

    if (provider.songs.isEmpty) {
      return Center(
        child: Text(
          "No tracks found on device",
          style: TextStyle(color: theme.colorScheme.inversePrimary),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: provider.songs.length,
      itemBuilder: (context, index) {
        final song = provider.songs[index];
        final isSelected = provider.currentSong?.id == song.id;

        return ListTile(
          leading: QueryArtworkWidget(
            id: song.id,
            type: ArtworkType.AUDIO,
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
            song.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isSelected ? const Color(0xFF38BDF8) : null,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(
            song.artist ?? "Unknown Artist",
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
                onSelected: (playlistName) {
                  context.read<MusicProvider>().addSongToPlaylist(playlistName, song.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Added to "$playlistName"'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                itemBuilder: (context) {
                  final playlistNames =
                  context.read<MusicProvider>().playlistBox.keys.cast<String>().toList();
                  if (playlistNames.isEmpty) {
                    return const [
                      PopupMenuItem(
                        enabled: false,
                        child: Text("No playlists created yet"),
                      ),
                    ];
                  }
                  return playlistNames.map((name) {
                    return PopupMenuItem<String>(
                      value: name,
                      child: Text('Add to "$name"'),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          onTap: () => provider.playSong(song, queue: provider.songs),
        );
      },
    );
  }
}