import 'package:flutter/material.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _query = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final cleanQuery = _query.trim().toLowerCase();

    final matchingSongs = cleanQuery.isEmpty
        ? <SongModel>[]
        : provider.songs
        .where((s) =>
    provider.getSongTitle(s).toLowerCase().contains(cleanQuery) ||
        (s.artist?.toLowerCase().contains(cleanQuery) ?? false))
        .toList();

    final matchingAlbums = cleanQuery.isEmpty
        ? <AlbumModel>[]
        : provider.albums
        .where((a) => a.album.toLowerCase().contains(cleanQuery))
        .toList();

    final matchingArtists = cleanQuery.isEmpty
        ? <ArtistModel>[]
        : provider.artists
        .where((ar) => ar.artist.toLowerCase().contains(cleanQuery))
        .toList();

    final playlistNames = provider.playlistBox.keys.cast<String>().toList();
    final matchingPlaylists = cleanQuery.isEmpty
        ? <String>[]
        : playlistNames
        .where((name) => name.toLowerCase().contains(cleanQuery))
        .toList();

    final bool hasResults = matchingSongs.isNotEmpty ||
        matchingAlbums.isNotEmpty ||
        matchingArtists.isNotEmpty ||
        matchingPlaylists.isNotEmpty;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.colorScheme.inversePrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _searchController,
          autofocus: true,
          style: TextStyle(color: theme.colorScheme.inversePrimary),
          decoration: InputDecoration(
            hintText: "Search songs, albums, artists...",
            hintStyle: TextStyle(
              color: theme.colorScheme.inversePrimary.withValues(alpha: 0.5),
            ),
            border: InputBorder.none,
          ),
          onChanged: (val) => setState(() => _query = val),
        ),
        actions: [
          if (_query.isNotEmpty)
            IconButton(
              icon: Icon(Icons.clear, color: theme.colorScheme.inversePrimary),
              onPressed: () {
                _searchController.clear();
                setState(() => _query = "");
              },
            ),
        ],
      ),
      body: cleanQuery.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 64,
              color: theme.colorScheme.inversePrimary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              "Search songs, artists, albums, and playlists",
              style: TextStyle(
                color: theme.colorScheme.inversePrimary.withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      )
          : !hasResults
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.music_off,
              size: 64,
              color: theme.colorScheme.inversePrimary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 12),
            Text(
              'No results found for "$_query"',
              style: TextStyle(
                color: theme.colorScheme.inversePrimary.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      )
          : ListView(
        padding: const EdgeInsets.only(bottom: 100),
        children: [
          // Songs Section
          if (matchingSongs.isNotEmpty) ...[
            _buildHeader("TRACKS (${matchingSongs.length})", theme),
            ...matchingSongs.map((song) {
              final isSelected = provider.currentSong?.id == song.id;
              return ListTile(
                leading: QueryArtworkWidget(
                  id: song.id,
                  type: ArtworkType.AUDIO,
                  artworkBorder: BorderRadius.circular(8),
                  nullArtworkWidget: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.music_note, color: theme.colorScheme.inversePrimary),
                  ),
                ),
                title: Text(
                  provider.getSongTitle(song),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? const Color(0xFF38BDF8) : null,
                  ),
                ),
                subtitle: Text((song.artist == null || song.artist == '<unknown>') ? "Unknown Artist" : song.artist!, maxLines: 1),
                trailing: IconButton(
                  icon: Icon(
                    provider.isFavorite(song.id) ? Icons.favorite : Icons.favorite_border,
                    color: provider.isFavorite(song.id) ? Colors.redAccent : Colors.grey,
                  ),
                  onPressed: () => provider.toggleFavorite(song.id),
                ),
                onTap: () => provider.playSong(song, queue: matchingSongs),
              );
            }),
          ],

          // Albums Section
          if (matchingAlbums.isNotEmpty) ...[
            _buildHeader("ALBUMS (${matchingAlbums.length})", theme),
            ...matchingAlbums.map((album) => ListTile(
              leading: QueryArtworkWidget(
                id: album.id,
                type: ArtworkType.ALBUM,
                artworkBorder: BorderRadius.circular(8),
                nullArtworkWidget: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.album, color: theme.colorScheme.inversePrimary),
                ),
              ),
              title: Text(album.album, maxLines: 1, overflow: TextOverflow.ellipsis),
              subtitle: Text("${album.numOfSongs} tracks"),
              onTap: () {
                final albumSongs = provider.songs
                    .where((s) => s.albumId == album.id)
                    .toList();
                if (albumSongs.isNotEmpty) {
                  provider.playSong(albumSongs.first, queue: albumSongs);
                }
              },
            )),
          ],

          if (matchingArtists.isNotEmpty) ...[
            _buildHeader("ARTISTS (${matchingArtists.length})", theme),
            ...matchingArtists.map((artist) => ListTile(
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.secondary,
                child: Icon(Icons.person, color: theme.colorScheme.inversePrimary),
              ),
              title: Text(artist.artist, maxLines: 1),
              subtitle: Text("${artist.numberOfTracks ?? 0} tracks"),
              onTap: () {
                final artistSongs = provider.songs
                    .where((s) => s.artistId == artist.id)
                    .toList();
                if (artistSongs.isNotEmpty) {
                  provider.playSong(artistSongs.first, queue: artistSongs);
                }
              },
            )),
          ],
          if (matchingPlaylists.isNotEmpty) ...[
            _buildHeader("PLAYLISTS (${matchingPlaylists.length})", theme),
            ...matchingPlaylists.map((name) {
              final pSongs = provider.getPlaylistSongs(name);
              return ListTile(
                leading: Icon(Icons.queue_music, color: theme.colorScheme.inversePrimary),
                title: Text(name, maxLines: 1),
                subtitle: Text("${pSongs.length} tracks"),
                onTap: () {
                  if (pSongs.isNotEmpty) {
                    provider.playSong(pSongs.first, queue: pSongs);
                  }
                },
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: theme.colorScheme.inversePrimary.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}

