import 'dart:ui';

import 'package:mobile_app/model/mobile/effects/mobile_strip_effects.dart';

class StripMobileData {
  final int brightness;
  final int speedEffect;
  final MobileStripEffect effect;
  final Color firstColor;
  final Color secondColor;

  StripMobileData({
    required this.brightness,
    required this.speedEffect,
    required this.effect,
    required this.firstColor,
    required this.secondColor,
  });

  factory StripMobileData.getDefaultData() {
    return StripMobileData(
      brightness: 255,
      speedEffect: 0,
      effect: MobileStripEffect.color,
      firstColor: const Color.fromARGB(255, 255, 0, 0),
      secondColor: const Color.fromARGB(255, 0, 0, 255),
    );
  }

  factory StripMobileData.fromJson(Map<String, dynamic> json) {
    return StripMobileData(
      brightness: json['brightness'] as int,
      speedEffect: json['speedEffect'] as int,
      effect: MobileStripEffect.values[json['effect'] as int],
      firstColor: Color.fromARGB(
        255,
        json['firstColor']['r'] as int,
        json['firstColor']['g'] as int,
        json['firstColor']['b'] as int,
      ),
      secondColor: Color.fromARGB(
        255,
        json['secondColor']['r'] as int,
        json['secondColor']['g'] as int,
        json['secondColor']['b'] as int,
      ),
    );
  }
}