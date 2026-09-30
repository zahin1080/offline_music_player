import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:on_audio_query/on_audio_query.dart';
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);

    final matchingSongs = provider.songs
        .where((s) => s.title.toLowerCase().contains(_query.toLowerCase()) ||
        (s.artist?.toLowerCase().contains(_query.toLowerCase()) ?? false))
        .toList();

    final matchingAlbums = provider.albums
        .where((a) => a.album.toLowerCase().contains(_query.toLowerCase()))
        .toList();

    return Column(
      children: [
        AppBar(
          backgroundColor: theme.colorScheme.surface,
          title: TextField(
            decoration: InputDecoration(
              hintText: "Search songs, albums, artists...",
              hintStyle: TextStyle(color: theme.colorScheme.inversePrimary.withAlpha(128)),
              border: InputBorder.none,
            ),
            onChanged: (val) => setState(() => _query = val),
          ),
        ),
        if (_query.isEmpty)
          const Expanded(child: Center(child: Text("Type above to search local storage")))
        else
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 90),
              children: [
                if (matchingSongs.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text("SONGS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  ...matchingSongs.map((song) => ListTile(
                    leading: QueryArtworkWidget(id: song.id, type: ArtworkType.AUDIO),
                    title: Text(song.title, maxLines: 1),
                    subtitle: Text(song.artist ?? "Unknown"),
                    onTap: () => provider.playSong(song),
                  )),
                ],
                if (matchingAlbums.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text("ALBUMS", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  ),
                  ...matchingAlbums.map((album) => ListTile(
                    leading: QueryArtworkWidget(id: album.id, type: ArtworkType.ALBUM),
                    title: Text(album.album, maxLines: 1),
                    subtitle: Text("${album.numOfSongs} songs"),
                  )),
                ]
              ],
            ),
          ),
      ],
    );
  }
}