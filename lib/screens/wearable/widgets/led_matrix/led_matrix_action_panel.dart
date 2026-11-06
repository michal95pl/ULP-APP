import 'package:flutter/material.dart';
import 'package:mobile_app/utils/app_colors.dart';
import 'package:mobile_app/widgets/labeled_icon_button.dart';

class LedMatrixActionPanel extends StatelessWidget {
  final int currentPage;
  final int maxPages;
  final VoidCallback onNextPage;
  final VoidCallback onLoadPattern;
  final VoidCallback onSavePattern;
  final VoidCallback onClear;
  final VoidCallback onSend;

  const LedMatrixActionPanel({
    super.key,
    required this.currentPage,
    required this.maxPages,
    required this.onNextPage,
    required this.onLoadPattern,
    required this.onSavePattern,
    required this.onClear,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 5),
          _buildPageButton(
            fraction: '${currentPage + 1}/$maxPages',
            label: 'Page',
            onTap: onNextPage,
            color: Colors.white70,
          ),
          const SizedBox(width: 5),
          LabeledIconButton(
            icon: Icons.folder_open_outlined,
            label: 'Load',
            onTap: onLoadPattern,
          ),
          const SizedBox(width: 5),
          LabeledIconButton(
            icon: Icons.save_outlined,
            label: 'Save',
            onTap: onSavePattern,
          ),
          const SizedBox(width: 5),
          LabeledIconButton(
            icon: Icons.cleaning_services_rounded,
            label: 'Clear',
            color: Colors.redAccent.shade100,
            onTap: onClear,
          ),
          const SizedBox(width: 5),
          LabeledIconButton(
            icon: Icons.send_rounded,
            label: 'Send',
            color: AppColors.sendButtonColor,
            onTap: onSend,
          ),
          const SizedBox(width: 5),
        ],
      ),
    );
  }

  Widget _buildPageButton({
    required String fraction,
    required String label,
    required VoidCallback onTap,
    Color color = Colors.white70,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: Center(
                child: Text(
                  fraction,
                  style: TextStyle(
                    color: color,
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}