import 'package:flutter/material.dart';
import 'package:minimal_music_player/components/my_drawer.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/models/library.dart';
import 'package:minimal_music_player/pages/miniplayer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final isPlaying = musicProvider.currentSong != null;

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const MyDrawer(),
      body: Stack(
        children: [
          const LibraryTabHost(),

          if (isPlaying)
            const Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: SafeArea(
                top: false,
                child: MiniPlayerWidget(),
              ),
            ),
        ],
      ),
    );
  }
}