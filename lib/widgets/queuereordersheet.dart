import 'package:flutter/material.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';

class QueueReorderSheet extends StatelessWidget {
  const QueueReorderSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 50,
            height: 5,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Text(
            "Up Next",
            style: TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 22,
              letterSpacing: 1.2,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${provider.currentQueue.length} Tracks in Queue",
            style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          Expanded(
            child: ReorderableListView.builder(
              padding: const EdgeInsets.only(bottom: 24, top: 8),
              proxyDecorator: (child, index, animation) {
                return Material(
                  color: Colors.transparent,
                  elevation: 10,
                  shadowColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                  child: child,
                );
              },
              itemCount: provider.currentQueue.length,
              onReorderItem: (oldIdx, newIdx) => provider.reorderQueue(oldIdx, newIdx),
              itemBuilder: (context, index) {
                final track = provider.currentQueue[index];
                final isCurrent = provider.currentSong?.id == track.id;
                final artistName = (track.artist == null || track.artist!.toLowerCase() == '<unknown>' || track.artist!.toLowerCase() == 'download' || track.artist!.trim().isEmpty) ? "Unknown Artist" : track.artist!;
                final titleName = (track.title.toLowerCase() == '<unknown>' || track.title.toLowerCase() == 'download') ? "Unknown Track" : track.title;

                return Container(
                  key: ValueKey(track.id),
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  decoration: BoxDecoration(
                    color: isCurrent ? theme.colorScheme.primary.withValues(alpha: 0.1) : theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: isCurrent ? Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 1) : null,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                      child: Stack(
                        children: [
                          QueryArtworkWidget(
                            id: track.id,
                            type: ArtworkType.AUDIO,
                            artworkBorder: BorderRadius.circular(10),
                            nullArtworkWidget: Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(Icons.music_note_rounded, color: theme.colorScheme.primary),
                            ),
                          ),
                          if (isCurrent)
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.4),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Center(
                                child: Icon(Icons.equalizer_rounded, color: Colors.white, size: 24),
                              ),
                            )
                        ],
                      ),
                    ),
                    title: Text(
                      titleName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: isCurrent ? FontWeight.bold : FontWeight.w600,
                        color: isCurrent ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                      ),
                    ),
                    subtitle: Text(
                      artistName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: isCurrent ? theme.colorScheme.primary.withValues(alpha: 0.8) : theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: theme.colorScheme.error.withValues(alpha: 0.7)),
                          onPressed: () => provider.removeFromQueue(index),
                        ),
                        
                      ],
                    ),
                    onTap: () => provider.playSong(track, queue: provider.currentQueue),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
