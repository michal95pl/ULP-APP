import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/text_slider.dart';

class EffectSliderPanel extends StatelessWidget{
  
  const EffectSliderPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextVerticalSlider(
          isHorizontal: true,
          label: 'Speed',
          maxValue: 100,
          color: Colors.blue,
          initialValue: 50.0,
          onChanged: (value) {
            
          },
        ),
        const SizedBox(width: 16),
        TextVerticalSlider(
          isHorizontal: true,
          label: 'Intensity',
          maxValue: 100,
          color: Colors.red,
          initialValue: 75.0,
          onChanged: (value) {
            
          },
        ),
      ],
    );
  }

}