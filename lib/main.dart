// Force IDE refresh
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:minimal_music_player/core/theme/theme_provider.dart';
import 'package:minimal_music_player/providers/playlist_provider.dart';
import 'package:minimal_music_player/ui/home/home_page.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.ryanheise.bg_demo.channel.audio',
    androidNotificationChannelName: 'Audio playback',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
    androidNotificationIcon: 'mipmap/launcher_icon',
  );
  await Hive.initFlutter();
  await Hive.openBox('favorites');
  await Hive.openBox('history');
  await Hive.openBox('playlists');
  await Hive.openBox('stats');
  await Hive.openBox('session');
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => MusicProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: themeProvider.themeData,
      title: 'Offline Music Player',
      navigatorKey: appNavigatorKey,
      home: HomePage(),
    );
  }
}
