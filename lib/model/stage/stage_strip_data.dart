import 'dart:ui';

class StageStripData<T> {
  final T effect;
  final int speedEffect;
  final int brightness;
  final Color color1;
  final Color color2;

  final int senitivity;
  final int treshold;
  final int smoothness;

  StageStripData({
    required this.effect,
    required this.speedEffect,
    required this.brightness,
    required this.color1,
    required this.color2,
    required this.senitivity,
    required this.treshold,
    required this.smoothness,
  });

  static StageStripData<T> getDefaultData<T>(T defaultEffect) {
    return StageStripData<T>(
      effect: defaultEffect,
      speedEffect: 50,
      brightness: 0,
      color1: const Color.fromARGB(255, 255, 0, 0),
      color2: const Color.fromARGB(255, 0, 0, 255),
      senitivity: 0,
      treshold: 0,
      smoothness: 0,
    );
  }
}