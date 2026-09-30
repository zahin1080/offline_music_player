import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimal_music_player/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();
    final musicProvider = context.watch<MusicProvider>();

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        title: Center(
          child: Text(
            "S E T T I N G S",
            style: TextStyle(
              color: Colors.greenAccent,
              letterSpacing: 2,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          _buildSectionHeader("APPEARANCE & THEME", theme),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(14),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: [
                SegmentedButton<ThemeMode>(
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode, size: 18),
                      label: Text("Light"),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode, size: 18),
                      label: Text("Dark"),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto, size: 18),
                      label: Text("System"),
                    ),
                  ],
                  selected: {themeProvider.themeMode},
                  onSelectionChanged: (Set<ThemeMode> newSelection) {
                    themeProvider.setThemeMode(newSelection.first);
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildSectionHeader("PLAYBACK SETTINGS", theme),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.speed, color: theme.colorScheme.inversePrimary),
                  title: const Text("Default Playback Speed"),
                  trailing: DropdownButton<double>(
                    value: musicProvider.playbackSpeed,
                    underline: const SizedBox.shrink(),
                    dropdownColor: theme.colorScheme.secondary,
                    items: const [
                      DropdownMenuItem(value: 0.75, child: Text("0.75x")),
                      DropdownMenuItem(value: 1.0, child: Text("1.0x")),
                      DropdownMenuItem(value: 1.25, child: Text("1.25x")),
                      DropdownMenuItem(value: 1.5, child: Text("1.5x")),
                      DropdownMenuItem(value: 2.0, child: Text("2.0x")),
                    ],
                    onChanged: (val) {
                      if (val != null) musicProvider.setPlaybackSpeed(val);
                    },
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.fast_forward, color: theme.colorScheme.inversePrimary),
                  title: const Text("Seek Step Duration"),
                  trailing: const Text("10 seconds", style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          _buildSectionHeader("LIBRARY STATISTICS", theme),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn("Tracks", "${musicProvider.songs.length}", theme),
                _buildStatColumn("Albums", "${musicProvider.albums.length}", theme),
                _buildStatColumn("Artists", "${musicProvider.artists.length}", theme),
                _buildStatColumn("Folders", "${musicProvider.folders.keys.length}", theme),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildSectionHeader("LIBRARY & DATA MANAGEMENT", theme),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.sync, color: theme.colorScheme.inversePrimary),
                  title: const Text("Rescan Library"),
                  subtitle: const Text("Scan device storage for new and deleted files"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Rescanning device music..."), duration: Duration(seconds: 1)),
                    );
                    await musicProvider.rescanLibrary();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Scan complete! Discovered ${musicProvider.songs.length} tracks.")),
                      );
                    }
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.history, color: Colors.orangeAccent),
                  title: const Text("Clear History"),
                  subtitle: const Text("Erase recently played song history"),
                  onTap: () => _confirmActionDialog(
                    context: context,
                    title: "Clear Play History?",
                    content: "This will erase your recently played logs.",
                    onConfirm: () => musicProvider.clearHistory(),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.bar_chart, color: Colors.redAccent),
                  title: const Text("Clear Play Statistics"),
                  subtitle: const Text("Reset all most-played counters"),
                  onTap: () => _confirmActionDialog(
                    context: context,
                    title: "Reset Statistics?",
                    content: "This will reset all song play-count statistics to zero.",
                    onConfirm: () => musicProvider.clearPlayStatistics(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          _buildSectionHeader("ABOUT", theme),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(Icons.info_outline, color: theme.colorScheme.inversePrimary),
                  title: const Text("App Version"),
                  trailing: const Text("v1.0.0+20", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(Icons.code, color: theme.colorScheme.inversePrimary),
                  title: const Text("Developed by Zahin"),
                  subtitle: const Text("Ahmed"),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showAboutAppDialog(context, theme),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
          color: theme.colorScheme.inversePrimary.withAlpha(180),
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: theme.colorScheme.inversePrimary)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  void _confirmActionDialog({
    required BuildContext context,
    required String title,
    required String content,
    required VoidCallback onConfirm,
  }) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text("Clear", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Music Player"),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close")),
        ],
      ),
    );
  }
}