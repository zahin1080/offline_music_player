import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
class MostPlayedSubView extends StatelessWidget {
  const MostPlayedSubView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final mostPlayed = provider.getMostPlayed();

    return Column(
      children: [
        if (mostPlayed.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => provider.clearMostPlayed(),
              child: const Text("Clear Statistics"),
            ),
          ),
        Expanded(
          child: mostPlayed.isEmpty
              ? const Center(child: Text("No track play records yet"))
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: mostPlayed.length,
            itemBuilder: (context, index) {
              final song = mostPlayed[index];
              final count = provider.getSongPlayCount(song.id);
              return ListTile(
                leading: Icon(Icons.trending_up, color: Theme.of(context).colorScheme.primary),
                title: Text(provider.getSongTitle(song)),
                subtitle: Text("${provider.getSongArtist(song)} • Played $count times"),
                onTap: () => provider.playSong(song, queue: mostPlayed),
              );
            },
          ),
        ),
      ],
    );
  }
}

