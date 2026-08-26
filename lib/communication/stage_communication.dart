
// This class is responsible for communication with the mobile ULP
import 'package:mobile_app/communication/device_communication.dart';
import 'package:mobile_app/communication/host_type.dart';
import 'package:mobile_app/model/status_stage_data.dart';

class StageCommunication 
extends DeviceCommunication<StatusStageData> {
  @override
   StatusStageData parseData(String rawData) {
    return StatusStageData.getStatusData(rawData);
  }

  @override
  bool isValidHostType(HostType hostType) {
    return hostType.isStage;
  }

}