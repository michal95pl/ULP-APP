import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/custom_color_picker.dart';

class DualColorPicker extends StatelessWidget {

  final Color initialColor1;
  final Color initialColor2;
  final ValueChanged<Color> onChangedColor1;
  final ValueChanged<Color>? onEndChangedColor1;
  final ValueChanged<Color> onChangedColor2;
  final ValueChanged<Color>? onEndChangedColor2;
  final bool isDoubleColorMode;
  final double paletteHeight;

  const DualColorPicker({
    super.key,
    required this.initialColor1,
    required this.initialColor2,
    required this.onChangedColor1,
    this.onEndChangedColor1,
    required this.onChangedColor2,
    this.onEndChangedColor2,
    required this.isDoubleColorMode,
    this.paletteHeight = 280.0,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child:
          CustomColorPicker(
            paletteHeight: paletteHeight,
            initialColor: initialColor1,
            onChanged: onChangedColor1,
            onChangedEnd: onEndChangedColor1,
          ),
        ),
        if (isDoubleColorMode) ...[
          const SizedBox(width: 8),
          Expanded(
            child: 
            CustomColorPicker(
              paletteHeight: paletteHeight,
              initialColor: initialColor2,
              onChanged: onChangedColor2,
              onChangedEnd: onEndChangedColor2,
            ),
          ),
        ],
      ],
    );
  }
}