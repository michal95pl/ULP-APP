import 'package:flutter/material.dart';

enum EFFECTS {color, rainbow}

class EffectDropdownButton {

  EFFECTS currentEffect = EFFECTS.color;

  DropdownButton<EFFECTS> getDropdownButton(State state, Function onChanged, bool isActive) {
    return DropdownButton<EFFECTS>(
      value: currentEffect,
      onChanged: isActive? (EFFECTS? value) {
        state.setState(() {
          currentEffect = value!;
        });
        onChanged(value!.index);
      } : null,
      items: EFFECTS.values.map((EFFECTS effect) {
        return DropdownMenuItem<EFFECTS>(
          value: effect,
          child: Text(effect.toString().split('.').last),
        );
      }).toList(),
    );
  }

  String getCurrentEffect() {
    return currentEffect.toString().split('.').last;
  }
}