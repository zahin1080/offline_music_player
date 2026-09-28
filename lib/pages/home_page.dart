import 'package:flutter/material.dart';
import 'package:minimal_music_player/components/my_drawer.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/pages/playlist_screen.dart';
import 'package:minimal_music_player/pages/search_screen.dart';
import 'package:minimal_music_player/models/library.dart';
import 'package:minimal_music_player/pages/miniplayer.dart';
import 'package:provider/provider.dart';
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;

  final List<Widget> _views = const [
    LibraryTabHost(),
    SearchScreen(),
    PlaylistsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      drawer: const MyDrawer(),
      body: Stack(
        children: [
          _views[_currentIndex],
          if (musicProvider.currentSong != null)
            const Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: MiniPlayerWidget(),
            ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        backgroundColor: theme.colorScheme.surface,
        indicatorColor: theme.colorScheme.inversePrimary.withValues(alpha: 0.2),
        onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.library_music), label: 'Library'),
          NavigationDestination(icon: Icon(Icons.search), label: 'Search'),
          NavigationDestination(icon: Icon(Icons.playlist_play), label: 'Playlists'),
        ],
      ),
    );
  }
}