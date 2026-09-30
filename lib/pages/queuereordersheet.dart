import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';


class QueueReorderSheet extends StatelessWidget {
  const QueueReorderSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: [
          const Text("Play Queue", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(height: 8),
          Expanded(
            child: ReorderableListView.builder(
              itemCount: provider.currentQueue.length,
              onReorder: (oldIdx, newIdx) => provider.reorderQueue(oldIdx, newIdx),
              itemBuilder: (context, index) {
                final track = provider.currentQueue[index];
                final isCurrent = provider.currentSong?.id == track.id;
                return ListTile(
                  key: ValueKey(track.id),
                  leading: Icon(isCurrent ? Icons.volume_up : Icons.music_note),
                  title: Text(track.title, maxLines: 1),
                  subtitle: Text(track.artist ?? "Unknown"),
                  trailing: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => provider.removeFromQueue(index),
                  ),
                  onTap: () => provider.playSong(track, queue: provider.currentQueue),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}