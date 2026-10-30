import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app/communication/model/device_error.dart';
import 'package:mobile_app/communication/device_manager.dart';
import 'package:mobile_app/model/mobile/status_mobile_data.dart';
import 'package:mobile_app/model/stage/status_stage_data.dart';
import 'package:async/async.dart';
import 'package:mobile_app/screens/settings/settings_screen.dart';
import 'package:mobile_app/utils/app_snack_bar.dart';

mixin DevicesListener<T extends StatefulWidget> on State<T> {

  final List<StreamSubscription> _subscriptions = [];
  // Timer? _statusTimer;

  @override
  void initState() {
    super.initState();
    final mobileComm = DeviceManager.instance.mobile;
    final stageComm = DeviceManager.instance.stage;

    _subscriptions.addAll([
      mobileComm.statusStream.listen((connected) => onMobileConnectionChanged(connected)),
      mobileComm.dataStream.listen((data) => onMobileDataReceived(data)),
      mobileComm.errorStream.listen((error) => onMobileErrorReceived(error)),
      
      stageComm.statusStream.listen((connected) => onStageConnectionChanged(connected)),
      stageComm.dataStream.listen((data) => onStageDataReceived(data)),
      stageComm.errorStream.listen((error) => onStageErrorReceived(error)),

      StreamGroup.merge([
        mobileComm.connectionHostInfoStream,
        stageComm.connectionHostInfoStream
      ]).listen((_) => onConnectionsHostInfoChanged())
    ]);

    mobileComm.sendStatusCommand();
    stageComm.sendStatusCommand();

    // _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
    //   mobileComm.sendStatusCommand();
    //   stageComm.sendStatusCommand();
    // });
  }

  @mustCallSuper
  void onMobileConnectionChanged(bool isConnected) {}

  @mustCallSuper
  void onMobileDataReceived(StatusMobileData data) {
    DeviceManager.instance.lastMobileStatus = data;
  }

  @mustCallSuper
  void onMobileErrorReceived(DeviceError error) {
    final isCurrentScreen = ModalRoute.of(context)?.isCurrent ?? false;
    if (isCurrentScreen) {
      if ((error.type != DeviceErrorType.invalidHostType && widget is SettingsScreen) || widget is! SettingsScreen) {
        _showErrorSnackBar("Mobile", error);
      }
    }
  }
  
  @mustCallSuper
  void onStageConnectionChanged(bool isConnected) {}

  @mustCallSuper
  void onStageDataReceived(StatusStageData data) {
    DeviceManager.instance.lastStageStatus = data;
  }

  @mustCallSuper
  void onStageErrorReceived(DeviceError error) {
    final isCurrentScreen = ModalRoute.of(context)?.isCurrent ?? false;
    if (isCurrentScreen) {
      if ((error.type != DeviceErrorType.invalidHostType && widget is SettingsScreen) || widget is! SettingsScreen) {
        _showErrorSnackBar("Stage", error);
      }
    }
  }

  @mustCallSuper
  void onConnectionsHostInfoChanged() {}

  void _showErrorSnackBar(String deviceName, DeviceError error) {
    if (!mounted) return;

    AppSnackBar.showError(context, title: deviceName, message: error.message);
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    // _statusTimer?.cancel();
    super.dispose();
  }
}