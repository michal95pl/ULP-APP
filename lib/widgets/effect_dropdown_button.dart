import 'package:flutter/material.dart';

class EffectDropdownButton<T extends Enum> extends StatelessWidget{

  final T currentEffect;
  final ValueChanged<T> onChanged;
  final List<T> effects;

  const EffectDropdownButton({
    super.key,
    required this.onChanged,
    required this.currentEffect,
    required this.effects,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black26,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<T>(
        value: currentEffect,
        underline: const SizedBox(),
        isDense: true,
        alignment: Alignment.center,
        iconSize: 0.0,
        icon: const SizedBox.shrink(),
        dropdownColor: Colors.black,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        onChanged: (T? newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items: effects.map<DropdownMenuItem<T>>((T value) {
          return DropdownMenuItem<T>(
            value: value,
            child: Text(value.name),
          );
        }).toList(),
      ),
    );
  }
}