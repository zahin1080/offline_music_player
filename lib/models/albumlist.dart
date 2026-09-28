import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';

class ArtistsListView extends StatelessWidget {
  const ArtistsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: provider.artists.length,
      itemBuilder: (context, index) {
        final artist = provider.artists[index];
        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Color(0xFF1E293B),
            child: Icon(Icons.person, color: Colors.white70),
          ),
          title: Text(artist.artist),
          subtitle: Text("${artist.numberOfTracks ?? 0} tracks"),
        );
      },
    );
  }
}