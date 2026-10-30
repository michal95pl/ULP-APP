import 'package:flutter/material.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/led_matrix_controller.dart';
import 'package:mobile_app/utils/app_colors.dart';
import 'package:mobile_app/utils/app_snack_bar.dart';
import 'package:mobile_app/widgets/app_text_field.dart';

class SaveLedMatrixSheet extends StatefulWidget {

  final LedMatrixController controller;

  const SaveLedMatrixSheet({
    super.key,
    required this.controller,
  });

  static void show(BuildContext context, {required LedMatrixController controller}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.cardBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      builder: (context) => SaveLedMatrixSheet(controller: controller),
    );
  }

  @override
  State<SaveLedMatrixSheet> createState() => _SaveLedMatrixSheetState();
}

class _SaveLedMatrixSheetState extends State<SaveLedMatrixSheet> {
  final TextEditingController _controller = TextEditingController();

  String? _errorText = null;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20.0,
          right: 20.0,
          top: 20.0,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20.0,
        ),
        child: Row(
          children: [
            Expanded(
              child: AppTextField(
                controller: _controller,
                hintText: 'filename',
                errorText: _errorText,
              ),
            ),
            const SizedBox(width: 12.0),
            FilledButton(
              onPressed: () async {
                if (_controller.text.trim().isEmpty) {
                  setState(() {
                    _errorText = 'cannot be empty';
                  });
                  return;
                }

                try {
                  await widget.controller.saveFile(_controller.text.trim());
                  if (!mounted) return;
                  AppSnackBar.showSuccess(context, title: 'Save', message: 'File saved successfully');
                  Navigator.of(context).pop();
                } catch (e) {
                  if (!mounted) return;
                  setState(() {
                    _errorText = e.toString();
                  });
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.buttonColor,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}