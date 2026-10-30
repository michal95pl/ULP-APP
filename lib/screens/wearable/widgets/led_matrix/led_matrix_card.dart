import 'package:flutter/material.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/led_matrix.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/led_matrix_action_panel.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/led_matrix_controller.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/sheets/load_led_matrix_sheet.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/sheets/save_led_matrix_sheet.dart';
import 'package:mobile_app/utils/app_colors.dart';

class LedMatrixCard extends StatelessWidget {

  final LedMatrixController controller;
  final Function() onSend;

  const LedMatrixCard({
    super.key,
    required this.controller,
    required this.onSend,
  });

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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          children: [
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1.0,
                  child: LedMatrix(
                    controller: controller,
                    onPixelChanged: (x, y) {
                      controller.setPixel(x, y);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            ListenableBuilder(
              listenable: controller.currentPageNotifier,
              builder: (context, _) {
                return LedMatrixActionPanel(
                  currentPage: controller.currentPage,
                  maxPages: controller.maxPages,
                  onNextPage: () {
                    final next = (controller.currentPage + 1) % controller.maxPages;
                    controller.setFrame(next);
                  },
                  onSend: onSend,
                  onLoadPattern: () {LoadLedMatrixSheet.show(context, controller: controller);},
                  onSavePattern: () {SaveLedMatrixSheet.show(context, controller: controller);},
                  onClear: () {controller.clearCurrentFrame();},
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}