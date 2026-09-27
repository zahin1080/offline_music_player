import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:minimal_music_player/theme/theme_provider.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(  title:Text("S E T T I N G S"),

      ),
      body: Container(
        decoration: BoxDecoration(color:Theme.of(context).colorScheme.secondary,borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.all(16.0),


        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Dark Mode",style: TextStyle(fontWeight: FontWeight.bold,),),
            CupertinoSwitch(
              value: Provider.of<ThemeProvider>(context).isDarkMode,
              onChanged: (value)=> Provider.of<ThemeProvider>(context,listen:false).toggleTheme(),
            ),
          ],
        ),
      ),

    );
  }
}
