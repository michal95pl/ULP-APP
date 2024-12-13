import 'package:flutter/material.dart';
import 'package:mobile_app/drawer_nav.dart';
import 'package:mobile_app/screens/settings/info_board.dart';
import 'package:mobile_app/statistics_bar.dart';
import 'package:mobile_app/communication.dart';
import 'package:mobile_app/status_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
implements CommunicationListener {

  static FilledButton _connectionButton(String host, int port, int socketId) {
    return FilledButton(
      onPressed: Communication.getConnectionsStatus()[socketId]? null : () =>  {Communication.createConnection(host, port, socketId)}, 
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 118, 151, 160)),
      ),
      child: Text('Connect $socketId'),
    );
  }

  @override
  void initState() {
    super.initState();
    Communication.setListener(this);
    Communication.sendStatusCommand(0);
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
          _connectionButton("192.168.2.123", 25567, 0),
        ],
      ),
    );
  }
  
  @override
  void onConnectionStatusChanged(List<bool> connections) {
    debugPrint("[SettingsScreenState] connection status changed: $connections");
    StatisticsBar.connections = Communication.getConnectionsStatus();
    setState(() {});
  }

  @override
  void onStatusDataReceived(StatusData statusData) {
    StatisticsBar.pd = statusData.pd;
    StatisticsBar.synch = statusData.communicationModule;

    InfoBoard.pcbTemp = statusData.temperaturePCB;
    InfoBoard.espTemperature = statusData.temperatureESP32;
    InfoBoard.stmTemperature = statusData.temperatureSTM32;
    InfoBoard.showBoard();
    setState(() {});
  }
}