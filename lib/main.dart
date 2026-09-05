import 'package:flutter/material.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const MainApp());
}

// https://digitalsynopsis.com/design/color-schemes-palettes/

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashScreen(),
    );  
  }
}