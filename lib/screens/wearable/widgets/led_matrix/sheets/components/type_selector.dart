import 'package:flutter/material.dart';
import 'package:mobile_app/utils/app_colors.dart';

enum MatrixSourceType {pixelArt, images}

class TypeSelector extends StatelessWidget {
  final MatrixSourceType selectedType;
  final ValueChanged<MatrixSourceType> onTypeChanged;
  final bool isEnabled;

  const TypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeChanged,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7.0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(14.0),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SegmentTab(
              title: 'Projects',
              icon: Icons.grid_on_rounded,
              isActive: selectedType == MatrixSourceType.pixelArt,
              onTap: () => onTypeChanged(MatrixSourceType.pixelArt),
              isEnabled: isEnabled,
            ),
          ),
          Expanded(
            child: _SegmentTab(
              title: 'Images',
              icon: Icons.image_outlined,
              isActive: selectedType == MatrixSourceType.images,
              onTap: () => onTypeChanged(MatrixSourceType.images),
              isEnabled: isEnabled,
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;
  final bool isEnabled;

  const _SegmentTab({
    required this.title,
    required this.icon,
    required this.isActive,
    required this.onTap,
    required this.isEnabled,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10.0),
        decoration: BoxDecoration(
          color: isActive ? (isEnabled ? AppColors.cardBackgroundColor : Colors.white12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isActive && isEnabled ? AppColors.navBarActiveColor : Colors.white54,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: isActive && isEnabled ? Colors.white : Colors.white54,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}