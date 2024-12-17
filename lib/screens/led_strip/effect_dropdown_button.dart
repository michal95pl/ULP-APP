import 'dart:async';

import 'package:flutter/material.dart';

enum EFFECTS {color, rainbow}

class EffectDropdownButton {

  EFFECTS currentEffect = EFFECTS.color;

  Future<void>? _onChangedFunction;

  FutureBuilder getDropdownButton(State state, Future<void> onChanged(int val), bool isActive, bool suspend) {
    return FutureBuilder(
      future: _onChangedFunction,
      builder: (context, snapshot) {
        return DropdownButton<EFFECTS>(
          value: currentEffect,
          onChanged: isActive? (EFFECTS? value) {
            if (snapshot.connectionState != ConnectionState.waiting && isActive)
            {
              if (!suspend) {
                currentEffect = value!;
                _onChangedFunction = onChanged(value.index);
              }
              // todo: move setState to if statement (may increase performance)
              state.setState(() {});
            }
          } : null,
          items: EFFECTS.values.map((EFFECTS effect) {
            return DropdownMenuItem<EFFECTS>(
              value: effect,
              child: Text(
                effect.toString().split('.').last,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          dropdownColor: const Color.fromARGB(255, 18, 24, 43),
        );
      },
    );
  }

  String getCurrentEffect() {
    return currentEffect.toString().split('.').last;
  }
}