import 'package:flutter/material.dart';
import 'package:mobile_app/communication/device_connection_guards.dart';
import 'package:mobile_app/communication/device_manager.dart';
import 'package:mobile_app/communication/devices_listener.dart';
import 'package:mobile_app/model/stage/stage_strip_data.dart';
import 'package:mobile_app/screens/stage/models/addresable_strip_effects.dart';
import 'package:mobile_app/screens/stage/models/analog_strip_effects.dart';
import 'package:mobile_app/screens/stage/widgets/led_mixer_panel.dart';
import 'package:mobile_app/utils/app_routes.dart';
import 'package:mobile_app/widgets/bottom_nav.dart';
import 'package:mobile_app/model/stage/status_stage_data.dart';
import 'package:mobile_app/widgets/statistics_app_bar.dart';
import 'package:mobile_app/model/status_mobile_data.dart';

class StageLedStripScreen extends StatefulWidget {
  const StageLedStripScreen({super.key});

  @override
  State<StageLedStripScreen> createState() => StageLedStripScreenState();
}

class StageLedStripScreenState extends State<StageLedStripScreen> 
with DevicesListener, RequiresStageConnection {

  @override
  Widget build(BuildContext context) {
  List<StageStripData<AddresableStripEffects>> addresableStrips = 
    DeviceManager.instance.lastStageStatus?.addresableStrips ?? 
    List.generate(
      2, 
      (index) => StageStripData.getDefaultData<AddresableStripEffects>(
        AddresableStripEffects.color,
      ),
    );

  List<StageStripData<AnalogStripEffects>> analogStrips = 
    DeviceManager.instance.lastStageStatus?.analogStrips ??
    List.generate(
      2, 
      (index) => StageStripData.getDefaultData<AnalogStripEffects>(
        AnalogStripEffects.color,
      ),
    );
      
    return Scaffold(
      appBar: StatisticsAppBar(
        isMobileConnected: DeviceManager.instance.mobile.isConnected(), 
        isStageConnected: DeviceManager.instance.stage.isConnected(), 
        isSynchEnabled: false
      ),
      bottomNavigationBar: BottomNav(currentRoute: AppRoutes.stageLed, isMobileConnected: DeviceManager.instance.mobile.isConnected(), isStageConnected: DeviceManager.instance.stage.isConnected()),
      backgroundColor: const Color.fromARGB(255, 40, 53, 87),
      body: Center(
        child: LedMixerPanel(
          addresableDataStrips: addresableStrips,
          analogDataStrips: analogStrips,
          onChangedAddresableEffect: (channelIndex, newEffect) {
            DeviceManager.instance.stage.sendGuaranteedEffect(channelIndex, newEffect.index);
          },
          onChangedAnalogEffect: (channelIndex, newEffect) {
            DeviceManager.instance.stage.sendGuaranteedEffect(channelIndex, newEffect.index);
          },
          onChangedSlider: (channelIndex, newValue) {
            DeviceManager.instance.stage.sendBrightness(channelIndex, newValue.toInt());
          },
          endChangedSlider: (channelIndex, newValue) {
            DeviceManager.instance.stage.sendGuaranteedBrightness(channelIndex, newValue.toInt());
          },
          onChangedColor1: (channelIndex, newColor) {
            DeviceManager.instance.stage.sendColor(channelIndex, newColor);
          },
          endChangedColor1: (channelIndex, newColor) {
            DeviceManager.instance.stage.sendGuaranteedColor(channelIndex, newColor);
          },
          onChangedColor2: (channelIndex, newColor) {
            DeviceManager.instance.stage.sendColor(channelIndex + 4, newColor);
          },
          endChangedColor2: (channelIndex, newColor) {
            DeviceManager.instance.stage.sendGuaranteedColor(channelIndex + 4, newColor);
          },
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
  void onMobileDataReceived(StatusMobileData data) {
    super.onMobileDataReceived(data);
    debugPrint("[StageLedStripScreenState] mobile data received: $data");
    setState(() {});
  }

  @override
  void onStageConnectionChanged(bool isConnected) {
    super.onStageConnectionChanged(isConnected);
    debugPrint("[StageLedStripScreenState] stage connection status changed: $isConnected");
    setState(() {});
  }

  @override
  void onStageDataReceived(StatusStageData data) {
    super.onStageDataReceived(data);
    setState(() {});
  }

}