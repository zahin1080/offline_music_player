import 'package:flutter/material.dart';
import 'package:minimal_music_player/pages/home_page.dart';
import 'package:minimal_music_player/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:minimal_music_player/models/playlist_provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.example.offline_music.channel.audio',
    androidNotificationChannelName: 'Music Playback',
    androidNotificationIcon: 'mipmap/launcher_icon',
    androidNotificationOngoing: true,
    androidStopForegroundOnPause: true,
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
  );;
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
      home: HomePage(),
    );
  }
}


