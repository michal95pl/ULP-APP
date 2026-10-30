import 'package:flutter/material.dart';

class PixelPainter extends CustomPainter {
  
  final int width;
  final int height;
  final double marginPercentage;
  final Paint _pixelPaint = Paint();
  final List<Color> Function() getPixels;
  
  PixelPainter({
    required this.width,
    required this.height,
    required this.getPixels,
    required Listenable repaint,
    this.marginPercentage = 0.10,
  }) : super(repaint: repaint);

 @override
  void paint(Canvas canvas, Size size) {
    final double cellSize = (size.width / width < size.height / height)
        ? size.width / width
        : size.height / height;

    final double margin = (cellSize * marginPercentage).clamp(0.5, 4.0);
    final double ledSize = cellSize - margin;

    final double totalGridWidth = width * cellSize;
    final double totalGridHeight = height * cellSize;
    final double offsetX = (size.width - totalGridWidth) / 2.0;
    final double offsetY = (size.height - totalGridHeight) / 2.0;

    final List<Color> pixels = getPixels();

    for (int y = 0; y < height; y++) {
      final double top = offsetY + y * cellSize;

      for (int x = 0; x < width; x++) {
        final double left = offsetX + x * cellSize;
        final int index = y * width + x;

        _pixelPaint.color = pixels[index];

        canvas.drawRect(
          Rect.fromLTWH(left, top, ledSize, ledSize),
          _pixelPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}