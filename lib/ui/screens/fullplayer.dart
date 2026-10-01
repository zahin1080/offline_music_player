import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:minimal_music_player/widgets/queuereordersheet.dart';
import 'package:on_audio_query/on_audio_query.dart';

import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class FullPlayerSheet extends StatelessWidget {
  const FullPlayerSheet({super.key});

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  void _openQueueModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => const QueueReorderSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final song = provider.currentSong;

    if (song == null) return const SizedBox.shrink();

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          // Drag handle
          Container(
            width: 48,
            height: 6,
            decoration: BoxDecoration(
              color: theme.colorScheme.inversePrimary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 24),

          if (provider.playbackError != null)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Colors.redAccent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      provider.playbackError!,
                      style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Massive Glowing Album Art
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(36),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.25),
                          blurRadius: 40,
                          spreadRadius: 8,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(36),
                      child: QueryArtworkWidget(
                        id: song.id,
                        type: ArtworkType.AUDIO,
                        artworkWidth: 320,
                        artworkHeight: 320,
                        nullArtworkWidget: Container(
                          width: 320,
                          height: 320,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          ),
                          child: Icon(Icons.music_note_rounded, size: 120, color: theme.colorScheme.primary),
                        ),
                      ),
                    ),
                  ),

                  // Song Title and Artist
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  provider.getSongTitle(song),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    color: theme.colorScheme.onSurface,
                                    letterSpacing: -0.5,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  provider.getSongArtist(song),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: theme.colorScheme.inversePrimary.withValues(alpha: 0.7),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            iconSize: 32,
                            icon: Icon(
                              provider.isFavorite(song.id) ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                              color: provider.isFavorite(song.id) ? Colors.redAccent : theme.colorScheme.inversePrimary.withValues(alpha: 0.5),
                            ),
                            onPressed: () => provider.toggleFavorite(song.id),
                          ),
                        ],
                      ),
                    ],
                  ),

                  // Progress Bar
                  StreamBuilder<Duration>(
                    stream: provider.player.positionStream,
                    builder: (context, snapshot) {
                      final pos = snapshot.data ?? Duration.zero;
                      final total = provider.player.duration ?? Duration.zero;
                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderThemeData(
                              trackHeight: 6,
                              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                              activeTrackColor: theme.colorScheme.primary,
                              inactiveTrackColor: theme.colorScheme.primary.withValues(alpha: 0.15),
                              thumbColor: theme.colorScheme.primary,
                            ),
                            child: Slider(
                              min: 0,
                              max: total.inMilliseconds.toDouble() > 0 ? total.inMilliseconds.toDouble() : 1.0,
                              value: pos.inMilliseconds.clamp(0, total.inMilliseconds).toDouble(),
                              onChanged: (val) => provider.seek(Duration(milliseconds: val.toInt())),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(_formatDuration(pos), style: TextStyle(fontSize: 13, color: theme.colorScheme.inversePrimary.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                                Text(_formatDuration(total), style: TextStyle(fontSize: 13, color: theme.colorScheme.inversePrimary.withValues(alpha: 0.7), fontWeight: FontWeight.w600)),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // Controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: Icon(Icons.skip_previous_rounded, color: theme.colorScheme.onSurface),
                        iconSize: 42,
                        onPressed: () => provider.playPrevious(),
                      ),
                      IconButton(
                        icon: Icon(Icons.fast_rewind_rounded, color: theme.colorScheme.onSurface),
                        iconSize: 32,
                        onPressed: () => provider.seekRewind(),
                      ),
                      
                      // Giant Play/Pause Button
                      GestureDetector(
                        onTap: () => provider.togglePlayPause(),
                        child: Container(
                          width: 76,
                          height: 76,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: theme.colorScheme.primary,
                            boxShadow: [
                              BoxShadow(
                                color: theme.colorScheme.primary.withValues(alpha: 0.4),
                                blurRadius: 20,
                                spreadRadius: 4,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: Icon(
                            provider.player.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                            size: 42,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      IconButton(
                        icon: Icon(Icons.fast_forward_rounded, color: theme.colorScheme.onSurface),
                        iconSize: 32,
                        onPressed: () => provider.seekForward(),
                      ),
                      IconButton(
                        icon: Icon(Icons.skip_next_rounded, color: theme.colorScheme.onSurface),
                        iconSize: 42,
                        onPressed: () => provider.playNext(),
                      ),
                    ],
                  ),

                  // Bottom Utilities
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.shuffle_rounded, color: provider.isShuffle ? theme.colorScheme.primary : theme.colorScheme.inversePrimary.withValues(alpha: 0.4)),
                        iconSize: 24,
                        onPressed: () => provider.toggleShuffle(),
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.inversePrimary.withValues(alpha: 0.8),
                        ),
                        icon: const Icon(Icons.speed_rounded, size: 20),
                        label: Text("${provider.playbackSpeed}x Speed"),
                        onPressed: () {
                          final nextSpeed = provider.playbackSpeed == 1.0 ? 1.5 : (provider.playbackSpeed == 1.5 ? 2.0 : 1.0);
                          provider.setPlaybackSpeed(nextSpeed);
                        },
                      ),
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                        ),
                        icon: const Icon(Icons.queue_music_rounded, size: 20),
                        label: const Text("Up Next", style: TextStyle(fontWeight: FontWeight.bold)),
                        onPressed: () => _openQueueModal(context),
                      ),
                      IconButton(
                        icon: Icon(
                          provider.loopMode == LoopMode.one ? Icons.repeat_one_rounded : Icons.repeat_rounded,
                          color: provider.loopMode != LoopMode.off ? theme.colorScheme.primary : theme.colorScheme.inversePrimary.withValues(alpha: 0.4),
                        ),
                        iconSize: 24,
                        onPressed: () => provider.toggleLoop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

