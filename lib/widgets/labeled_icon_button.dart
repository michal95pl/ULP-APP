import 'package:flutter/material.dart';

class LabeledIconButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final bool isEnabled;

  const LabeledIconButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.color = Colors.white70,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = isEnabled ? color : color.withAlpha(60);
    
    return InkWell(
      onTap: isEnabled ? onTap : null,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: effectiveColor, size: 28),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: effectiveColor,
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