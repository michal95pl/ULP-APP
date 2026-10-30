
// This class is responsible for communication with the mobile ULP
import 'package:mobile_app/communication/model/device_command.dart';
import 'package:mobile_app/communication/devices/device_communication.dart';
import 'package:mobile_app/communication/model/host_type.dart';
import 'package:mobile_app/model/mobile/status_mobile_data.dart';

class MobileCommunication 
  extends DeviceCommunication<StatusMobileData> {

  @override
  StatusMobileData parseData(String rawData) {
    return StatusMobileData.getStatusData(rawData);
  }

  @override
  bool isValidHostType(HostType hostType) {
    return hostType.isMobile;
  }

  /// Send display text to the server.
  Future<void> sendGuaranteedDisplayText(int displayId, String text) async {
    await connection.sendGuaranteedCommand(DeviceCommand.writeDisplayText.code, <int>[displayId, ...text.codeUnits]);
  }

  Future<void> sendGuaranteedAllDisplayFrame(int displayId, List<int> frameData) async {
    await connection.sendGuaranteedCommand(DeviceCommand.writeDisplayFrame.code, <int>[displayId, ...frameData]);
  }
}