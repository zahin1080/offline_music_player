import 'package:flutter/material.dart';
import 'package:minimal_music_player/ui/screens/settins_page.dart';

class MyDrawer extends StatelessWidget {
  final VoidCallback? onNavigateHome;
  final VoidCallback? onNavigateLibrary;

  const MyDrawer({super.key, this.onNavigateHome, this.onNavigateLibrary});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      width: 100,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(40)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),
          // Beautiful Music Icon
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.4), width: 2),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ]
            ),
            child: Icon(
              Icons.music_note_rounded,
              size: 32,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 40),
          Divider(
            indent: 24,
            endIndent: 24,
            height: 1,
            color: theme.colorScheme.primary.withValues(alpha: 0.2),
          ),
          const SizedBox(height: 40),
          
          // Settings Icon
          _buildDrawerIcon(Icons.settings_rounded, theme, () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsPage()),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDrawerIcon(IconData icon, ThemeData theme, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: theme.colorScheme.primary.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
        child: Icon(
          icon,
          size: 28,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
