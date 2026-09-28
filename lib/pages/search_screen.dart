import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';

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
    final matches = provider.songs
        .where((s) =>
    s.title.toLowerCase().contains(_query.toLowerCase()) ||
        (s.artist?.toLowerCase().contains(_query.toLowerCase()) ?? false))
        .toList();

    return Column(
      children: [
        AppBar(
          backgroundColor: theme.colorScheme.surface,
          title: TextField(
            decoration: InputDecoration(
              hintText: "Search songs, artists...",
              hintStyle: TextStyle(color: theme.colorScheme.inversePrimary.withValues(alpha: 0.5)),
              border: InputBorder.none,
            ),
            onChanged: (val) => setState(() => _query = val),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 90),
            itemCount: matches.length,
            itemBuilder: (context, index) {
              final song = matches[index];
              return ListTile(
                title: Text(song.title),
                subtitle: Text(song.artist ?? "Unknown"),
                onTap: () => provider.playSong(song),
              );
            },
          ),
        ),
      ],
    );
  }
}