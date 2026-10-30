import 'package:flutter/material.dart';
import 'package:mobile_app/model/display_target.dart';
import 'package:mobile_app/utils/color_extensions.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PixelStorage {

  static late Directory basePath;

  static Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();
    basePath = Directory('${dir.path}/pixel_storage');

    for (final target in DisplayTarget.values) {
      final subDir = Directory('${basePath.path}/${target.folderName}');
      if (!await subDir.exists()) {
        await subDir.create(recursive: true);
      }
    }
  }

  static Future<void> savePixels(DisplayTarget target, String fileName, int width, int height, List<List<Color>> pixels) async {
    final name = fileName.endsWith('.bin') ? fileName : '$fileName.bin';
    final file = File('${basePath.path}/${target.folderName}/$name');

    List<int> bytes = [width, height, pixels.length];
    for (final frame in pixels) {
      for (final color in frame) {
        bytes.addAll([color.redInt, color.greenInt, color.blueInt]);
      }
    }
    await file.writeAsBytes(bytes);
    debugPrint('Saved pixel data to ${file.path}');
  }

  static Future<bool> fileExists(DisplayTarget target, String fileName) async {
    final name = fileName.endsWith('.bin') ? fileName : '$fileName.bin';
    final file = File('${basePath.path}/${target.folderName}/$name');

    return await file.exists();
  }

  static Future<Map<String, dynamic>> loadPixels(DisplayTarget target, String fileName) async {
    final name = fileName.endsWith('.bin') ? fileName : '$fileName.bin';
    final file = File('${basePath.path}/${target.folderName}/$name');

    if (!await file.exists()) {
      throw Exception('File not found: ${file.path}');
    }

    final bytes = await file.readAsBytes();
    if (bytes.length < 3) {
      throw Exception('Invalid pixel data in file: ${file.path}');
    }

    final int width = bytes[0];
    final int height = bytes[1];
    final int pagesCount = bytes[2];

    List<List<Color>> pages = [];

    for (int p=0; p < pagesCount; p++) {
      List<Color> page = [];
      for (int i = 0; i < width * height; i++) {
        final int index = 3 + (p * width * height + i) * 3;
        if (index + 2 >= bytes.length) {
          throw Exception('Unexpected end of pixel data in file: ${file.path}');
        }
        final color = Color.fromARGB(255, bytes[index], bytes[index + 1], bytes[index + 2]);
        page.add(color);
      }
      pages.add(page);
    }

    return {
      'width': width,
      'height': height,
      'pages': pages
    };
  }

  static Future<void> deleteFile(DisplayTarget target, String fileName) async {
    final name = fileName.endsWith('.bin') ? fileName : '$fileName.bin';
    final file = File('${basePath.path}/${target.folderName}/$name');

    if (await file.exists()) {
      await file.delete();
      debugPrint('Deleted pixel data file: ${file.path}');
    } else {
      throw Exception('File not found: ${file.path}');
    }
  }

 static Future<List<String>> listFiles(DisplayTarget target) async {
    final dir = Directory('${basePath.path}/${target.folderName}');

    if (!dir.existsSync()) {
      return [];
    }

    return dir.listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.bin'))
        .map((file) => file.uri.pathSegments.last.replaceAll('.bin', ''))
        .toList();
  }

}