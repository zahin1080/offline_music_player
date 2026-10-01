import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';

class ArtistsSubView extends StatelessWidget {
  const ArtistsSubView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final artists = provider.artists;

    if (artists.isEmpty) return const Center(child: Text("No artists found"));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: artists.length,
      itemBuilder: (context, index) {
        final artist = artists[index];
        return ListTile(
          leading: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.person_rounded, color: Theme.of(context).colorScheme.primary),
          ),
          title: Text((artist.artist == '<unknown>') ? "Unknown Artist" : artist.artist),
          subtitle: Text("${artist.numberOfTracks ?? 0} tracks"),
        );
      },
    );
  }
}

