
// This class is responsible for communication with the mobile ULP
import 'dart:async';

import 'package:mobile_app/communication/devices/device_communication.dart';
import 'package:mobile_app/communication/devices/synch_controllable_device.dart';
import 'package:mobile_app/communication/model/host_type.dart';
import 'package:mobile_app/communication/model/send_command_type.dart';
import 'package:mobile_app/model/stage/status_stage_data.dart';

class StageCommunication 
  extends DeviceCommunication<StatusStageData> 
  implements SynchControllableDevice {

  StageCommunication(super.connection);

  @override
   StatusStageData parseData(String rawData) {
    return StatusStageData.getStatusData(rawData);
  }

  @override
  bool isValidHostType(HostType hostType) {
    return hostType.isStage;
  }

  @override
  Future<void> sendGuaranteedSynchRequest(bool enable) => connection.sendGuaranteedCommand(SendCommandType.writeSynch.code, [enable? 1 : 0]);
}