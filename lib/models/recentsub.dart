
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
class RecentSubView extends StatelessWidget {
  const RecentSubView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final recents = provider.getRecentlyPlayed();

    return Column(
      children: [
        if (recents.isNotEmpty)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => provider.clearHistory(),
              child: const Text("Clear History"),
            ),
          ),
        Expanded(
          child: recents.isEmpty
              ? const Center(child: Text("No history available"))
              : ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: recents.length,
            itemBuilder: (context, index) {
              final song = recents[index];
              return ListTile(
                leading: const Icon(Icons.history),
                title: Text(provider.getSongTitle(song)),
                subtitle: Text(song.artist ?? "Unknown"),
                onTap: () => provider.playSong(song, queue: recents),
              );
            },
          ),
        ),
      ],
    );
  }
}