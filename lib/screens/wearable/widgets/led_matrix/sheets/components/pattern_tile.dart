import 'package:flutter/material.dart';
import 'package:mobile_app/utils/app_colors.dart';

class PatternTile extends StatelessWidget {
  final String fileName;
  final bool isSelected;
  final VoidCallback onTap;

  const PatternTile({
    super.key, 
    required this.fileName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20.0),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14.0, horizontal: 16.0),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.navBarActiveColor.withAlpha(80)
                : AppColors.cardBackgroundColor,
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              color: isSelected ? AppColors.navBarActiveColor : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Text(
            fileName,
            style: TextStyle(
              color: isSelected ? AppColors.navBarActiveColor : Colors.white,
              fontSize: 15.0,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}