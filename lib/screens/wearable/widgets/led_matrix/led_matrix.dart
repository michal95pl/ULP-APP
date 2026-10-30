import 'package:flutter/material.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/led_matrix_controller.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/pixel_painter.dart';

class LedMatrix extends StatelessWidget {
  final LedMatrixController controller;
  final void Function(int x, int y) onPixelChanged;

  const LedMatrix({
    super.key,
    required this.controller,
    required this.onPixelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          onPanDown: (details) => _handleTouch(details.localPosition, size),
          onPanUpdate: (details) => _handleTouch(details.localPosition, size),
          child: CustomPaint(
            size: size,
            painter: PixelPainter(
              width: controller.width,
              height: controller.height,
              getPixels: (){return controller.currentScreen;},
              repaint: controller,
            ),
          )
        );
      },
    );
  }

  void _handleTouch(Offset localPosition, Size size) {
    final double cellSize = (size.width / controller.width < size.height / controller.height)
        ? size.width / controller.width
        : size.height / controller.height;

    final double totalGridWidth = controller.width * cellSize;
    final double totalGridHeight = controller.height * cellSize;
    final double offsetX = (size.width - totalGridWidth) / 2.0;
    final double offsetY = (size.height - totalGridHeight) / 2.0;

    final int gridX = ((localPosition.dx - offsetX) / cellSize).floor();
    final int gridY = ((localPosition.dy - offsetY) / cellSize).floor();

    onPixelChanged(gridX, gridY);
  }
}