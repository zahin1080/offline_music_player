import 'package:flutter/material.dart';
import 'package:minimal_music_player/ui/screens/settins_page.dart';
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Icon(
                Icons.music_note,
                size: 50,
                color: theme.colorScheme.inversePrimary,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0, top: 20.0),
            child: ListTile(
              title: const Text("H O M E", style: TextStyle(letterSpacing: 2)),
              leading: const Icon(Icons.home),
              onTap: () => Navigator.pop(context),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: ListTile(
              title: const Text("S E T T I N G S", style: TextStyle(letterSpacing: 2)),
              leading: const Icon(Icons.settings),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsPage()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

