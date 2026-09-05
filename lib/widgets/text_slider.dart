import 'package:flutter/material.dart';

class TextVerticalSlider extends StatefulWidget {
  final String label;
  final Color color;
  final double maxValue;
  final double initialValue;
  final ValueChanged<double> onChanged;
  final ValueChanged<double>? onChangeEnd;
  final double step;
  final bool isHorizontal;

  const TextVerticalSlider({
    super.key,
    required this.label,
    required this.maxValue,
    required this.color,
    required this.onChanged,
    this.onChangeEnd,
    this.initialValue = 0.0,
    this.step = 10.0,
    this.isHorizontal = false,
  });

  @override
  State<TextVerticalSlider> createState() => _TextVerticalSliderState();
}
class _TextVerticalSliderState extends State<TextVerticalSlider> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
  }

  @override
  void didUpdateWidget(covariant TextVerticalSlider oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_currentValue != widget.initialValue) {
      setState(() {
        _currentValue = widget.initialValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    final slider = SliderTheme(
      data: SliderTheme.of(context).copyWith(
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 12.0),
      ),
      child: Slider(
        min: 0.0,
        max: widget.maxValue,
        value: _currentValue,
        divisions: (widget.maxValue / widget.step).toInt(),
        activeColor: widget.color,
        onChanged: (newValue) {
          setState(() {
            _currentValue = newValue;
          });
          widget.onChanged(newValue);
        },
        onChangeEnd: widget.onChangeEnd,
      ),
    );

    final labelText = Text(
      widget.label,
      style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
    );


    if (widget.isHorizontal) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          labelText,
          SizedBox(
            width: 200,
            child: slider,
          ),
        ],
      ); 
    } else {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 200,
            child: RotatedBox(
              quarterTurns: 3,
              child: slider,
            ),
          ),
          labelText,
        ],
      );
    }
  }
}