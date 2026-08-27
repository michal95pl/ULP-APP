import 'package:flutter/material.dart';
import 'package:mobile_app/communication/device_manager.dart';
import 'package:mobile_app/communication/devices_listener.dart';
import 'package:mobile_app/widgets/bottom_nav.dart';
import 'package:mobile_app/widgets/effect_dropdown_button.dart';
import 'package:mobile_app/widgets/strip_color_picker.dart';
import 'package:mobile_app/screens/settings/widgets/info_board.dart';
import 'package:mobile_app/widgets/statistics_app_bar.dart';
import 'package:mobile_app/model/status_mobile_data.dart';
import 'package:mobile_app/widgets/text_vertical_slider.dart';

class LedStripScreen extends StatefulWidget {
  const LedStripScreen({super.key});

  @override
  State<LedStripScreen> createState() => LedStripScreenState();
}

class LedStripScreenState extends State<LedStripScreen> 
with DevicesListener {

  static TextVerticalSlider brightnessSlider = TextVerticalSlider("Brightness", 100, const Color.fromARGB(255, 243, 32, 250));
  static TextVerticalSlider speedEffectSlider = TextVerticalSlider("Speed", 100, const Color.fromARGB(255, 20, 242, 224));
  static EffectDropdownButton effectDropdownButton = EffectDropdownButton();
  static StripColorPicker stripColorPicker = StripColorPicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: DrawerNav.getDrawerNav(context),
      appBar: StatisticsAppBar(isMobileConnected: false, isStageConnected: false, isSynchEnabled: false),
      backgroundColor: const Color.fromARGB(255, 40, 53, 87),
      body: Column(children: [
        stripColorPicker.getColorPicker(this, (value) async {await DeviceManager.instance.mobile.sendPrimaryStripColor(value);}, (value) async {await DeviceManager.instance.mobile.sendSecondaryStripColor(value);}, true, DeviceManager.instance.mobile.isConnected(), !DeviceManager.instance.mobile.isReadyToSend()),
        Row(children: [
          brightnessSlider.getSlider(this, (value) async {await DeviceManager.instance.mobile.sendStripBrightness(value);}, DeviceManager.instance.mobile.isConnected(), !DeviceManager.instance.mobile.isReadyToSend()),
          speedEffectSlider.getSlider(this, (value) async {await DeviceManager.instance.mobile.sendStripSpeedEffect(value);}, DeviceManager.instance.mobile.isConnected(), !DeviceManager.instance.mobile.isReadyToSend()),
          effectDropdownButton.getDropdownButton(this, (value) async {await DeviceManager.instance.mobile.sendStripEffect(value);}, DeviceManager.instance.mobile.isConnected(), !DeviceManager.instance.mobile.isReadyToSend()),
        ])
      ])
    );
  }
  
  @override
  void onMobileConnectionChanged(bool isConnected) {
    debugPrint("[LedStripScreenState] mobile connection status changed: $isConnected");
    if (!isConnected) {
      InfoBoard.hideBoard();
    }
    setState(() {});
  }

  @override
  void onMobileDataReceived(StatusMobileData data) {
    brightnessSlider.updateValue(data.stripBrightness.toDouble());
    speedEffectSlider.updateValue(data.stripSpeedEffect.toDouble());
    effectDropdownButton.currentEffect = EFFECTS.values[data.stripEffect];
    stripColorPicker.setColor1(data.stripFirstColor);
    stripColorPicker.setColor2(data.stripSecondColor);
    setState(() {});
  }
}