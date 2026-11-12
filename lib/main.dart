import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:permission_handler/permission_handler.dart';
import 'theme/app_theme.dart';
import 'providers/quran_provider.dart';
import 'providers/audio_player_provider.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await JustAudioBackground.init(
    androidNotificationChannelId: 'com.frontalminds.gonidahir.quran.audio.v1',
    androidNotificationChannelName: 'Goni Dahir Quran Audio',
    androidNotificationChannelDescription: 'Goni Dahir Quran Recitation Playback Controls',
    androidNotificationOngoing: false,
    androidNotificationIcon: 'mipmap/ic_launcher',
  );

  if (Platform.isAndroid) {
    try {
      await Permission.notification.request();
    } catch (_) {}
  }

  // Set system navigation & status bar styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const GwaniDahiruQuranApp());
}

class GwaniDahiruQuranApp extends StatelessWidget {
  const GwaniDahiruQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => QuranProvider()..initialize(),
        ),
        ChangeNotifierProvider(
          create: (_) => AudioPlayerProvider(),
        ),
      ],
      child: MaterialApp(
        title: 'Goni Dahir',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const HomeScreen(),
      ),
    );
  }
}
