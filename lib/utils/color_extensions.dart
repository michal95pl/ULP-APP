import 'package:flutter/material.dart';

extension ColorToBytes on Color {
  int get redInt => (r * 255.0).round().clamp(0, 255);
  int get greenInt => (g * 255.0).round().clamp(0, 255);
  int get blueInt => (b * 255.0).round().clamp(0, 255);
}