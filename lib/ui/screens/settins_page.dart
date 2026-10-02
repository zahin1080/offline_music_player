import 'package:flutter/material.dart';
import 'package:minimal_music_player/core/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';

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
        title: Text(
          "SETTINGS",
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
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        children: [
          _buildSectionHeader("APPEARANCE & THEME", theme),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                SegmentedButton<ThemeMode>(
                  style: SegmentedButton.styleFrom(
                    backgroundColor: theme.colorScheme.surface,
                    selectedForegroundColor: Colors.white,
                    selectedBackgroundColor: theme.colorScheme.primary,
                    side: BorderSide(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                  ),
                  segments: const [
                    ButtonSegment(
                      value: ThemeMode.light,
                      icon: Icon(Icons.light_mode_rounded),
                      label: Text("Light"),
                    ),
                    ButtonSegment(
                      value: ThemeMode.dark,
                      icon: Icon(Icons.dark_mode_rounded),
                      label: Text("Dark"),
                    ),
                    ButtonSegment(
                      value: ThemeMode.system,
                      icon: Icon(Icons.brightness_auto_rounded),
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

          const SizedBox(height: 24),

          _buildSectionHeader("PLAYBACK SETTINGS", theme),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.speed_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text("Default Playback Speed"),
                  trailing: DropdownButton<double>(
                    value: musicProvider.playbackSpeed,
                    underline: const SizedBox.shrink(),
                    dropdownColor: theme.colorScheme.surface,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 0.75, child: Text("0.75x")),
                      DropdownMenuItem(
                        value: 1.0,
                        child: Text("1.0x (Normal)"),
                      ),
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
                  leading: Icon(
                    Icons.forward_10_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text("Seek Step Duration"),
                  trailing: DropdownButton<int>(
                    value: musicProvider.seekDuration,
                    underline: const SizedBox.shrink(),
                    dropdownColor: theme.colorScheme.surface,
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: theme.colorScheme.primary,
                    ),
                    items: const [
                      DropdownMenuItem(value: 2, child: Text("2 seconds")),
                      DropdownMenuItem(value: 5, child: Text("5 seconds")),
                      DropdownMenuItem(value: 10, child: Text("10 seconds")),
                      DropdownMenuItem(value: 15, child: Text("15 seconds")),
                      DropdownMenuItem(value: 30, child: Text("30 seconds")),
                    ],
                    onChanged: (val) {
                      if (val != null) musicProvider.setSeekDuration(val);
                    },
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader("ACCESSIBILITY", theme),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: SwitchListTile(
              secondary: Icon(
                Icons.touch_app_rounded,
                color: theme.colorScheme.primary,
              ),
              title: const Text("Assistive Touch"),
              subtitle: const Text("Floating quick actions button"),
              activeTrackColor: theme.colorScheme.primary.withValues(alpha: 0.5), activeThumbColor: theme.colorScheme.primary,
              value: themeProvider.isAssistiveTouchEnabled,
              onChanged: (val) {
                themeProvider.toggleAssistiveTouch();
              },
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader("LIBRARY STATISTICS", theme),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatColumn(
                  "Tracks",
                  "${musicProvider.songs.length}",
                  theme,
                ),
                _buildStatColumn(
                  "Albums",
                  "${musicProvider.albums.length}",
                  theme,
                ),
                _buildStatColumn(
                  "Artists",
                  "${musicProvider.artists.length}",
                  theme,
                ),
                _buildStatColumn(
                  "Folders",
                  "${musicProvider.folders.keys.length}",
                  theme,
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("DATA MANAGEMENT", theme),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.sync_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text("Rescan Library"),
                  subtitle: Text(
                    "Scan storage for new and deleted files",
                    style: TextStyle(
                      color: theme.colorScheme.inversePrimary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onTap: () async {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Rescanning device music..."),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    await musicProvider.rescanLibrary();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Scan complete! Discovered ${musicProvider.songs.length} tracks.",
                          ),
                        ),
                      );
                    }
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(
                    Icons.history_rounded,
                    color: Colors.orangeAccent,
                  ),
                  title: const Text("Clear History"),
                  subtitle: Text(
                    "Erase recently played song history",
                    style: TextStyle(
                      color: theme.colorScheme.inversePrimary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  onTap: () => _confirmActionDialog(
                    context: context,
                    title: "Clear Play History?",
                    content: "This will erase your recently played logs.",
                    onConfirm: () => musicProvider.clearHistory(),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(
                    Icons.bar_chart_rounded,
                    color: Colors.redAccent,
                  ),
                  title: const Text("Clear Play Statistics"),
                  subtitle: Text(
                    "Reset all most-played counters",
                    style: TextStyle(
                      color: theme.colorScheme.inversePrimary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  onTap: () => _confirmActionDialog(
                    context: context,
                    title: "Reset Statistics?",
                    content:
                        "This will reset all song play-count statistics to zero.",
                    onConfirm: () => musicProvider.clearPlayStatistics(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          _buildSectionHeader("ABOUT", theme),
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 10,
                  spreadRadius: 1,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: theme.colorScheme.primary.withValues(alpha: 0.1),
              ),
            ),
            child: Column(
              children: [
                ListTile(
                  leading: Icon(
                    Icons.info_outline_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text("App Version"),
                  trailing: Text(
                    "v1.0.0+20",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ListTile(
                  leading: Icon(
                    Icons.code_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  title: const Text("Developed by Zahin"),
                  subtitle: Text(
                    "Ahmed",
                    style: TextStyle(
                      color: theme.colorScheme.inversePrimary.withValues(
                        alpha: 0.5,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    Icons.chevron_right_rounded,
                    color: theme.colorScheme.primary,
                  ),
                  onTap: () => _showAboutAppDialog(context, theme),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value, ThemeData theme) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: theme.colorScheme.inversePrimary.withValues(alpha: 0.5),
            letterSpacing: 1,
            fontWeight: FontWeight.w600,
          ),
        ),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              onConfirm();
              Navigator.pop(ctx);
            },
            child: const Text("Clear"),
          ),
        ],
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context, ThemeData theme) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Music Player App"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "A beautiful, minimalist local music player built with Flutter.",
            ),
            const SizedBox(height: 16),
            Text(
              "Design & Code: Zahin Ahmed",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Close"),
          ),
        ],
      ),
    );
  }
}
