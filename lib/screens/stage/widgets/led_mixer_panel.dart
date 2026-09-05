import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app/model/stage/stage_strip_data.dart';
import 'package:mobile_app/screens/stage/models/addresable_strip_effects.dart';
import 'package:mobile_app/screens/stage/models/analog_strip_effects.dart';
import 'package:mobile_app/screens/stage/widgets/led_mixer_channel.dart';
import 'package:mobile_app/utils/app_colors.dart';
import 'package:mobile_app/widgets/dual_color_picker.dart';

class LedMixerPanel extends StatefulWidget {
  final List<StageStripData<AddresableStripEffects>> addresableDataStrips;
  final List<StageStripData<AnalogStripEffects>> analogDataStrips;

  final Function(int, AddresableStripEffects) onChangedAddresableEffect;
  final Function(int, AnalogStripEffects) onChangedAnalogEffect;
  final Function(int, double) onChangedSlider;
  final Function(int, double) endChangedSlider;
  final Function(int, Color) onChangedColor1;
  final Function(int, Color) endChangedColor1;
  final Function(int, Color) onChangedColor2;
  final Function(int, Color) endChangedColor2;
  
  const LedMixerPanel({super.key, 
    required this.addresableDataStrips, 
    required this.analogDataStrips,
    required this.onChangedAddresableEffect,
    required this.onChangedAnalogEffect,
    required this.onChangedSlider,
    required this.endChangedSlider,
    required this.onChangedColor1,
    required this.endChangedColor1,
    required this.onChangedColor2,
    required this.endChangedColor2,
  }) 
    : assert(addresableDataStrips.length == 2, 'Addresable strips must have a length of 2'),
      assert(analogDataStrips.length == 2, 'Analog strips must have a length of 2');

  @override
  State<LedMixerPanel> createState() => _LedMixerPanelState();
}

class _LedMixerPanelState extends State<LedMixerPanel> {

  final List<bool> _channelSelected = List.generate(4, (index) => false);
  late List<AnalogStripEffects> _analogEffects;
  late List<AddresableStripEffects> _addresableEffects;
  late List<Color> _initialColors1;
  late List<Color> _initialColors2;

  @override
  void initState() {
    super.initState();
    _channelSelected[0] = true;
    _analogEffects = widget.analogDataStrips.map((s) => s.effect).toList();
    _addresableEffects = widget.addresableDataStrips.map((s) => s.effect).toList();

    _initialColors1 = widget.addresableDataStrips.map((s) => s.color1).toList() + 
                      widget.analogDataStrips.map((s) => s.color1).toList();

    _initialColors2 = widget.addresableDataStrips.map((s) => s.color2).toList() + 
                      widget.analogDataStrips.map((s) => s.color2).toList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant LedMixerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    final newAnalogEffects = widget.analogDataStrips.map((s) => s.effect).toList();
    final newAddresableEffects = widget.addresableDataStrips.map((s) => s.effect).toList();

    final newColors1 = widget.addresableDataStrips.map((s) => s.color1).toList() + 
                       widget.analogDataStrips.map((s) => s.color1).toList();
                       
    final newColors2 = widget.addresableDataStrips.map((s) => s.color2).toList() + 
                       widget.analogDataStrips.map((s) => s.color2).toList();

    if (!listEquals(_analogEffects, newAnalogEffects) || 
        !listEquals(_addresableEffects, newAddresableEffects) ||
        !listEquals(_initialColors1, newColors1) ||
        !listEquals(_initialColors2, newColors2)) {
      setState(() {
        _analogEffects = newAnalogEffects;
        _addresableEffects = newAddresableEffects;
        _initialColors1 = newColors1;
        _initialColors2 = newColors2;
      });
    }
  }

  void _onAddresableChangedEffect(int channelIndex, AddresableStripEffects newEffect) {
    setState(() {
      _addresableEffects[channelIndex] = newEffect;
    });
    widget.onChangedAddresableEffect(channelIndex, newEffect);
  }

  void _onAnalogChangedEffect(int channelIndex, AnalogStripEffects newEffect) {
    setState(() {
      _analogEffects[channelIndex-2] = newEffect;
    });
    widget.onChangedAnalogEffect(channelIndex, newEffect);
  }

  void _activeChannelChanged(int channelIndex) {
    setState(() {
      _channelSelected.fillRange(0, _channelSelected.length, false);
      _channelSelected[channelIndex] = true;
    });
  }

  void _onChangedColor1(Color newColor) {
    widget.onChangedColor1(_channelSelected.indexOf(true), newColor);
  }

  void _endChangedColor1(Color newColor) {
    widget.endChangedColor1(_channelSelected.indexOf(true), newColor);
  }

  void _onChangedColor2(Color newColor) {
    widget.onChangedColor2(_channelSelected.indexOf(true), newColor);
  }

  void _endChangedColor2(Color newColor) {
    widget.endChangedColor2(_channelSelected.indexOf(true), newColor);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.cardBackgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: SingleChildScrollView( 
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DualColorPicker(
              paletteHeight: 200.0,
              initialColor1: _initialColors1[_channelSelected.indexOf(true)],
              initialColor2: _initialColors2[_channelSelected.indexOf(true)],
              onChangedColor1: _onChangedColor1,
              onEndChangedColor1: _endChangedColor1,
              onChangedColor2: _onChangedColor2,
              onEndChangedColor2: _endChangedColor2,
              isDoubleColorMode: _isCurrentEffectDualColor,
            ),
            const SizedBox(height: 15.0),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ... List.generate(2, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: LedMixerChannel<AddresableStripEffects>(
                      sliderInitValue: widget.addresableDataStrips[index].brightness,
                      channelName: 'D${index + 1}',
                      channelIndex: index,
                      isSelected: _channelSelected[index],
                      currentEffect: _addresableEffects[index],
                      effects: AddresableStripEffects.values,
                      onChangedEffect: _onAddresableChangedEffect,
                      onChangedSlider: widget.onChangedSlider,
                      endChangedSlider: widget.endChangedSlider,
                      activeChannelChanged: _activeChannelChanged,
                    ),
                  );
                }),

                ... List.generate(2, (index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: LedMixerChannel<AnalogStripEffects>(
                      sliderInitValue: widget.analogDataStrips[index].brightness,
                      channelName: 'A${index + 1}',
                      channelIndex: index+2,
                      isSelected: _channelSelected[index+2],
                      currentEffect: _analogEffects[index],
                      effects: AnalogStripEffects.values,
                      onChangedEffect: _onAnalogChangedEffect,
                      onChangedSlider: widget.onChangedSlider,
                      endChangedSlider: widget.endChangedSlider,
                      activeChannelChanged: _activeChannelChanged,
                    ),
                  );
                }),
              ],
            ),
          ],
        ),
      ),
    );
  }

  bool get _isCurrentEffectDualColor {
    final selectedIndex = _channelSelected.indexOf(true);
    if (selectedIndex == -1) return false;

    if (selectedIndex < 2) {
      return _addresableEffects[selectedIndex].needsDualColorPicker();
    } else {
      return _analogEffects[selectedIndex - 2].needsDualColorPicker();
    }
  }
}