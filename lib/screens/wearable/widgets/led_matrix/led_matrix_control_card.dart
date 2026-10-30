import 'package:flutter/material.dart';
import 'package:mobile_app/model/mobile/effects/mobile_display_effects.dart';
import 'package:mobile_app/utils/app_colors.dart';
import 'package:mobile_app/widgets/custom_color_picker.dart';
import 'package:mobile_app/widgets/effect_dropdown_button.dart';
import 'package:mobile_app/widgets/text_slider.dart';

class LedMatrixControlCard extends StatelessWidget {

  final MobileDisplayEffects currentEffect;
  final double initialBrightness;
  final Color initialColor;
  final ValueChanged<MobileDisplayEffects?> onEffectChanged;
  final ValueChanged<double> onBrightnessChanged;
  final ValueChanged<double> onBrightnessChangeEnd;
  final ValueChanged<Color> onColorChanged;
  final ValueChanged<Color> onColorChangeEnd;
  final bool isColorPickerShown;

  const LedMatrixControlCard({
    super.key,
    required this.currentEffect,
    required  this.initialBrightness,
    required this.initialColor,
    required this.onEffectChanged,
    required this.onBrightnessChanged,
    required this.onBrightnessChangeEnd,
    required this.onColorChanged,
    required this.onColorChangeEnd,
    this.isColorPickerShown = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColors.cardBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
        child: Row(children: [
          Column(children: [
            EffectDropdownButton<MobileDisplayEffects>(
              onChanged: onEffectChanged,
              currentEffect: currentEffect,
              effects: MobileDisplayEffects.values,
            ),
            TextVerticalSlider(
              label: 'Brightness',
              color: AppColors.navBarActiveColor,
              maxValue: 255.0,
              initialValue: initialBrightness,
              step: 1.0,
              onChanged: onBrightnessChanged,
              onChangeEnd: onBrightnessChangeEnd,
            ),
          ]),
          
          if (isColorPickerShown) ...[
            const SizedBox(width: 25),
            Expanded(
              child: CustomColorPicker(
                paletteHeight: 170,
                onChanged: onColorChanged,
                onChangedEnd: onColorChangeEnd,
                initialColor: initialColor,
              )
            )
          ],
        ]),
      ),
    );
  }

}