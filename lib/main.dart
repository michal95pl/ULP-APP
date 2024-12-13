import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/led_strip/led_strip_screen.dart';

void main() {
  runApp(const MainApp());
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
      },
      home: const SplashScreen(),
    );  
  }
}