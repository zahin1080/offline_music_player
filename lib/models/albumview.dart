import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class AlbumsGridView extends StatelessWidget {
  const AlbumsGridView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    return GridView.builder(
      padding: const EdgeInsets.all(16).copyWith(bottom: 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: provider.albums.length,
      itemBuilder: (context, index) {
        final album = provider.albums[index];
        return Card(
          color: const Color(0xFF1E293B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: QueryArtworkWidget(
                    id: album.id,
                    type: ArtworkType.ALBUM,
                    artworkBorder: const BorderRadius.vertical(top: Radius.circular(12)),
                    nullArtworkWidget: const Icon(Icons.album, size: 60, color: Colors.white24),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(album.album, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text(album.artist ?? "Unknown", maxLines: 1,
                        style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }
}