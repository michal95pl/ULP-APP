import 'package:flutter/material.dart';
import 'package:flutter_hsvcolor_picker/flutter_hsvcolor_picker.dart';

class StripColorPicker {

  HSVColor color1 = const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0);
  HSVColor color2 = const HSVColor.fromAHSV(1.0, 0.0, 1.0, 1.0);

  Row getColorPicker(State state, bool isDoubleColor, Function onChangedPicker1, Function onChangedPicker2) {
    return Row(children: [
      Expanded(
        child: FutureBuilder(
          future: Future.delayed(const Duration(milliseconds: 100)),
          builder: (context, snapshot) {
            return PaletteHuePicker(
              color: color1,
              onChanged: (value) {
                if (snapshot.connectionState == ConnectionState.done)
                {
                   state.setState(() {});
                  color1 = value;
                  onChangedPicker1(value.toColor());
                }
               
              },
            );
          },
        ),
      )
        // PaletteHuePicker(
        //   color: color1,
        //   onChanged: (value) async {
        //     state.setState(() {
        //       color1 = value;
        //     });
            
        //     await Future.delayed(const Duration(seconds: 100));
        //   },
        // ),
      //), 
      // const SizedBox(width: 10),
      // if (isDoubleColor)
      //   Expanded(
      //     child: PaletteHuePicker(
      //       color: color2,
      //       onChanged: (value) {
      //         state.setState(() {
                
      //         });
      //         color2 = value;
      //         onChangedPicker2(value.toColor());
      //       },
      //     ),
      //   ),
    ]);
  }

  HSVColor getColor1() {
    return color1;
  }

  HSVColor getColor2() {
    return color2;
  }
}