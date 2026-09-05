import 'package:flutter/material.dart';
import 'package:mobile_app/screens/settings/settings_screen.dart';
import 'package:mobile_app/screens/stage/stage_led_strip_screen.dart';
import 'package:mobile_app/screens/wearable/front_display.dart';
import 'package:mobile_app/screens/wearable/led_strip_screen.dart';

enum AppRoutes {
  splash,
  stageLed,
  wearableLed,
  wearableDisplay,
  settings;

  // Method to navigate to a specific route wiithout animation
  static void navigateTo(BuildContext context, AppRoutes route) {
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation1, animation2) {
          switch (route) {
            case AppRoutes.wearableDisplay: return const FrontDisplay();
            case AppRoutes.wearableLed: return const LedStripScreen();
            case AppRoutes.stageLed: return const StageLedStripScreen();
            case AppRoutes.settings: return const SettingsScreen();
            default: return const SettingsScreen();
          }
        },
        transitionDuration: Duration.zero,
        reverseTransitionDuration: Duration.zero,
      ),
    );
  }
}