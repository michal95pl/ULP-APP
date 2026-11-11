import 'package:flutter/material.dart';
import 'package:mobile_app/communication/device_manager.dart';
import 'package:mobile_app/communication/devices_listener.dart';
import 'package:mobile_app/model/mobile/data/status_mobile_data.dart';
import 'package:mobile_app/model/stage/status_stage_data.dart';
import 'package:mobile_app/utils/app_routes.dart';
import 'package:mobile_app/widgets/bottom_nav.dart';
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

  // gets status from both devices, mainly for synch status, Maybe it's not neccessery
  @override
  bool get fetchStageStatus => true;
  
  @override
  bool get fetchMobileStatus => true;

  ConnectionPanelRole _getRoleForMobileDevice() {
    final mode = DeviceManager.instance.mode;
    
    if (mode == ConnectionMode.tunnelThroughMobile) return ConnectionPanelRole.tunnelHost;
    if (mode == ConnectionMode.tunnelThroughStage) return ConnectionPanelRole.tunneled;
    return ConnectionPanelRole.direct;
  }

  ConnectionPanelRole _getRoleForStageDevice() {
    final mode = DeviceManager.instance.mode;
    
    if (mode == ConnectionMode.tunnelThroughStage) return ConnectionPanelRole.tunnelHost;
    if (mode == ConnectionMode.tunnelThroughMobile) return ConnectionPanelRole.tunneled;
    return ConnectionPanelRole.direct;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: StatisticsAppBar(
        isMobileConnected: DeviceManager.instance.mobile.isConnected, 
        isStageConnected: DeviceManager.instance.stage.isConnected, 
        isSynchEnabled: DeviceManager.instance.isSynchActive
      ),
      bottomNavigationBar: BottomNav(currentRoute: AppRoutes.settings, isMobileConnected: DeviceManager.instance.mobile.isConnected, isStageConnected: DeviceManager.instance.stage.isConnected),
      backgroundColor: AppColors.backgroundColor,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 280,
                child: ConnectionPanel(
                  name: "Stage Device",
                  device: DeviceManager.instance.stage,
                  fileIndexAddress: 1,
                  role: _getRoleForStageDevice(),
                  onTunnelToggled: () async {
                    final newMode = DeviceManager.instance.mode == ConnectionMode.tunnelThroughStage 
                        ? ConnectionMode.direct 
                        : ConnectionMode.tunnelThroughStage;
                        
                    await DeviceManager.instance.setConnectionMode(newMode);
                    setState(() {});
                  }
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: 280,
                child: ConnectionPanel(
                  name: "Mobile Device",
                  device: DeviceManager.instance.mobile,
                  fileIndexAddress: 0,
                  role: _getRoleForMobileDevice(),
                  onTunnelToggled: () async {
                   final newMode = DeviceManager.instance.mode == ConnectionMode.tunnelThroughMobile 
                        ? ConnectionMode.direct 
                        : ConnectionMode.tunnelThroughMobile;
                        
                    await DeviceManager.instance.setConnectionMode(newMode);
                    setState(() {});
                  }
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
    super.onStageConnectionChanged(isConnected);
    debugPrint("[SettingsScreenState] stage connection status changed: $isConnected");
    setState(() {});
  }
  
  @override
  void onStageSynchStateChanged(bool state) {
    super.onStageSynchStateChanged(state);
    debugPrint("[SettingsScreenState] stage synch state changed: $state");
  }

  @override
  void onMobileConnectionChanged(bool isConnected) {
    super.onMobileConnectionChanged(isConnected);
    debugPrint("[SettingsScreenState] mobile connection status changed: $isConnected");
    setState(() {});
  }

  @override
  void onMobileSynchStateChanged(bool state) {
    super.onMobileSynchStateChanged(state);
    debugPrint("[SettingsScreenState] mobile synch state changed: $state");
  }

  @override
  void onMobileDataReceived(StatusMobileData data) {
    super.onMobileDataReceived(data);
    debugPrint("[SettingsScreenState] mobile data received: $data");
    setState(() {});
  }

  @override
  void onStageDataReceived(StatusStageData data) {
    super.onStageDataReceived(data);
    debugPrint("[SettingsScreenState] stage data received: $data");
    setState(() {});
  }

}