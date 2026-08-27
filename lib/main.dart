import 'package:flutter/material.dart';
import 'package:mobile_app/screens/stage/stage_led_strip_screen.dart';
import 'package:mobile_app/utils/app_routes.dart';
import 'screens/splash_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/wearable/led_strip_screen.dart';
import 'screens/wearable/front_display.dart';

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
        AppRoutes.splash: (context) => const SplashScreen(),
        AppRoutes.settings: (context) => const SettingsScreen(),
        AppRoutes.wearableLed: (context) => const LedStripScreen(),
        AppRoutes.wearableDisplay: (context) => const FrontDisplay(),
        AppRoutes.stageLed: (context) => const StageLedStripScreen(),
      },
      home: const SplashScreen(),
    );  
  }
}