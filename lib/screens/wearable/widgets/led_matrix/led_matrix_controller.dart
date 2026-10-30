import 'package:flutter/material.dart';
import 'package:mobile_app/data/pixel_storage.dart';
import 'package:mobile_app/model/display_target.dart';
import 'package:mobile_app/utils/color_extensions.dart';

class SaveMatrixException implements Exception {
  final String message;
  SaveMatrixException(this.message);

  @override
  String toString() => message;
}

class LedMatrixController extends ChangeNotifier {
  final int width;
  final int height;
  final List<List<Color>> _pages;
  final int maxPages;
  final DisplayTarget target;
  Color selectedColor = Colors.red;
  ValueNotifier<int> currentPageNotifier = ValueNotifier<int>(0);

  int get currentPage => currentPageNotifier.value;

  LedMatrixController({
    required this.width,
    required this.height,
    required this.maxPages,
    required this.target,
  }) : _pages = List.generate(
          maxPages,
          (_) => List<Color>.filled(width * height, Colors.black, growable: true),
        );

  List<Color> get currentScreen => _pages[currentPageNotifier.value];


  List<int> getAllFramesAsBytes() {
    final int totalBytes = (maxPages * width * height * 3) + 3;
    final List<int> bytes = List<int>.filled(totalBytes, 0);
    
    bytes[0] = width;
    bytes[1] = height;
    bytes[2] = maxPages;

    int byteIndex = 3;
    
    for (int i = 0; i < maxPages; i++) {
      final List<Color> frameColors = _pages[i];
      
      for (final Color color in frameColors) {
        bytes[byteIndex++] = color.redInt;
        bytes[byteIndex++] = color.greenInt;
        bytes[byteIndex++] = color.blueInt;
      }
    }
    return bytes;
  }

  void setAllFramesFromBytes(List<int> bytes) {
    if (bytes.length < 3) {
      throw Exception('Invalid byte array');
    }

    final int loadedWidth = bytes[0];
    final int loadedHeight = bytes[1];
    final int loadedMaxPages = bytes[2];

    if (loadedWidth != width || loadedHeight != height || loadedMaxPages != maxPages) {
      throw Exception('Loaded matrix dimensions do not match the controller dimensions');
    }

    int byteIndex = 3;

    for (int i = 0; i < maxPages; i++) {
      for (int j = 0; j < width * height; j++) {
        final int r = bytes[byteIndex++];
        final int g = bytes[byteIndex++];
        final int b = bytes[byteIndex++];
        _pages[i][j] = Color.fromARGB(255, r, g, b);
      }
    }
    notifyListeners();
  }

  void setPixel(int x, int y) {
    if (x >= 0 && x < width && y >= 0 && y < height) {
      final int index = y * width + x;
      if (_pages[currentPageNotifier.value][index] != selectedColor) {
        _pages[currentPageNotifier.value][index] = selectedColor;
        notifyListeners();
      }
    }
  }

  void setPixels(List<Color> colors) {
    if (colors.length == width * height) {
      _pages[currentPageNotifier.value] = List.from(colors);
    }
    notifyListeners();
  }

  void clearCurrentFrame() {
    _pages[currentPageNotifier.value].fillRange(0, width * height, Colors.black);
  }

  void setFrame(int index) {
    if (index >= 0 && index < maxPages && index != currentPageNotifier.value) {
      currentPageNotifier.value = index;
      notifyListeners();
    }
  }

  bool checkFileName(String fileName) {
    if (fileName.isEmpty) {
      return false;
    }
    final validCharacters = RegExp(r'^[a-zA-Z0-9_\-]+$');
    return validCharacters.hasMatch(fileName);
  }

  Future<void> saveFile(String fileName) async {
    if (!checkFileName(fileName)) {
      throw SaveMatrixException('Invalid file name');
    }
    if (await PixelStorage.fileExists(target, fileName)) {
      throw SaveMatrixException('File already exists');
    }
    await PixelStorage.savePixels(target, fileName, width, height, _pages);
  }

  Future<void> loadFile(String fileName) async {
    if (!await PixelStorage.fileExists(target, fileName)) {
      throw SaveMatrixException('File does not exist');
    }
    final loadedMatrix = await PixelStorage.loadPixels(target, fileName);
    if (loadedMatrix['pages'].length != maxPages) {
      throw SaveMatrixException('Loaded matrix has a different number of pages than expected');
    }
    
    final int loadedWidth = loadedMatrix['width'];
    final int loadedHeight = loadedMatrix['height'];

    if (loadedWidth != width || loadedHeight != height) {
      throw SaveMatrixException('Loaded matrix dimensions do not match the controller dimensions');
    }

    for (int i = 0; i < maxPages; i++) {
      _pages[i] = List<Color>.from(loadedMatrix['pages'][i]);
    }
  
    currentPageNotifier.value = 0;
    notifyListeners();
  }

  Future<void> deleteFile(String fileName) => PixelStorage.deleteFile(target, fileName);

  Future<List<String>> getSavedPixelArts() => 
    PixelStorage.listFiles(target);

  Future<List<String>> getSavedImages() async {
    return [];
  }

}