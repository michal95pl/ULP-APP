
// This class is responsible for communication with the mobile ULP
import 'dart:async';
import 'dart:typed_data';

import 'package:mobile_app/communication/model/receive_command_type.dart';
import 'package:mobile_app/communication/model/send_command_type.dart';
import 'package:mobile_app/communication/devices/device_communication.dart';
import 'package:mobile_app/communication/model/host_type.dart';
import 'package:mobile_app/model/mobile/data/status_mobile_data.dart';

class MobileCommunication 
  extends DeviceCommunication<StatusMobileData> {

  final StreamController<Uint8List> _receivedBackDisplayDataController = StreamController<Uint8List>.broadcast();

  Stream<Uint8List> get receivedBackDisplayDataStream => _receivedBackDisplayDataController.stream;

  MobileCommunication(super.connection) {
    receivedDataStream.listen((packet) {
      if (packet.commandType.startsWith(ReceiveCommandType.writeDisplayFrame.code)) {
        Uint8List payload = packet.payload;
        // check displayID
        if (payload[0] == 1) {
          final Uint8List frameData = Uint8List.view(
            payload.buffer,
            payload.offsetInBytes + 1,
            payload.lengthInBytes - 1,
          );
          _receivedBackDisplayDataController.add(frameData);
        }
      }
    });
  }

  @override
  StatusMobileData parseData(String rawData) {
    return StatusMobileData.getStatusData(rawData);
  }

  @override
  bool isValidHostType(HostType hostType) {
    return hostType.isMobile;
  }

  /// Send display text to the server.
  Future<void> sendGuaranteedDisplayText(int displayId, String text) =>
    connection.sendGuaranteedCommand(SendCommandType.writeDisplayText.code, <int>[displayId, ...text.codeUnits]);

  Future<void> sendGuaranteedAllDisplayFrame(int displayId, List<int> frameData) =>
    connection.sendGuaranteedCommand(SendCommandType.writeDisplayFrame.code, <int>[displayId, ...frameData]);

  Future<void> sendRequestDisplayFrame(int displayId) =>
    connection.sendCommand(SendCommandType.readDisplayFrame.code, <int>[displayId]);
}