import 'package:flutter/material.dart';

enum AddressInputError {
  none, invalidFormat, invalidAddress, invalidHostType;
  
  String get errorMessage {
    switch (this) {
      case AddressInputError.invalidFormat:
        return 'Invalid format';
      case AddressInputError.invalidAddress:
        return 'Invalid address';
      case AddressInputError.invalidHostType:
        return 'Invalid device type';
      default:
        return '';
    }
  }
}

class AddressInputField extends StatelessWidget {
  final TextEditingController controller;
  final AddressInputError error;

  const AddressInputField({
    super.key, 
    required this.controller,
    required this.error
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: const Color.fromARGB(255, 0, 0, 0),
        hintText: 'Write address',
        hintStyle: const TextStyle(color: Color.fromARGB(255, 120, 120, 120)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: const BorderSide(color: Color.fromARGB(255, 120, 120, 120)),
        ),
        errorText: error != AddressInputError.none ? error.errorMessage : null,
      ),
      style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
    );
  }
}