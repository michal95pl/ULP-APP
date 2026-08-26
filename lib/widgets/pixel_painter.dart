import 'package:flutter/material.dart';

class PixelPainter extends CustomPainter {
  
  final int _width, _height, _pageNumber;
  late int _pixelSize, _margin;
  late List<List<List<List<int>>>> displayBuffer; // [page number][y][x][r,g,b]
  int actualPage = 0;
  bool updating = false;
  final ValueNotifier<bool> _needsRepaint;

  // needsRepaint is a ValueNotifier that triggers repaint when its value changes. It shouldn't be used directly.
  PixelPainter(this._width, this._height, this._pageNumber, this._needsRepaint, {
    int pixelSize = 35,
    int margin = 5
  }) : super(repaint: _needsRepaint) {
    _pixelSize = pixelSize;
    _margin = margin;
    displayBuffer = List.generate(_pageNumber, (i) => List.generate(_height, (i) =>  List.generate(_width, (i) => [0,0,0], growable: false),  growable: false), growable: false);
  }

  @override
  void paint(Canvas canvas, Size size) {
    int y1 = 0, y2 = _pixelSize;
    for (int j = 0; j < _height; j++) {
      int x1 = 0, x2 = _pixelSize;
      for (int i = 0; i < _width; i++) {
        var paint1 = Paint()..color = Color.fromARGB(255, displayBuffer[actualPage][j][i][0], displayBuffer[actualPage][j][i][1], displayBuffer[actualPage][j][i][2]);
        canvas.drawRect(Rect.fromLTRB(x1.toDouble(), y1.toDouble(), x2.toDouble(), y2.toDouble()), paint1);
        x2 += _pixelSize + _margin;
        x1 += _pixelSize + _margin;
      }
      y1 += _pixelSize + _margin;
      y2 += _pixelSize + _margin;
    }
  }

  Size getSize() {
    return Size(
      (_width * (_pixelSize + _margin) - _margin).toDouble(), 
      (_height * (_pixelSize + _margin) - _margin).toDouble()
    );
  }

  void setActualPage(int page) {
    actualPage = page;
    _needsRepaint.value = !_needsRepaint.value;
  }

  void setDisplayBuffer(List<List<List<List<int>>>> buffer) {
    displayBuffer = buffer;
    _needsRepaint.value = !_needsRepaint.value;
  }

  void setPixel(int page, int x, int y, int r, int g, int b) {
    displayBuffer[page][y][x][0] = r;
    displayBuffer[page][y][x][1] = g;
    displayBuffer[page][y][x][2] = b;
    _needsRepaint.value = !_needsRepaint.value;
  }

  void setPixelFromPosition(int x, int y, int r, int g, int b) {
    int px = x ~/ (_pixelSize + _margin);
    int py = y ~/ (_pixelSize + _margin);
    if (px < _width && py < _height) {
      displayBuffer[actualPage][py][px][0] = r;
      displayBuffer[actualPage][py][px][1] = g;
      displayBuffer[actualPage][py][px][2] = b;
    }
    _needsRepaint.value = !_needsRepaint.value;
  }

  @override
  bool shouldRepaint(PixelPainter oldDelegate) {
    return false;
  }
}