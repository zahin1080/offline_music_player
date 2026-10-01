import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:minimal_music_player/providers/playlist_provider.dart';
class FavoritesSubView extends StatelessWidget {
  const FavoritesSubView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final favorites = provider.getFavorites();

    if (favorites.isEmpty) {
      return const Center(child: Text("No favorite songs added"));
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 90),
      itemCount: favorites.length,
      itemBuilder: (context, index) {
        final song = favorites[index];
        return ListTile(
          leading: const Icon(Icons.favorite, color: Colors.redAccent),
          title: Text(provider.getSongTitle(song)),
          subtitle: Text((song.artist == null || song.artist == '<unknown>') ? "Unknown Artist" : song.artist!,style: TextStyle(color: Colors.green),),
          onTap: () => provider.playSong(song, queue: favorites),
        );
      },
    );
  }
}

