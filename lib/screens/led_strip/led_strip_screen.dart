import 'package:flutter/material.dart';
import 'package:mobile_app/drawer_nav.dart';
import 'package:mobile_app/screens/led_strip/effect_dropdown_button.dart';
import 'package:mobile_app/screens/led_strip/strip_color_picker.dart';
import 'package:mobile_app/statistics_bar.dart';
import 'package:mobile_app/communication.dart';
import 'package:mobile_app/status_data.dart';
import 'package:mobile_app/text_vertical_slider.dart';

class LedStripScreen extends StatefulWidget {
  const LedStripScreen({super.key});

  @override
  State<LedStripScreen> createState() => LedStripScreenState();
}

class LedStripScreenState extends State<LedStripScreen> 
implements CommunicationListener {

  static TextVerticalSlider brightnessSlider = TextVerticalSlider("Brightness", 100, const Color.fromARGB(255, 243, 32, 250));
  static TextVerticalSlider speedEffectSlider = TextVerticalSlider("Speed", 100, const Color.fromARGB(255, 20, 242, 224));
  static EffectDropdownButton effectDropdownButton = EffectDropdownButton();
  static StripColorPicker stripColorPicker = StripColorPicker();

  @override
  void initState() {
    super.initState();
    Communication.setListener(this);
    Communication.sendStatusCommand(0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerNav.getDrawerNav(context),
      appBar: StatisticsBar.getAppBar(),
      backgroundColor: const Color.fromARGB(255, 40, 53, 87),
      body: Column(children: [
        stripColorPicker.getColorPicker(this, false, (value) {Communication.sendPrimaryStripColor(0, value);}, (value) {Communication.sendSecondaryStripColor(0, value);}), 
        Row(children: [
          brightnessSlider.getSlider(this, (value) {Communication.sendStripBrightness(0, value);}, Communication.getConnectionsStatus()[0]),
          speedEffectSlider.getSlider(this, (value) {Communication.sendStripSpeedEffect(0, value);}, Communication.getConnectionsStatus()[0]),
          effectDropdownButton.getDropdownButton(this, (value) {Communication.sendStripEffect(0, value);}, Communication.getConnectionsStatus()[0]),
        ])
      ])
    );
  }
  
  @override
  void onConnectionStatusChanged(List<bool> connections) {
    debugPrint("[LedStripScreenState] connection status changed: $connections");
    StatisticsBar.connections = Communication.getConnectionsStatus();
    setState(() {});
  }

  @override
  void onStatusDataReceived(StatusData statusData) {
    StatisticsBar.pd = statusData.pd;
    StatisticsBar.synch = statusData.communicationModule;
    setState(() {});
  }
}