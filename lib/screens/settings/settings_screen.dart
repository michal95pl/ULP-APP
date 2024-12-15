import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app/communication/mobile_communication.dart';
import 'package:mobile_app/communication/mobile_connection_listener.dart';
import 'package:mobile_app/drawer_nav.dart';
import 'package:mobile_app/screens/settings/info_board.dart';
import 'package:mobile_app/statistics_bar.dart';
import 'package:mobile_app/status_mobile_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
  implements MobileConnectionListener {

  Future<void>? _connectionFuture;
  
  Widget _connectionButton(String host, int port, int socketId) {
    return FutureBuilder(
      future: _connectionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return FilledButton(
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 118, 151, 160)),
            ),
            child: const Text('Connecting...'),
          );
        } else if (MobileCommunication.isConnected()) {
          return const FilledButton(
            onPressed: null,
            child: Text('Connected'),
          );
        } else {
          return FilledButton(
            onPressed: () {
              _connectionFuture = MobileCommunication.connect(host, port);
              setState(() {});
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 118, 151, 160)),
            ),
            child: const Text('Connect'),
          );
        }
      }
      
    );
  }

  @override
  void initState() {
    super.initState();
    MobileCommunication.setListener(this);
    MobileCommunication.sendStatusCommand();
  }

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      appBar: StatisticsBar.getAppBar(),
      drawer: DrawerNav.getDrawerNav(context),
      backgroundColor: const Color.fromARGB(255, 40, 53, 87),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          InfoBoard.getBoard(),
          _connectionButton("192.168.2.116", 25567, 0),
        ],
      ),
    );
  }
  
  @override
  void onConnectionMobileStatusChanged(bool connection) {
    debugPrint("[SettingsScreenState] mobile connection status changed: $connection");
    StatisticsBar.setMobileConnectionStatus(connection);
    setState(() {});
  }

  @override
  void onStatusMobileDataReceived(StatusMobileData statusData) {
    StatisticsBar.pd = statusData.pd;
    StatisticsBar.synch = statusData.communicationModule;

    InfoBoard.pcbTemp = statusData.temperaturePCB;
    InfoBoard.espTemperature = statusData.temperatureESP32;
    InfoBoard.stmTemperature = statusData.temperatureSTM32;
    InfoBoard.showBoard();
    setState(() {});
  }
}