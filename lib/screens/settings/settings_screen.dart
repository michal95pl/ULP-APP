import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app/communication/mobile_communication.dart';
import 'package:mobile_app/communication/mobile_connection_listener.dart';
import 'package:mobile_app/drawer_nav.dart';
import 'package:mobile_app/screens/settings/info_board.dart';
import 'package:mobile_app/settings_file.dart';
import 'package:mobile_app/statistics_bar.dart';
import 'package:mobile_app/status_mobile_data.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen>
  implements MobileConnectionListener {

  static bool statusUpdate = false;
  Future<void>? _connectionFuture;

  Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    MobileCommunication.setListener(this);
    MobileCommunication.sendStatusCommand();

    // resend status command every 3 seconds to keep the UI updated
    _statusTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      MobileCommunication.sendStatusCommand();
    });

    _readSetAddress(_textControllers, 0);
  }

  final List<TextEditingController> _textControllers = [TextEditingController()];
  final List<bool> _textFieldErrors = [false];

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
          Row(children: [
            _addressInput(_textControllers, _textFieldErrors, 0),
            _connectionButton(_textControllers, _textFieldErrors, 0),
          ])
        ],
      ),
    );
  }
  
  @override
  void onConnectionMobileStatusChanged(bool connection) {
    debugPrint("[SettingsScreenState] mobile connection status changed: $connection");
    StatisticsBar.setMobileConnectionStatus(connection);
    if (!connection) {
      InfoBoard.hideBoard();
    }
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

  @override
  void dispose() {
    _statusTimer?.cancel();
    // clean up
    for (var controller in _textControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _connectionButton(List<TextEditingController> controllers, List<bool> errors, int index) {
    return FutureBuilder(
      future: _connectionFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          statusUpdate = true;
          return FilledButton(
            onPressed: () {},
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all<Color>(const Color.fromARGB(255, 118, 151, 160)),
            ),
            child: const Text('Connecting...'),
          );
        } else if (MobileCommunication.isConnected()) {
          // send status command after connection
          if (statusUpdate) {
            MobileCommunication.sendStatusCommand();
            statusUpdate = false;
          }

          return const FilledButton(
            onPressed: null,
            child: Text('Connected'),
          );
        } else {
          return FilledButton(
            onPressed: () {
              if (!_checkAddress(controllers[index].text)) {
                errors[index] = true;
              } else{
                errors[index] = false;

                List<String> parts = controllers[index].text.split(":");
                String host = parts[0];
                String port = parts[1];

                SettingsFile.writeAddress(host, port, 0);
                _connectionFuture = MobileCommunication.connect(host, int.parse(port));
              }
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

  Padding _addressInput(List<TextEditingController> controllers, List<bool> errors, int index) {
    return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SizedBox(
              width: 200,
              child: TextField(
                controller: controllers[index],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color.fromARGB(255, 0, 0, 0),
                  hintText: 'Write address',
                  hintStyle: const TextStyle(color: Color.fromARGB(255, 120, 120, 120)),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 0, 0, 0)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                    borderSide: const BorderSide(color: Color.fromARGB(255, 120, 120, 120)),
                  ),
                  errorText: errors[index]? "Invalid address": null,
                ),
                style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
              ),
            ),
          );
  }

  bool _checkAddress(String address) {
    List<String> parts = address.split(":");
    if (parts.length != 2) {
      return false;
    }

    if (parts[0].isEmpty || parts[1].isEmpty) {
      return false;
    }

    if (parts[0].split(".").length != 4) {
      return false;
    }

    if (int.tryParse(parts[1]) == null) {
      return false;
    }

    for (String part in parts[0].split(".")) {
      if (int.tryParse(part) == null || int.parse(part) < 0 || int.parse(part) > 255) {
        return false;
      }
    }

    return true;
  }

  void _readSetAddress(List<TextEditingController> controllers, int index) {
    Map<String, String> address = SettingsFile.readAddress(0);
    if (address["ip"] != "" || address["port"] != "") {
      controllers[index].text = "${address["ip"]}:${address["port"]}";
    }
  }
}