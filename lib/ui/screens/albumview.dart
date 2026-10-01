import 'package:flutter/material.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class AlbumsSubView extends StatelessWidget {
  const AlbumsSubView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final albums = provider.albums;

    if (albums.isEmpty) return const Center(child: Text("No albums found"));

    return GridView.builder(
      padding: const EdgeInsets.all(12).copyWith(bottom: 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Center(
                  child: QueryArtworkWidget(
                    id: album.id,
                    type: ArtworkType.ALBUM,
                    artworkWidth: double.infinity,
                    artworkHeight: double.infinity,
                    artworkBorder: const BorderRadius.vertical(top: Radius.circular(12)),
                    nullArtworkWidget: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      ),
                      child: Icon(Icons.album_rounded, size: 64, color: Theme.of(context).colorScheme.primary),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  (album.album.toLowerCase() == '<unknown>' || album.album.toLowerCase() == 'download') ? "Unknown Album" : album.album,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

