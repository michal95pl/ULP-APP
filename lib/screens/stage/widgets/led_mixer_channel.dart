import 'package:flutter/material.dart';
import 'package:mobile_app/utils/app_colors.dart';
import 'package:mobile_app/widgets/effect_dropdown_button.dart';
import 'package:mobile_app/widgets/text_slider.dart';

class LedMixerChannel<T extends Enum> extends StatelessWidget {

  final T currentEffect;
  final List<T> effects;
  final String channelName;
  final int channelIndex;
  final bool isSelected;
  final int sliderInitValue;

  final Function(int, T) onChangedEffect;
  final Function(int, double) onChangedSlider;
  final Function(int, double) endChangedSlider;
  final Function(int) activeChannelChanged;

  const LedMixerChannel({
    super.key,
    required this.channelName,
    required this.channelIndex,
    required this.isSelected,
    required this.currentEffect,
    required this.effects,
    required this.sliderInitValue,
    required this.onChangedEffect,
    required this.onChangedSlider,
    required this.endChangedSlider,
    required this.activeChannelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        EffectDropdownButton<T>(
          onChanged: (newEffect) {
            onChangedEffect(channelIndex, newEffect);
          },
          currentEffect: currentEffect, 
          effects: effects,
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          color: isSelected ? AppColors.navBarActiveColor : AppColors.navBarInactiveColor,
          onPressed: () {
            activeChannelChanged(channelIndex);
          },
        ),
        TextVerticalSlider(
          initialValue: sliderInitValue.toDouble(),
          label: channelName,
          maxValue: 100,
          color: AppColors.navBarActiveColor,
          onChanged: (value) {
            onChangedSlider(channelIndex, value);
          },
          onChangeEnd: (value) {
            endChangedSlider(channelIndex, value);
          },
        ),
      ],
    );
  }
}