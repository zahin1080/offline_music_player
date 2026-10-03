import 'package:flutter/material.dart';

import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:minimal_music_player/ui/home/library.dart';
import 'package:minimal_music_player/ui/home/tracksub.dart';
import 'package:minimal_music_player/ui/screens/search_screen.dart';
import 'package:minimal_music_player/ui/Screen_settings/settins_page.dart';
import 'package:minimal_music_player/ui/screens/mostplayedsub.dart';
import 'package:minimal_music_player/ui/screens/recentsubscreen.dart';

import 'package:minimal_music_player/widgets/miniplayer.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _showLibrary = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Widget _buildNavIcon(
    IconData icon,
    bool isActive,
    ThemeData theme,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive
              ? theme.colorScheme.primary.withValues(alpha: 0.15)
              : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive
              ? theme.colorScheme.primary
              : theme.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final musicProvider = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    final isPlaying = musicProvider.currentSong != null;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.colorScheme.surface,
        appBar: _showLibrary
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
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
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.15,
                        ),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'images/Neon Home.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
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
                        MaterialPageRoute(builder: (_) => SearchScreen()),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    tooltip: "Settings",
                    color: theme.colorScheme.inversePrimary,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SettingsPage()),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                ],
              ),
        body: Stack(
          children: [
            // Content
            Positioned.fill(
              child: _showLibrary
                  ? const LibraryTabHost()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 16.0,
                            right: 16.0,
                            top: 8.0,
                            bottom: 16.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Your music",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Pick up where you left off",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.colorScheme.onSurface.withValues(
                                    alpha: 0.7,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        TabBar(
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
                          unselectedLabelColor: theme.colorScheme.onSurface
                              .withValues(alpha: 0.7),
                          tabs: const [
                            Tab(text: "Tracks"),
                            Tab(text: "Recently Played"),
                            Tab(text: "Most Played"),
                          ],
                        ),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildRefreshableTab(
                                context,
                                const TracksSubView(),
                              ),
                              _buildRefreshableTab(
                                context,
                                const RecentSubView(),
                              ),
                              _buildRefreshableTab(
                                context,
                                const MostPlayedSubView(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),

            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isPlaying) const MiniPlayerWidget(),
                    if (isPlaying) const SizedBox(height: 12),
                    Container(
                      height: 64,
                      width: 160,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surface,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.2,
                            ),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavIcon(
                            Icons.home_rounded,
                            !_showLibrary,
                            theme,
                            () {
                              setState(() => _showLibrary = false);
                            },
                          ),
                          _buildNavIcon(
                            Icons.my_library_music_rounded,
                            _showLibrary,
                            theme,
                            () {
                              setState(() => _showLibrary = true);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRefreshableTab(BuildContext context, Widget child) {
    final musicProvider = context.watch<MusicProvider>();
    final theme = Theme.of(context);
    return RefreshIndicator(
      onRefresh: () async {
        await musicProvider.requestPermissionAndFetch();
      },
      color: theme.colorScheme.primary,
      backgroundColor: theme.colorScheme.surface,
      child: child,
    );
  }
}
