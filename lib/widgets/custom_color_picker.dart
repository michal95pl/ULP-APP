import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

class CustomColorPicker extends StatefulWidget {
  final Color initialColor;
  final ValueChanged<Color> onChanged;
  final ValueChanged<Color>? onChangedEnd;
  final double paletteHeight;

  const CustomColorPicker({
    super.key,
    required this.paletteHeight,
    required this.initialColor,
    required this.onChanged,
    this.onChangedEnd,
  });

  @override
  State<CustomColorPicker> createState() => _CustomColorPickerState();
}

class _CustomColorPickerState extends State<CustomColorPicker> {
  late Color _currentColor;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.initialColor;
  }

  @override
  void didUpdateWidget(covariant CustomColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentColor != widget.initialColor) {
      setState(() {
        _currentColor = widget.initialColor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerUp: (event) {
        if (widget.onChangedEnd != null) {
          widget.onChangedEnd!(_currentColor);
        }
      },
      child: PaletteHuePicker(
        paletteHeight: widget.paletteHeight,
        color: HSVColor.fromColor(_currentColor),
        onChanged: (newColor) {
          setState(() {
            _currentColor = newColor.toColor();
          });
          widget.onChanged(newColor.toColor());
        },
      ),
    );
  }
}