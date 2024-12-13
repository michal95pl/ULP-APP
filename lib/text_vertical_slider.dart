import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class TextVerticalSlider {

  double _value = 0.0;
  final String label;
  final Color color;
  final maxValue;

  TextVerticalSlider(this.label, this.maxValue, this.color);

  Column getSlider(State state, Function onChanged, bool isActive) {
    return Column(children: [
      SizedBox(
        height: 350,
        child: SfSlider.vertical(
          min: 0.0,
          max: maxValue,
          value: _value,
          interval: 1.0,
          activeColor: color,
          onChanged: isActive? (dynamic value) {
            state.setState(() {
              _value = value;
            });
            onChanged(value.toInt());
          } : null,
        ),
      ),
      Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10
        )
      )
    ]);
  }

  get value => _value;
}