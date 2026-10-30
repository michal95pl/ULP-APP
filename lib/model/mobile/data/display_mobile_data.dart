import 'dart:ui';

import 'package:mobile_app/model/mobile/effects/mobile_display_effects.dart';

class DisplayMobileData {
  String displayText;
  Color textColor;

  double displayBrightness;
  MobileDisplayEffects displayEffect;

  DisplayMobileData({
    required this.displayText,
    required this.textColor,
    required this.displayBrightness,
    required this.displayEffect,
  });

  factory DisplayMobileData.getDefaultData() {
    return DisplayMobileData(
      displayText: '',
      textColor: const Color.fromARGB(255, 255, 255, 255),
      displayBrightness: 0.0,
      displayEffect: MobileDisplayEffects.matrix,
    );
  }

  factory DisplayMobileData.fromJson(Map<String, dynamic> json) {
    return DisplayMobileData(
      displayText: json['displayText'] as String,
      textColor: Color.fromARGB(
        255,
        json['textColor']['r'] as int,
        json['textColor']['g'] as int,
        json['textColor']['b'] as int,
      ),
      displayBrightness: (json['displayBrightness'] as num).toDouble(),
      displayEffect: MobileDisplayEffects.values[json['displayEffect'] as int],
    );
  }
}