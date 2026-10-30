import 'package:flutter/material.dart';
import 'package:mobile_app/widgets/app_text_field.dart';

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
    return AppTextField(
      controller: controller,
      hintText: 'Write address',
      errorText: error != AddressInputError.none ? error.errorMessage : null,
    );
  }
}