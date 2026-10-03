import 'package:flutter/material.dart';
import 'package:minimal_music_player/ui/screens/mostplayedsub.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:minimal_music_player/ui/screens/playlistsub.dart';
import 'package:minimal_music_player/ui/screens/recentsub.dart';

import 'package:provider/provider.dart';
import 'package:minimal_music_player/ui/screens/albumlist.dart';
import 'albumview.dart';
import 'favoratesub.dart';
import 'foldersub.dart';

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
      length: 7,
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
            "LIBRARY",
            style: TextStyle(
              color: theme.colorScheme.primary,
              letterSpacing: 2.5,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  blurRadius: 15,
                ),
              ],
            ),
          ),

          bottom: TabBar(
            isScrollable: true,

            tabs: const [
              Tab(
                text: "Playlists",
                icon: Icon(Icons.queue_music_rounded, color: Colors.redAccent),
              ),
              Tab(
                text: "Albums",
                icon: Icon(Icons.album_rounded, color: Colors.redAccent),
              ),
              Tab(
                text: "Artists",
                icon: Icon(Icons.person_rounded, color: Colors.redAccent),
              ),
              Tab(
                text: "Folders",
                icon: Icon(Icons.folder_rounded, color: Colors.redAccent),
              ),
              Tab(
                text: "Favorites",
                icon: Icon(Icons.favorite_rounded, color: Colors.redAccent),
              ),
              Tab(
                text: "Recently Played",
                icon: Icon(Icons.history_rounded, color: Colors.redAccent),
              ),
              Tab(
                text: "Most Played",
                icon: Icon(Icons.trending_up_rounded, color: Colors.redAccent),
              ),
            ],
          ),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            await provider.requestPermissionAndFetch();
          },
          color: theme.colorScheme.primary,
          backgroundColor: theme.colorScheme.surface,
          child: const TabBarView(
            children: [
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
      ),
    );
  }
}
