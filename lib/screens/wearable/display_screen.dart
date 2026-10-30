import 'package:flutter/material.dart';
import 'package:mobile_app/communication/device_connection_guards.dart';
import 'package:mobile_app/communication/device_manager.dart';
import 'package:mobile_app/communication/devices_listener.dart';
import 'package:mobile_app/model/mobile/data/display_mobile_data.dart';
import 'package:mobile_app/model/mobile/status_mobile_data.dart';
import 'package:mobile_app/model/mobile/effects/mobile_display_effects.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/led_matrix_card.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/led_matrix_control_card.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/led_matrix_manager.dart';
import 'package:mobile_app/screens/wearable/widgets/text_matrix_card.dart';
import 'package:mobile_app/utils/app_routes.dart';
import 'package:mobile_app/widgets/bottom_nav.dart';
import 'package:mobile_app/widgets/statistics_app_bar.dart';

class DisplayScreen extends StatefulWidget {

  const DisplayScreen({super.key});

  @override
  State<DisplayScreen> createState() => DisplayScreenState();
}

class DisplayScreenState extends State<DisplayScreen>
  with DevicesListener, RequiresMobileConnection { 

  static const int displayId = 1;

  DisplayMobileData currentDisplayData = DeviceManager.instance.lastMobileStatus?.displayData ?? DisplayMobileData.getDefaultData();

  void _onEffectChanged(MobileDisplayEffects? effect) {
    setState(() {
      currentDisplayData.displayEffect = effect!;
    });
    DeviceManager.instance.mobile.sendGuaranteedEffect(displayId, effect!.index);
  }

  void _onBrightnessChanged(double brightness) {
    currentDisplayData.displayBrightness = brightness;
    DeviceManager.instance.mobile.sendBrightness(displayId, brightness.toInt());
  }

  void _onColorChanged(Color color) {
    if (currentDisplayData.displayEffect == MobileDisplayEffects.matrix) {
      LedMatrixManager.instance.backController.selectedColor = color;
    } else {
      DeviceManager.instance.mobile.sendColor(displayId, color);
      currentDisplayData.textColor = color;
    }
  }

  void _onColorChangeEnd(Color color) {
    if (currentDisplayData.displayEffect != MobileDisplayEffects.matrix) {
      DeviceManager.instance.mobile.sendGuaranteedColor(displayId, color);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: StatisticsAppBar(
        isMobileConnected: DeviceManager.instance.mobile.isConnected(),
        isStageConnected: DeviceManager.instance.stage.isConnected(),
        isSynchEnabled: false
      ),
      bottomNavigationBar: BottomNav(currentRoute: AppRoutes.wearableDisplay, isMobileConnected: DeviceManager.instance.mobile.isConnected(), isStageConnected: DeviceManager.instance.stage.isConnected()),
      backgroundColor: const Color.fromARGB(255, 40, 53, 87),
      body: Center (
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const SizedBox(height: 15),
              currentDisplayData.displayEffect == MobileDisplayEffects.text
              ? TextMatrixCard(
                initialText: currentDisplayData.displayText,
                onTextSend: (String text) {
                  currentDisplayData.displayText = text;
                  DeviceManager.instance.mobile.sendGuaranteedDisplayText(displayId, text);
                },
              )
              : Expanded(
                  child: LedMatrixCard(
                    controller: LedMatrixManager.instance.backController,
                    onSend: () {
                      DeviceManager.instance.mobile.sendGuaranteedAllDisplayFrame(displayId, LedMatrixManager.instance.backController.getAllFramesAsBytes());
                    },
                  ),
                ),

              const SizedBox(height: 15),
              LedMatrixControlCard(
                currentEffect: currentDisplayData.displayEffect,
                initialBrightness: currentDisplayData.displayBrightness,
                initialColor: currentDisplayData.displayEffect == MobileDisplayEffects.text ? currentDisplayData.textColor : LedMatrixManager.instance.backController.selectedColor,
                onEffectChanged: _onEffectChanged,
                onBrightnessChanged: _onBrightnessChanged,
                onBrightnessChangeEnd: (double brightness) {DeviceManager.instance.mobile.sendGuaranteedBrightness(displayId, brightness.toInt());},
                onColorChanged: _onColorChanged,
                onColorChangeEnd: _onColorChangeEnd
              ),
              const SizedBox(height: 15),
            ],
          ),
        ), 
      ),
    );
  }

  @override
  void onMobileConnectionChanged(bool isConnected) {
    super.onMobileConnectionChanged(isConnected);
    debugPrint("[StageLedStripScreenState] mobile connection status changed: $isConnected");
    setState(() {});
  }

  @override
  void onStageConnectionChanged(bool isConnected) {
    super.onStageConnectionChanged(isConnected);
    debugPrint("[StageLedStripScreenState] stage connection status changed: $isConnected");
    setState(() {});
  }

  @override
  void onMobileDataReceived(StatusMobileData data) {
    super.onMobileDataReceived(data);
    debugPrint("[StageLedStripScreenState] mobile data received: $data");
    currentDisplayData = data.displayData;
    setState(() {});
  }
}
