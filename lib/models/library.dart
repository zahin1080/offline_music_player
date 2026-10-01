
import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/mostplayedsub.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:minimal_music_player/models/playlistsub.dart';
import 'package:minimal_music_player/models/recentsub.dart';
import 'package:minimal_music_player/models/tracksub.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/models/albumlist.dart';
import 'albumview.dart';
import 'favoratesub.dart';
import 'foldersub.dart';
import 'package:minimal_music_player/pages/search_screen.dart';

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
            Icon(Icons.folder_off, size: 64, color: theme.colorScheme.inversePrimary),
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
      length: 6,
      child: Column(
        children: [
          AppBar(
            backgroundColor: theme.colorScheme.surface,
            elevation: 0,

            leading: Builder(
              builder: (ctx) => IconButton(
                icon: const Icon(Icons.menu),
                color: theme.colorScheme.inversePrimary,
                tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                onPressed: () => Scaffold.of(ctx).openDrawer(),
              ),
            ),
            title: Text(
              "M Y  L I B R A R Y",
              style: TextStyle(
                color: Colors.greenAccent,
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
                color: Colors.indigo,
                onPressed: () => provider.requestPermissionAndFetch(),
              ),
            ],
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: theme.colorScheme.inversePrimary,
              labelColor: theme.colorScheme.inversePrimary,
              unselectedLabelColor: theme.colorScheme.inversePrimary.withAlpha(128),
              tabs: const [
                Tab(text: "Tracks"),
                Tab(text: "Playlists"),
                Tab(text: "Albums"),
                Tab(text: "Artists"),
                Tab(text: "Folders"),
                Tab(text: "Favorites"),
                Tab(text: "Recently Played",),
                Tab(text: "Most Played",)

              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
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
        ],
      ),
    );
  }
}