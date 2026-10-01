import 'package:flutter/material.dart';
import 'package:minimal_music_player/ui/screens/mostplayedsub.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:minimal_music_player/ui/screens/playlistsub.dart';
import 'package:minimal_music_player/ui/screens/recentsub.dart';
import 'package:minimal_music_player/ui/screens/tracksub.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/ui/screens/albumlist.dart';
import 'albumview.dart';
import 'favoratesub.dart';
import 'foldersub.dart';
import 'package:minimal_music_player/ui/screens/search_screen.dart';

class LibraryTabHost extends StatelessWidget {
  const LibraryTabHost({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);

    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!provider.hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.folder_off,
              size: 64,
              color: theme.colorScheme.inversePrimary,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => provider.requestPermissionAndFetch(),
              child: const Text("Grant Audio Permission"),
            ),
          ],
        ),
      );
    }

    return DefaultTabController(
      length: 8, // Fixed from 6 to 8 to match the number of tabs
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu),
            color: theme.colorScheme.inversePrimary,
            tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
          title: Text(
            "L I B R A R Y",
            style: TextStyle(
              color: theme.colorScheme.primary,
              letterSpacing: 2,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.search),
              tooltip: "Search",
              color: theme.colorScheme.inversePrimary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SearchScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.refresh),
              color: theme.colorScheme.primary,
              onPressed: () => provider.requestPermissionAndFetch(),
            ),
          ],
          bottom: TabBar(
            isScrollable: true,

            tabs: const [
              Tab(text: "Tracks"),
              Tab(text: "Playlists"),
              Tab(text: "Albums"),
              Tab(text: "Artists"),
              Tab(text: "Folders"),
              Tab(text: "Favorites"),
              Tab(text: "Recently Played"),
              Tab(text: "Most Played"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TracksSubView(),
            PlaylistsSubView(),
            AlbumsSubView(),
            ArtistsSubView(),
            FoldersSubView(),
            FavoritesSubView(),
            RecentSubView(),
            MostPlayedSubView(),
          ],
        ),
      ),
    );
  }
}

