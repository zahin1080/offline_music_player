import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/models/song.dart';
import 'package:minimal_music_player/models/albumview.dart';
import 'package:minimal_music_player/models/albumlist.dart';

class LibraryTabHost extends StatelessWidget {
  const LibraryTabHost({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MusicProvider>();
    final theme = Theme.of(context);


    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (kIsWeb) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.devices_other, size: 64, color: theme.colorScheme.inversePrimary),
              const SizedBox(height: 16),
              Text(
                "Offline Media Scanning Unavailable on Web",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.inversePrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Local device audio scanning requires native Android or iOS storage APIs. Please launch the app on an Android device or emulator.",
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.colorScheme.inversePrimary.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      );
    }

    if (!provider.hasPermissions) {
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
      length: 3,
      child: Column(
        children: [
          AppBar(
            backgroundColor: theme.colorScheme.surface,
            title: Text(
              "M Y  L I B R A R Y",
              style: TextStyle(color: theme.colorScheme.inversePrimary, letterSpacing: 2),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => provider.requestPermissionAndFetch(),
              ),
            ],
            bottom: TabBar(
              indicatorColor: theme.colorScheme.inversePrimary,
              labelColor: theme.colorScheme.inversePrimary,
              tabs: const [
                Tab(text: "Songs"),
                Tab(text: "Albums"),
                Tab(text: "Artists"),
              ],
            ),
          ),
          const Expanded(
            child: TabBarView(
              children: [
                SongsListView(),
                AlbumsGridView(),
                ArtistsListView(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}