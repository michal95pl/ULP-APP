import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PixelStorage {

  static late Directory path;

  static void _createDirectoryIfNotExists(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  static Future<void> _createDirStructure(Directory baseDir) async {
    _createDirectoryIfNotExists('${baseDir.path}/front_display');
    _createDirectoryIfNotExists('${baseDir.path}/back_display');
    _createDirectoryIfNotExists('${baseDir.path}/led_strip');
  }

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    path = Directory('${dir.path}/pixel_storage');
    _createDirStructure(path);
    debugPrint('[PixelStorage] Pixel storage path: ${path.path}');
  }

  static List<int> _convertPixelDataToBytes(List<List<List<int>>> pixelData) {
    List<int> buffer = [];
    for (final y in pixelData) {
      for (final x in y) {
        buffer.addAll(x);
      }
    }
    return buffer;
  }

  static List<List<List<List<int>>>> _convertBytesToPixelData(List<int> bytes, int width, int height, int frames) {
    List<List<List<List<int>>>> pixelData = List.generate(frames, (_) => List.generate(height, (_) => List.generate(width, (_) => [0, 0, 0])));
    debugPrint(pixelData.toString());
    int index = 0;
    for (int f = 0; f < frames; f++) {
      for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
          pixelData[f][y][x] = [bytes[index], bytes[index + 1], bytes[index + 2]];
          index += 3;
        }
      }
    }
    return pixelData;
  }

  static Future<void> saveLedStrip(String nameProfile, List<List<List<int>>> pixelData) async {
    final file = File('${path.path}/led_strip/$nameProfile.bin');

    // header: number of strips (x), number of pixels, number of animation frames (0 for static)
    List<int> bytes = [pixelData.length, pixelData[0].length, 1];
    bytes.addAll(_convertPixelDataToBytes(pixelData));
    await file.writeAsBytes(bytes);
  }

  static Future<void> saveLedStripAnimation(String nameProfile, List<List<List<List<int>>>> pixelData) async {
    final file = File('${path.path}/led_strip/$nameProfile.bin');

    // header: number of strips (x), number of pixels, number of animation frames
    List<int> bytes = [pixelData[0].length, pixelData[0][0].length, pixelData.length];
    for (final frame in pixelData) {
      bytes.addAll(_convertPixelDataToBytes(frame));
    }
    await file.writeAsBytes(bytes);
  }

  static Future<void> saveDisplay(String nameProfile, List<List<List<int>>> pixelData) async {
    final file = File('${path.path}/front_display/$nameProfile.bin');

    // header: x, y, animation frames (0 for static)
    List<int> bytes = [pixelData[0].length, pixelData.length, 1];
    bytes.addAll(_convertPixelDataToBytes(pixelData));
    await file.writeAsBytes(bytes);
  }

  static Future<void> saveDisplayAnimation(String nameProfile, List<List<List<List<int>>>> pixelData) async {
    final file = File('${path.path}/front_display/$nameProfile.bin');

    // header: x, y, animation frames
    List<int> bytes = [pixelData[0][0].length, pixelData[0].length, pixelData.length];
    for (final frame in pixelData) {
      bytes.addAll(_convertPixelDataToBytes(frame));
    }
    await file.writeAsBytes(bytes);
  }

  static Future<List<List<List<List<int>>>>?> readFile(String p) async {
    final file = File("${path.path}/$p");
    if (!await file.exists()) {
      debugPrint('[PixelStorage] File not found: ${file.path}');
      return null;
    }

    final bytes = await file.readAsBytes();
    if (bytes.isEmpty) {
      debugPrint('[PixelStorage] File is empty: ${file.path}');
      return null;
    }

    final x = bytes[0];
    final y = bytes[1];
    final frames = bytes[2];
    if (x > 0 && y > 0) {
      return _convertBytesToPixelData(bytes.sublist(3), x, y, frames);
    }

    return null;
  }

  static List<String> getLedStripProfiles() {
    final dir = Directory('${path.path}/led_strip');
    final files = dir.listSync().whereType<File>().where((file) => file.path.endsWith('.bin'));
    return files.map((file) => file.path.split('/').last.replaceAll('.bin', '')).toList();
  }

  static List<String> getFrontDisplayProfiles() {
    final dir = Directory('${path.path}/front_display');
    final files = dir.listSync().whereType<File>().where((file) => file.path.endsWith('.bin'));
    return files.map((file) => file.path.split('/').last.replaceAll('.bin', '')).toList();
  }

  static List<String> getBackDisplayProfiles() {
    final dir = Directory('${path.path}/back_display');
    final files = dir.listSync().whereType<File>().where((file) => file.path.endsWith('.bin'));
    return files.map((file) => file.path.split('/').last.replaceAll('.bin', '')).toList();
  }

}