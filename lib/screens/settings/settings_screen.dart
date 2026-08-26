import 'package:flutter/material.dart';
import 'package:mobile_app/communication/device_manager.dart';
import 'package:mobile_app/communication/devices_listener.dart';
import 'package:mobile_app/widgets/drawer_nav.dart';
import 'package:mobile_app/screens/settings/widgets/connection_panel.dart';
import 'package:mobile_app/widgets/statistics_app_bar.dart';
import 'package:mobile_app/utils/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
  with DevicesListener {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StatisticsAppBar(
        isMobileConnected: DeviceManager.instance.mobile.isConnected(), 
        isStageConnected: DeviceManager.instance.stage.isConnected(), 
        isSynchEnabled: false
      ),
      drawer: DrawerNav.getDrawerNav(context),
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: ConnectionPanel(
                  device: DeviceManager.instance.stage,
                  deviceIndexAddress: 1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onStageConnectionChanged(bool isConnected) {
    debugPrint("[SettingsScreenState] stage connection status changed: $isConnected");
    setState(() {});
  }
  
  @override
  void onMobileConnectionChanged(bool isConnected) {
    debugPrint("[SettingsScreenState] mobile connection status changed: $isConnected");
    setState(() {});
  }

}