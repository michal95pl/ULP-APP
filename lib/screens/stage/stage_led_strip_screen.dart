

import 'package:flutter/material.dart';
import 'package:mobile_app/communication/devices_listener.dart';
import 'package:mobile_app/widgets/drawer_nav.dart';
import 'package:mobile_app/model/status_stage_data.dart';
import 'package:mobile_app/widgets/statistics_app_bar.dart';
import 'package:mobile_app/model/status_mobile_data.dart';
import 'package:mobile_app/widgets/text_vertical_slider.dart';

class StageLedStripScreen extends StatefulWidget {
  const StageLedStripScreen({super.key});

  @override
  State<StageLedStripScreen> createState() => StageLedStripScreenState();
}

class StageLedStripScreenState extends State<StageLedStripScreen> 
with DevicesListener {

  static TextVerticalSlider brightnessSlider = TextVerticalSlider("Brightness", 100, const Color.fromARGB(255, 243, 32, 250));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerNav.getDrawerNav(context),
      appBar: StatisticsAppBar(isMobileConnected: false, isStageConnected: false, isSynchEnabled: false),
      backgroundColor: const Color.fromARGB(255, 40, 53, 87),
      body: Column(children: [
        Row(children: [
          brightnessSlider.getSlider(this, (value) async {debugPrint("asd");}, true, false),
        ])
      ])
    );
  }

  @override
  void onMobileConnectionChanged(bool isConnected) {
    debugPrint("[StageLedStripScreenState] mobile connection status changed: $isConnected");
    setState(() {});
  }

  @override
  void onMobileDataReceived(StatusMobileData data) {
    debugPrint("[StageLedStripScreenState] mobile data received: $data");
    setState(() {});
  }

  @override
  void onStageConnectionChanged(bool isConnected) {
    debugPrint("[StageLedStripScreenState] stage connection status changed: $isConnected");
    setState(() {});
  }

  @override
  void onStageDataReceived(StatusStageData data) {
    setState(() {});
  }

}