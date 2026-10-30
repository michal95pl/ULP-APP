import 'package:flutter/material.dart';
import 'package:mobile_app/utils/app_colors.dart';
import 'package:mobile_app/widgets/app_text_field.dart';

class TextMatrixCard extends StatefulWidget {
  final ValueChanged<String> onTextSend;
  final String initialText;

  const TextMatrixCard({
    super.key,
    required this.onTextSend,
    this.initialText = '',
  });

  @override
  State<TextMatrixCard> createState() => _TextMatrixCardState();
}

class _TextMatrixCardState extends State<TextMatrixCard> {

  late final TextEditingController textController;
  String? errorText;

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.initialText);
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  bool isValidText(String text) {
    if (text.isEmpty) {
      setState(() {
        errorText = 'Text cannot be empty';
      });
      return false;
    }

    final regex = RegExp(r'^[A-Z0-9 ]+$');
    if (!regex.hasMatch(text)) {
      setState(() {
        errorText = 'Only letters and numbers are allowed';
      });
      return false;
    }
    if (errorText != null) {
      setState(() {
        errorText = null;
      });
    }
    
    return true;
  }

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children : [
            Expanded(
              child: AppTextField(
                controller: textController, 
                hintText: 'Enter text to display',
                errorText: errorText,
              ),
            ),
            const SizedBox(width: 5.0),
            IconButton(
              color: AppColors.sendButtonColor,
              icon: const Icon(Icons.send),
              onPressed: () {
                final currentText = textController.text.toUpperCase();
                
                if (isValidText(currentText)) {
                  widget.onTextSend(currentText);
                }
              }
            ),
          ]
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(covariant TextMatrixCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialText != widget.initialText) {
      textController.text = widget.initialText;
    }
  }
}