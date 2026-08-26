import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app/communication/device_communication.dart';
import 'package:mobile_app/communication/device_error.dart';
import 'package:mobile_app/screens/settings/widgets/address_input_field.dart';
import 'package:mobile_app/screens/settings/widgets/connection_button.dart';
import 'package:mobile_app/screens/settings/widgets/device_info_field.dart';
import 'package:mobile_app/utils/app_colors.dart';
import 'package:mobile_app/utils/network_utils.dart';
import 'package:mobile_app/data/settings_file.dart';

class ConnectionPanel extends StatefulWidget {
  final DeviceCommunication device;
  final int deviceIndexAddress;

  const ConnectionPanel({
    super.key,
    required this.device,
    required this.deviceIndexAddress
  });

  @override
  State<ConnectionPanel> createState() => _ConnectionPanelState();
}


class _ConnectionPanelState extends State<ConnectionPanel> {

  final TextEditingController _addressController = TextEditingController();

  StreamSubscription? _deviceStatusSubscription;
  StreamSubscription? _deviceConnectionHostInfoSubscription;
  StreamSubscription? _deviceErrorSubscription;

  ConnectionStatus? _connectionButtonStatus;
  AddressInputError _addressError = AddressInputError.none;

  @override
  void initState() {
    super.initState();

    _deviceStatusSubscription = widget.device.statusStream.listen((status) {
      setState(() {
        _connectionButtonStatus = status ? ConnectionStatus.connected : ConnectionStatus.disconnected;
      });
    });

    _deviceConnectionHostInfoSubscription = widget.device.connectionHostInfoStream.listen((hostInfo) {
      setState(() {});
    });

    _deviceErrorSubscription = widget.device.errorStream.listen((error) {
      if (error.type == DeviceErrorType.invalidHostType) {
        setState(() {
          _addressError = AddressInputError.invalidHostType;
        });
      }
    });

    var address = SettingsFile.readAddress(widget.deviceIndexAddress);
    if (address["ip"] != "" || address["port"] != "") {
      _addressController.text = '${address['ip']}:${address['port']}';
    }

    _connectionButtonStatus = widget.device.isConnected() ? ConnectionStatus.connected : ConnectionStatus.disconnected;
  }

  @override
  void dispose() {
    _deviceStatusSubscription?.cancel();
    _deviceConnectionHostInfoSubscription?.cancel();
    _addressController.dispose();
    _deviceErrorSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 320),
      child: Card(
        color: AppColors.cardBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Stage Device", 
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
              const SizedBox(height: 16),
              if (widget.device.isConnected())
                DeviceInfoField(
                  address: _addressController.text.trim(),
                  hostname: widget.device.getHostName(),
                  deviceName: widget.device.getHostType().name
                )
              else
                AddressInputField(controller: _addressController, error: _addressError),

              const SizedBox(height: 16),
              ConnectionButton(
                status: _connectionButtonStatus ?? ConnectionStatus.disconnected,
                onConnectPressed: _handleConnect,
                onDisconnectPressed: _handleDisconnect
              ),
            ],
          ),
        ),
      )
    );
  }

  Future<void> _handleDisconnect() async {
    await widget.device.disconnect();
    if (!mounted) return;
    setState(() {
      _connectionButtonStatus = ConnectionStatus.disconnected;
    });
  }

  Future<void> _handleConnect() async {
    String addressText = _addressController.text.trim();
    if (!NetworkUtils.checkAddress(addressText)) {
      setState(() {
        _addressError = AddressInputError.invalidFormat;
      });
      return;
    }

    setState(() {
      _connectionButtonStatus = ConnectionStatus.connecting;
      _addressError = AddressInputError.none;
    });

    List<String> parts = addressText.split(":");
    String ip = parts[0];
    String port = parts[1];

    SettingsFile.writeAddress(widget.deviceIndexAddress, ip, port);
      
    try {
      await widget.device.connect(ip, int.parse(port));
      if (!mounted) return;

      if (widget.device.isConnected()) {
        widget.device.sendStatusCommand();
      }
    } catch (e) {
      setState(() {
        _addressError = AddressInputError.invalidAddress;
        _connectionButtonStatus = ConnectionStatus.disconnected;
      });
    }

  }
}