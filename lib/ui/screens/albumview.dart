import 'package:minimal_music_player/services/library_service.dart';
import 'package:minimal_music_player/widgets/query_artwork_widget.dart';
import 'package:flutter/material.dart';
import 'package:media_browser/media_browser.dart';
import 'package:minimal_music_player/models/music_models.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class AlbumsSubView extends StatelessWidget {
  const AlbumsSubView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final albums = provider.albums;
    final theme = Theme.of(context);

    if (albums.isEmpty) return const Center(child: Text("No albums found"));

    return GridView.builder(
      padding: const EdgeInsets.all(12).copyWith(bottom: 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: albums.length,
      itemBuilder: (context, index) {
        final album = albums[index];
        return InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AlbumDetailScreen(album: album)),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: QueryArtworkWidget(
                    id: album.id,
                    type: ArtworkType.audio,
                    artworkWidth: double.infinity,
                    artworkHeight: double.infinity,
                    artworkBorder: const BorderRadius.vertical(top: Radius.circular(16)),
                    nullArtworkWidget: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Icon(Icons.album_rounded, size: 64, color: theme.colorScheme.primary),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        album.album,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontWeight: FontWeight.bold, color: theme.colorScheme.onSurface),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${album.numOfSongs} ${album.numOfSongs == 1 ? 'track' : 'tracks'}",
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class AlbumDetailScreen extends StatelessWidget {
  final AlbumModel album;
  const AlbumDetailScreen({super.key, required this.album});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final songs = provider.songsForAlbum(album.album);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: theme.colorScheme.primary),
        title: Text(
          album.album,
          style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: songs.isEmpty
          ? null
          : FloatingActionButton(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
              onPressed: () => provider.playSong(songs.first, queue: songs),
              child: const Icon(Icons.play_arrow_rounded),
            ),
      body: songs.isEmpty
          ? const Center(child: Text("No tracks in this album"))
          : ListView.builder(
              padding: const EdgeInsets.only(bottom: 90),
              itemCount: songs.length,
              itemBuilder: (context, i) {
                final song = songs[i];
                final isPlaying = provider.currentSong?.id == song.id;
                return ListTile(
                  leading: QueryArtworkWidget(
                    id: song.id,
                    type: ArtworkType.audio,
                    artworkWidth: 48,
                    artworkHeight: 48,
                    artworkBorder: BorderRadius.circular(10),
                    nullArtworkWidget: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.music_note_rounded, color: theme.colorScheme.primary),
                    ),
                  ),
                  title: Text(
                    provider.getSongTitle(song),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                      color: isPlaying ? theme.colorScheme.primary : theme.colorScheme.onSurface,
                    ),
                  ),
                  subtitle: Text(LibraryService.artistNameOf(song), maxLines: 1),
                  onTap: () => provider.playSong(song, queue: songs),
                );
              },
            ),
    );
  }
}
