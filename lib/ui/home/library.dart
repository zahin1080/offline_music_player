import 'package:flutter/material.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:minimal_music_player/ui/screens/playlistsubscreen.dart';

import 'package:provider/provider.dart';
import 'package:minimal_music_player/ui/home/albumlist.dart';
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
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leadingWidth: 72,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Center(
              child: Container(
                height: 62,
                width: 100,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary.withValues(alpha: 0.15),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'images/Library Icons.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          bottom: TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.center,
            dividerColor: Colors.transparent,
            indicatorSize: TabBarIndicatorSize.label,
            indicator: UnderlineTabIndicator(
              borderSide: BorderSide(
                width: 3.0,
                color: theme.colorScheme.primary,
              ),
              borderRadius: BorderRadius.circular(2.0),
            ),
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.onSurface.withValues(
              alpha: 0.7,
            ),
            tabs: const [
              Tab(text: "Playlists"),
              Tab(text: "Albums"),
              Tab(text: "Artists"),
              Tab(text: "Folders"),
              Tab(text: "Favorites"),
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
            ],
          ),
        ),
      ),
    );
  }
}
