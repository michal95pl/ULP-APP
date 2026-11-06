import 'package:mobile_app/communication/devices/mobile_communication.dart';
import 'package:mobile_app/communication/devices/stage_communication.dart';
import 'package:mobile_app/communication/transport/socket_connection.dart';
import 'package:mobile_app/communication/transport/tunneled_connection.dart';
import 'package:mobile_app/model/mobile/data/status_mobile_data.dart';
import 'package:mobile_app/model/stage/status_stage_data.dart';

enum ConnectionMode {
  direct, // both devices are connected directly to the app
  tunnelThroughStage, // mobile device is connected to the app through the stage device
  tunnelThroughMobile // stage device is connected to the app through the mobile device
}

class DeviceManager {
  DeviceManager._internal() {
    _mobileSocket = SocketConnection();
    _stageSocket = SocketConnection();

    _tunnelViaStage = TunneledConnection(_stageSocket);
    _tunnelViaMobile = TunneledConnection(_mobileSocket);

    mobile = MobileCommunication(_mobileSocket);
    stage = StageCommunication(_stageSocket);
  }

  static final DeviceManager instance = DeviceManager._internal();

  late final SocketConnection _mobileSocket;
  late final SocketConnection _stageSocket;
  late final TunneledConnection _tunnelViaStage;
  late final TunneledConnection _tunnelViaMobile;

  late final MobileCommunication mobile;
  late final StageCommunication stage;

  StatusMobileData? lastMobileStatus;
  StatusStageData? lastStageStatus;

  ConnectionMode _mode = ConnectionMode.direct;
  ConnectionMode get mode => _mode;

Future<void> setConnectionMode(ConnectionMode newMode) async {
  if (_mode == newMode) return;

  final previousMode = _mode;
  _mode = newMode;

    switch (newMode) {
      case ConnectionMode.direct:
        if (previousMode == ConnectionMode.tunnelThroughStage) {
          await mobile.disconnect();
          mobile.setNewChannel(_mobileSocket);
        } else if (previousMode == ConnectionMode.tunnelThroughMobile) {
          await stage.disconnect();
          stage.setNewChannel(_stageSocket);
        }
        break;

      case ConnectionMode.tunnelThroughStage:
        if (previousMode == ConnectionMode.direct) {
          await mobile.disconnect();
          mobile.setNewChannel(_tunnelViaStage);
        } else if (previousMode == ConnectionMode.tunnelThroughMobile) {
          await stage.disconnect();
          await mobile.disconnect();
          
          stage.setNewChannel(_stageSocket);
          mobile.setNewChannel(_tunnelViaStage);
        }
        break;

      case ConnectionMode.tunnelThroughMobile:
        if (previousMode == ConnectionMode.direct) {
          await stage.disconnect();
          stage.setNewChannel(_tunnelViaMobile);
        } else if (previousMode == ConnectionMode.tunnelThroughStage) {
          await mobile.disconnect();
          await stage.disconnect();
          
          mobile.setNewChannel(_mobileSocket);
          stage.setNewChannel(_tunnelViaMobile);
        }
        break;
    }
  }
}