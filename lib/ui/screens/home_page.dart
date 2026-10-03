import 'package:flutter/material.dart';
import 'package:minimal_music_player/widgets/my_drawer.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:minimal_music_player/ui/screens/library.dart';
import 'package:minimal_music_player/ui/screens/tracksub.dart';
import 'package:minimal_music_player/ui/screens/search_screen.dart';
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

  Widget _buildNavIcon(IconData icon, bool isActive, ThemeData theme, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 28,
          color: isActive ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.5),
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
      length: 1,
      child: Scaffold(
        key: _scaffoldKey,
        backgroundColor: theme.colorScheme.surface,
        drawer: const MyDrawer(),
        appBar: _showLibrary ? null : AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.sort, color: theme.colorScheme.inversePrimary),
            onPressed: () => _scaffoldKey.currentState?.openDrawer(),
          ),
          title: Text(
            "HOME",
            style: TextStyle(
              color: theme.colorScheme.primary,
              letterSpacing: 2.5,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              shadows: [
                Shadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.6),
                  blurRadius: 15,
                )
              ],
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
          ],
          bottom: TabBar(
            isScrollable: true, tabAlignment: TabAlignment.center,
            tabs: const [
              Tab(text: "Tracks", icon: Icon(Icons.music_note_rounded, color: Colors.redAccent)),
            ],
            labelColor: theme.colorScheme.primary,
            unselectedLabelColor: theme.colorScheme.inversePrimary.withValues(alpha: 0.6),
            indicatorColor: theme.colorScheme.primary,
          ),
        ),
        body: Stack(
          children: [
            // Content
            Positioned.fill(
              child: _showLibrary 
                  ? const LibraryTabHost()
                  : TabBarView(
                      children: [
                        RefreshIndicator(
                          onRefresh: () async {
                            await musicProvider.requestPermissionAndFetch();
                          },
                          color: theme.colorScheme.primary,
                          backgroundColor: theme.colorScheme.surface,
                          child: const TracksSubView(),
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
                            color: theme.colorScheme.primary.withValues(alpha: 0.2),
                            blurRadius: 20,
                            spreadRadius: 2,
                            offset: const Offset(0, 4),
                          )
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildNavIcon(Icons.home_rounded, !_showLibrary, theme, () {
                            setState(() => _showLibrary = false);
                          }),
                          _buildNavIcon(Icons.my_library_music_rounded, _showLibrary, theme, () {
                            setState(() => _showLibrary = true);
                          }),
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
}
