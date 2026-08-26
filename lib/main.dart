import 'package:flutter/material.dart';
import 'package:mobile_app/data/settings_file.dart';
import 'screens/splash_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/wearable/led_strip_screen.dart';
import 'screens/wearable/front_display.dart';
import 'data/pixel_storage.dart';

void main() async {
  runApp(const MainApp());
  SettingsFile.openFile('settings.json');
  await PixelStorage.init();
}

// https://digitalsynopsis.com/design/color-schemes-palettes/


class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/led_strip': (context) => const LedStripScreen(),
        '/front_display': (context) => const FrontDisplay(),
      },
      home: const SplashScreen(),
    );  
  }
}