import 'package:flutter/material.dart';
import 'package:minimal_music_player/pages/settins_page.dart';
class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        children: [
          DrawerHeader(child: Center(child: Icon(Icons.music_note,size:50,color: Theme.of(context).colorScheme.inversePrimary,
          ),
          ),

          ),
          Padding(
            padding: const EdgeInsets.only(left:20.0 ,top:20.0),
            child: ListTile(
              title: const Text("H O M E"),
              leading: const Icon(Icons.home),
              onTap:()=> Navigator.pop(context),

            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left:20.0 ,top:0),
            child: ListTile(
              title: const Text("S E T T I N G S"),
              leading: const Icon(Icons.settings),
              onTap:() {Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context)=> SettingsPage(),)

                );
  },

            ),
          ),
        ],
      ),
    );
  }
}
