import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class TextVerticalSlider {

  double _value = 0.0;
  final String label;
  final Color color;
  final maxValue;

  TextVerticalSlider(this.label, this.maxValue, this.color);

  Future<void>? _onChangedFunc;

  // ignore: use_function_type_syntax_for_parameters
  FutureBuilder getSlider(State state, Future<void> onChanged(int value), bool isActive, bool suspend) {
    return FutureBuilder(
      future: _onChangedFunc,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Column(children: [
            SizedBox(
              height: 350,
              child: SfSlider.vertical(
                min: 0.0,
                max: maxValue,
                value: _value,
                interval: 1.0,
                activeColor: color,
                onChanged: (valu){},
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
        } else {
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
                  // wait for the previous command to finish
                  if (!suspend) {
                    _value = value;
                    _onChangedFunc = onChanged(value.toInt());
                  }
                  // todo: move setState to if statement (may increase performance)
                  state.setState(() {});
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
      }
    );
  }

  get value => _value;
}