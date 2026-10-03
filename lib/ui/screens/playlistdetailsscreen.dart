import 'package:minimal_music_player/utils/top_toast.dart';
import 'package:minimal_music_player/widgets/query_artwork_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:media_browser/media_browser.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';


class PlaylistDetailScreen extends StatelessWidget {
  final String playlistName;

  const PlaylistDetailScreen({super.key, required this.playlistName});

  void _showAddSongsModal(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => DefaultTabController(
        length: 2,
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Add to \"$playlistName\"",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              TabBar(
                indicatorColor: theme.colorScheme.inversePrimary,
                labelColor: theme.colorScheme.inversePrimary,
                tabs: const [
                  Tab(text: "From Songs"),
                  Tab(text: "From Albums"),
                ],
              ),
              Expanded(
                child: TabBarView(
                  children: [
                    Consumer<MusicProvider>(
                      builder: (_, p, _) {
                        final currentPlaylistSongs = p.getPlaylistSongs(playlistName);
                        final currentIds = currentPlaylistSongs.map((s) => s.id).toSet();

                        return ListView.builder(
                          itemCount: p.songs.length,
                          itemBuilder: (context, index) {
                            final song = p.songs[index];
                            final isAdded = currentIds.contains(song.id);

                            return ListTile(
                              leading: QueryArtworkWidget(
                                id: song.id,
                                type: ArtworkType.audio,
                                artworkWidth: 42,
                                artworkHeight: 42,
                                artworkBorder: BorderRadius.circular(6),
                                nullArtworkWidget: Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(Icons.music_note_rounded, color: Theme.of(context).colorScheme.primary),
                              ),
                              ),
                              title: Text(song.title, maxLines: 1),
                              subtitle: Text((song.artist == '<unknown>') ? "Unknown Artist" : song.artist),
                              trailing: IconButton(
                                icon: Icon(
                                  isAdded ? Icons.check_circle : Icons.add_circle_outline,
                                  color: isAdded
                                      ? Colors.greenAccent
                                      : theme.colorScheme.inversePrimary,
                                ),
                                onPressed: () {
                                  if (isAdded) {
                                    p.removeSongFromPlaylist(playlistName, song.id);
                                  } else {
                                    p.addSongToPlaylist(playlistName, song.id);
                                  }
                                },
                              ),
                            );
                          },
                        );
                      },
                    ),
                    Consumer<MusicProvider>(
                      builder: (_, p, _) {
                        return ListView.builder(
                          itemCount: p.albums.length,
                          itemBuilder: (context, index) {
                            final album = p.albums[index];
                            final albumSongs = p.songsForAlbum(album.album);

                            return ListTile(
                              leading: QueryArtworkWidget(
                                id: album.id,
                                type: ArtworkType.album,
                                artworkWidth: 42,
                                artworkHeight: 42,
                                artworkBorder: BorderRadius.circular(6),
                                nullArtworkWidget: const Icon(Icons.album),
                              ),
                              title: Text(album.album, maxLines: 1),
                              subtitle: Text("${albumSongs.length} tracks"),
                              trailing: ElevatedButton.icon(
                                icon: const Icon(Icons.add, size: 16),
                                label: const Text("Add All"),
                                onPressed: () {
                                  for (var track in albumSongs) {
                                    p.addSongToPlaylist(playlistName, track.id);
                                  }
                                  TopToast.show(context, "Added ${albumSongs.length} tracks from \"${album.album}\"");
},
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final songs = provider.getPlaylistSongs(playlistName);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        title: Text(playlistName),
        backgroundColor: theme.colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: "Add Tracks or Albums",
            onPressed: () => _showAddSongsModal(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (songs.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.inversePrimary,
                        foregroundColor: theme.colorScheme.surface,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      icon: const Icon(Icons.play_arrow),
                      label: Text("Play All (${songs.length})"),
                      onPressed: () => provider.playSong(songs.first, queue: songs),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.shuffle),
                    onPressed: () {
                      final shuffled = List<AudioModel>.from(songs)..shuffle();
                      provider.playSong(shuffled.first, queue: shuffled);
                    },
                  ),
                ],
              ),
            ),

          Expanded(
            child: songs.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.music_off_outlined,
                    size: 64,
                    color: theme.colorScheme.inversePrimary.withValues(alpha: 0.3),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "This playlist is empty",
                    style: TextStyle(
                      color: theme.colorScheme.inversePrimary.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text("Add Tracks / Albums"),
                    onPressed: () => _showAddSongsModal(context),
                  ),
                ],
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: songs.length,
              itemBuilder: (context, index) {
                final song = songs[index];
                final isCurrent = provider.currentSong?.id == song.id;

                return ListTile(
                  leading: QueryArtworkWidget(
                    id: song.id,
                    type: ArtworkType.audio,
                    artworkWidth: 44,
                    artworkHeight: 44,
                    artworkBorder: BorderRadius.circular(8),
                    nullArtworkWidget: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.secondary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.music_note,
                        color: theme.colorScheme.inversePrimary,
                      ),
                    ),
                  ),
                  title: Text(
                    song.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                      color: isCurrent ? theme.colorScheme.inversePrimary : null,
                    ),
                  ),
                  subtitle: Text(
                    (song.artist == '<unknown>') ? "Unknown Artist" : song.artist,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle_outline, size: 20),
                    tooltip: "Remove from playlist",
                    onPressed: () {
                      provider.removeSongFromPlaylist(playlistName, song.id);
                    },
                  ),
                  onTap: () => provider.playSong(song, queue: songs),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

