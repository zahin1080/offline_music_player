import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class SongsListView extends StatelessWidget {
  const SongsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
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
            nullArtworkWidget: const Icon(Icons.music_note, color: Colors.white54),
          ),
          title: Text(
            song.title,
            maxLines: 1,
            style: TextStyle(
              color: isSelected ? const Color(0xFF38BDF8) : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          subtitle: Text(song.artist ?? "Unknown Artist", maxLines: 1),
          trailing: IconButton(
            icon: Icon(
              provider.isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
              color: provider.isFavorite(song.id) ? Colors.redAccent : Colors.grey,
            ),
            onPressed: () => provider.toggleFavorite(song.id),
          ),
          onTap: () => provider.playSong(song),
        );
      },
    );
  }
}

