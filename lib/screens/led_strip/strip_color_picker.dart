import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

class StripColorPicker {

  HSVColor _color1 = const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0);
  HSVColor _color2 = const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0);

  Future<void>? _onChangedPicker1;
  Future<void>? _onChangedPicker2;

  // ignore: use_function_type_syntax_for_parameters
  Row getColorPicker(State state, Future<void> onChangedPicker1(Color color), Future<void> onChangedPicker2(Color color), bool isDoubleColor, bool isActive, bool suspend) {
    return Row(children: [
      Expanded(
        child: FutureBuilder(
          future: _onChangedPicker1,
          builder: (context, snapshot) {
            return PaletteHuePicker(
              color: _color1,
              onChanged: (value) {
                if (snapshot.connectionState != ConnectionState.waiting && isActive)
                {
                  if (!suspend) {
                    _color1 = value;
                    _onChangedPicker1 = onChangedPicker1(_color1.toColor());
                  }
                  // todo: move setState to if statement (may increase performance)
                  state.setState(() {});
                }
              },
            );
          },
        ),
      ),
      const SizedBox(width: 10),
      if (isDoubleColor)
      Expanded(
        child: FutureBuilder(
          future: _onChangedPicker2,
          builder: (context, snapshot) {
            return PaletteHuePicker(
              color: _color2,
              onChanged: (value) {
                if (snapshot.connectionState != ConnectionState.waiting && isActive)
                {
                  if (!suspend) {
                    _color2 = value;
                    _onChangedPicker2 = onChangedPicker2(_color2.toColor());
                  }
                  // todo: move setState to if statement (may increase performance)
                  state.setState(() {});
                }
              },
            );
          },
        ),
      ),
    ]);
  }

  HSVColor getColor1() {
    return _color1;
  }

  HSVColor getColor2() {
    return _color2;
  }

  void setColor1(List<int> color) {
    _color1 = HSVColor.fromColor(Color.fromARGB(255, color[0], color[1], color[2]));
  }

  void setColor2(List<int> color) {
    _color2 = HSVColor.fromColor(Color.fromARGB(255, color[0], color[1], color[2]));
  }
}