import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app/communication/device_manager.dart';
import 'package:mobile_app/communication/devices/device_communication.dart';
import 'package:mobile_app/communication/devices/synch_controllable_device.dart';
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
  StreamSubscription? _deviceSynchSubscription;

  ConnectionStatus? _connectionStatus;
  AddressInputError _addressError = AddressInputError.none;

  bool _isSynchEnabled = false;
  bool _isWaitingForSynch = false;
  Timer? _synchTimeoutTimer;

  @override
  void initState() {
    super.initState();

    _deviceStatusSubscription = widget.device.statusStream.listen((status) {
      if (status) {
        widget.device.sendRequestStatus();
      }
      setState(() {
        _connectionStatus = status ? ConnectionStatus.connected : ConnectionStatus.disconnected;
        if (!status) {
          _synchTimeoutTimer?.cancel();
          _isWaitingForSynch = false;
        }
      });
    });

    if (widget.device is SynchControllableDevice) {
      _isSynchEnabled = DeviceManager.instance.isSynchActive;
      _deviceSynchSubscription = widget.device.receivedSynchStatusStream.listen((state) {
        _synchTimeoutTimer?.cancel();
        setState(() {
          _isSynchEnabled = state;
          _isWaitingForSynch = false;
        });
      });
    }
    
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

    _connectionStatus = widget.device.isConnected ? ConnectionStatus.connected : ConnectionStatus.disconnected;
  }

 @override
  void dispose() {
    _deviceStatusSubscription?.cancel();
    _deviceErrorSubscription?.cancel();
    _deviceSynchSubscription?.cancel();
    _synchTimeoutTimer?.cancel();
    _addressController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ConnectionPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.device is SynchControllableDevice) {
      _isSynchEnabled = DeviceManager.instance.isSynchActive;
    }
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
                  Expanded(
                    child: widget.device is SynchControllableDevice
                    ? Align(
                      alignment: Alignment.centerLeft,
                      child: widget.role != ConnectionPanelRole.tunneled ? 
                      LabeledIconButton(
                        isEnabled: _connectionStatus == ConnectionStatus.connected && !_isWaitingForSynch,
                        color: Colors.white,
                        icon: _isSynchEnabled? Icons.sync_disabled : Icons.sync,
                        label: "Synch",
                        onTap: () {
                          _handleSynch(widget.device as SynchControllableDevice);
                        },
                      ) 
                      : null,
                    )
                    : SizedBox(),
                  ),
                ConnectionButton(
                  status: _connectionStatus ?? ConnectionStatus.disconnected,
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
      _connectionStatus = ConnectionStatus.connecting;
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
        _connectionStatus = ConnectionStatus.disconnected;
      });
      await widget.device.disconnect();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        if (widget.role != ConnectionPanelRole.tunneled) {
          _addressError = AddressInputError.invalidAddress;
        }
        _connectionStatus = ConnectionStatus.disconnected;
      });
    }
  }

  void _handleSynch(SynchControllableDevice synchDevice) {
    if (_isWaitingForSynch) return;

    setState(() {
      _isWaitingForSynch = true;
    });

    synchDevice.sendGuaranteedSynchRequest(!_isSynchEnabled);

    _synchTimeoutTimer?.cancel();
    _synchTimeoutTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() {
        _isWaitingForSynch = false;
      });
    });
  }
}