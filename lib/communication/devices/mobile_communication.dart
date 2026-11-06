
// This class is responsible for communication with the mobile ULP
import 'package:mobile_app/communication/model/receive_command_type.dart';
import 'package:mobile_app/communication/model/send_command_type.dart';
import 'package:mobile_app/communication/devices/device_communication.dart';
import 'package:mobile_app/communication/model/host_type.dart';
import 'package:mobile_app/model/mobile/data/status_mobile_data.dart';

class MobileCommunication 
  extends DeviceCommunication<StatusMobileData> {

  MobileCommunication(super.connection) {
    receivedDataStream.listen((rawData) {
      if (rawData.startsWith(ReceiveCommandType.writeDisplayFrame.code)) {
      //TODO: Handle display frame data
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