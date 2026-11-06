import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app/communication/devices/device_communication.dart';
import 'package:mobile_app/communication/model/connection_error.dart';
import 'package:mobile_app/screens/settings/widgets/address_input_field.dart';
import 'package:mobile_app/screens/settings/widgets/connection_button.dart';
import 'package:mobile_app/screens/settings/widgets/device_info_field.dart';
import 'package:mobile_app/utils/app_colors.dart';
import 'package:mobile_app/utils/network_utils.dart';
import 'package:mobile_app/data/settings_file.dart';
import 'package:mobile_app/widgets/labeled_icon_button.dart';

enum ConnectionPanelRole {
  direct,
  tunneled, // the device that is connected through a tunnel
  tunnelHost // the device that creates the tunnel
}

class ConnectionPanel extends StatefulWidget {
  final DeviceCommunication device;
  final int fileIndexAddress;
  final String name;

  final ConnectionPanelRole role;
  final VoidCallback onTunnelToggled;

  const ConnectionPanel({
    super.key,
    required this.name,
    required this.device,
    required this.fileIndexAddress,
    required this.role,
    required this.onTunnelToggled,
  });

  @override
  State<ConnectionPanel> createState() => _ConnectionPanelState();
}


class _ConnectionPanelState extends State<ConnectionPanel> {

  final TextEditingController _addressController = TextEditingController();

  StreamSubscription? _deviceStatusSubscription;
  StreamSubscription? _deviceErrorSubscription;

  ConnectionStatus? _connectionButtonStatus;
  AddressInputError _addressError = AddressInputError.none;

  @override
  void initState() {
    super.initState();

    _deviceStatusSubscription = widget.device.statusStream.listen((status) {
      if (status) {
        widget.device.sendRequestStatus();
      }
      setState(() {
        _connectionButtonStatus = status ? ConnectionStatus.connected : ConnectionStatus.disconnected;
      });
    });

    _deviceErrorSubscription = widget.device.errorStream.listen((error) {
      if (error.type == ConnectionErrorType.invalidHostType) {
        setState(() {
          _addressError = AddressInputError.invalidHostType;
        });
      }
    });

    var address = SettingsFile.readAddress(widget.fileIndexAddress);
    if (address["ip"] != "" || address["port"] != "") {
      _addressController.text = '${address['ip']}:${address['port']}';
    }

    _connectionButtonStatus = widget.device.isConnected ? ConnectionStatus.connected : ConnectionStatus.disconnected;
  }

  @override
  void dispose() {
    _deviceStatusSubscription?.cancel();
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
              Text(
                widget.name,
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)
              ),
              if (widget.role == ConnectionPanelRole.tunneled)
                Text(
                  "(Tunneled)",
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold)
                ),
              const SizedBox(height: 16),
              if (widget.device.isConnected)
                DeviceInfoField(
                  address: widget.role == ConnectionPanelRole.tunneled ? null : _addressController.text.trim(),
                  hostname: widget.device.hostName!,
                  deviceName: widget.device.hostType.name
                )
              else if (widget.role != ConnectionPanelRole.tunneled)
                AddressInputField(controller: _addressController, error: _addressError),

              const SizedBox(height: 16),
              Row(children: [
                const Expanded(child: SizedBox()),
                ConnectionButton(
                  status: _connectionButtonStatus ?? ConnectionStatus.disconnected,
                  onConnectPressed: _handleConnect,
                  onDisconnectPressed: () async {await widget.device.disconnect();}
                ),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: widget.role != ConnectionPanelRole.tunneled ? 
                    LabeledIconButton(
                      color: Colors.white,
                      icon: widget.role == ConnectionPanelRole.tunnelHost ? Icons.link_off : Icons.link,
                      label: "Tunnel",
                      onTap: widget.onTunnelToggled
                    ) 
                    : null,
                  ),
                ),
              ])
            ],
          ),
        ),
      )
    );
  }

Future<void> _handleConnect() async {
    String? ip;
    int? port;

    if (widget.role != ConnectionPanelRole.tunneled) {
      String addressText = _addressController.text.trim();
      if (!NetworkUtils.checkAddress(addressText)) {
        setState(() {
          _addressError = AddressInputError.invalidFormat;
        });
        return;
      }
      List<String> parts = addressText.split(":");
      ip = parts[0];
      port = int.parse(parts[1]);
      
      SettingsFile.writeAddress(widget.fileIndexAddress, ip, port.toString());
    }

    setState(() {
      _connectionButtonStatus = ConnectionStatus.connecting;
      _addressError = AddressInputError.none;
    });

    try {
      if (widget.role == ConnectionPanelRole.tunneled) {
        await widget.device.connect(); 
      } else {
        await widget.device.connect(ip, port);
      }

      if (!widget.device.isConnected) {
        await widget.device.statusStream
            .firstWhere((status) => status == true)
            .timeout(const Duration(seconds: 3));
      }
      
    } on TimeoutException {
      if (!mounted) return;
      setState(() {
        if (widget.role != ConnectionPanelRole.tunneled) {
          _addressError = AddressInputError.invalidAddress;
        }
        _connectionButtonStatus = ConnectionStatus.disconnected;
      });
      await widget.device.disconnect();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (widget.role != ConnectionPanelRole.tunneled) {
          _addressError = AddressInputError.invalidAddress;
        }
        _connectionButtonStatus = ConnectionStatus.disconnected;
      });
    }
  }
}