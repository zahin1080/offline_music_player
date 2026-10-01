import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';

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
          leading: const CircleAvatar(child: Icon(Icons.person)),
          title: Text(artist.artist),
          subtitle: Text("${artist.numberOfTracks ?? 0} tracks"),
        );
      },
    );
  }
}