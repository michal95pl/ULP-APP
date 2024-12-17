import 'package:flutter/material.dart';
import 'package:mobile_app/communication/mobile_communication.dart';
import 'package:mobile_app/communication/mobile_connection_listener.dart';
import 'package:mobile_app/drawer_nav.dart';
import 'package:mobile_app/screens/led_strip/effect_dropdown_button.dart';
import 'package:mobile_app/screens/led_strip/strip_color_picker.dart';
import 'package:mobile_app/statistics_bar.dart';
import 'package:mobile_app/status_mobile_data.dart';
import 'package:mobile_app/text_vertical_slider.dart';

class LedStripScreen extends StatefulWidget {
  const LedStripScreen({super.key});

  @override
  State<LedStripScreen> createState() => LedStripScreenState();
}

class LedStripScreenState extends State<LedStripScreen> 
implements MobileConnectionListener {

  static TextVerticalSlider brightnessSlider = TextVerticalSlider("Brightness", 100, const Color.fromARGB(255, 243, 32, 250));
  static TextVerticalSlider speedEffectSlider = TextVerticalSlider("Speed", 100, const Color.fromARGB(255, 20, 242, 224));
  static EffectDropdownButton effectDropdownButton = EffectDropdownButton();
  static StripColorPicker stripColorPicker = StripColorPicker();

  @override
  void initState() {
    super.initState();
    MobileCommunication.setListener(this);
    MobileCommunication.sendStatusCommand();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerNav.getDrawerNav(context),
      appBar: StatisticsBar.getAppBar(),
      backgroundColor: const Color.fromARGB(255, 40, 53, 87),
      body: Column(children: [
        stripColorPicker.getColorPicker(this, (value) async {await MobileCommunication.sendPrimaryStripColor(value);}, (value) async {await MobileCommunication.sendSecondaryStripColor(value);}, true, MobileCommunication.isConnected(), !MobileCommunication.isReadyToSend()),
        Row(children: [
          brightnessSlider.getSlider(this, (value) async {await MobileCommunication.sendStripBrightness(value);}, MobileCommunication.isConnected(), !MobileCommunication.isReadyToSend()),
          speedEffectSlider.getSlider(this, (value) async {await MobileCommunication.sendStripSpeedEffect(value);}, MobileCommunication.isConnected(), !MobileCommunication.isReadyToSend()),
          effectDropdownButton.getDropdownButton(this, (value) async {await MobileCommunication.sendStripEffect(value);}, MobileCommunication.isConnected(), !MobileCommunication.isReadyToSend()),
        ])
      ])
    );
  }
  
  @override
  void onConnectionMobileStatusChanged(bool connection) {
    debugPrint("[LedStripScreenState] mobile connection status changed: $connection");
    StatisticsBar.setMobileConnectionStatus(connection);
    setState(() {});
  }

  @override
  void onStatusMobileDataReceived(StatusMobileData statusData) {
    StatisticsBar.pd = statusData.pd;
    StatisticsBar.synch = statusData.communicationModule;
    setState(() {});
  }
}