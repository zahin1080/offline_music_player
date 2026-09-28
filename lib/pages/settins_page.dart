import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimal_music_player/theme/theme_provider.dart';
import 'package:provider/provider.dart';
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<ThemeProvider>();

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          "S E T T I N G S",
          style: TextStyle(color: theme.colorScheme.inversePrimary, letterSpacing: 2),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Dark Mode", style: TextStyle(fontWeight: FontWeight.bold)),
            CupertinoSwitch(
              value: themeProvider.isDarkMode,
              onChanged: (_) => context.read<ThemeProvider>().toggleTheme(),
            ),
          ],
        ),
      ),
    );
  }
}
