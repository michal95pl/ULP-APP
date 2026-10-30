import 'package:mobile_app/communication/devices/mobile_communication.dart';
import 'package:mobile_app/communication/devices/stage_communication.dart';
import 'package:mobile_app/model/stage/status_stage_data.dart';
import 'package:mobile_app/model/mobile/status_mobile_data.dart';

class DeviceManager {
  DeviceManager._internal();
  static final DeviceManager instance = DeviceManager._internal();

  StatusMobileData? lastMobileStatus;
  final MobileCommunication mobile = MobileCommunication();

  StatusStageData? lastStageStatus;
  final StageCommunication stage = StageCommunication();
}