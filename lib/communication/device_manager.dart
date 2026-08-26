import 'package:mobile_app/communication/mobile_communication.dart';
import 'package:mobile_app/communication/stage_communication.dart';

class DeviceManager {
  DeviceManager._internal();
  static final DeviceManager instance = DeviceManager._internal();

  final MobileCommunication mobile = MobileCommunication();
  final StageCommunication stage = StageCommunication();
}