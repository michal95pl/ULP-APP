import 'package:flutter/material.dart';
import 'package:mobile_app/utils/app_colors.dart';

abstract final class AppSnackBar {

  static void _show(
    BuildContext context, 
    String title, 
    String message, 
    IconData icon, 
    Color accentColor,
    Color backgroundColor,
  ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: accentColor, width: 1),
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: accentColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static void showError(BuildContext context, {required String title, required String message}) {
    _show(
      context,
      title,
      message,
      Icons.error_outline,
      AppColors.redSnackbarColor,
      AppColors.errorSnackbarBackgroundColor,
    );
  }

  static void showSuccess(BuildContext context, {required String title, required String message}) {
    _show(
      context,
      title,
      message,
      Icons.check_circle_outline,
      AppColors.greenSnackbarColor,
      AppColors.successSnackbarBackgroundColor,
    );
  }
}