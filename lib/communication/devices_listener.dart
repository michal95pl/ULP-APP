import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mobile_app/communication/model/connection_error.dart';
import 'package:mobile_app/communication/device_manager.dart';
import 'package:mobile_app/model/mobile/data/status_mobile_data.dart';
import 'package:mobile_app/model/stage/status_stage_data.dart';
import 'package:mobile_app/screens/settings/settings_screen.dart';
import 'package:mobile_app/screens/wearable/widgets/led_matrix/led_matrix_manager.dart';
import 'package:mobile_app/utils/app_snack_bar.dart';

/// Implements basic functionality to handle device connection changes, data received and errors received.
mixin DevicesListener<T extends StatefulWidget> on State<T> {

  final List<StreamSubscription> _subscriptions = [];
  // Timer? _statusTimer;

  bool get fetchMobileStatus => false;
  bool get fetchStageStatus => false;

  @override
  void initState() {
    super.initState();
    final mobileComm = DeviceManager.instance.mobile;
    final stageComm = DeviceManager.instance.stage;

    _subscriptions.addAll([
      mobileComm.statusStream.listen((connected) => onMobileConnectionChanged(connected)),
      mobileComm.statusDataStream.listen((data) => onMobileDataReceived(data)),
      mobileComm.errorStream.listen((error) => onMobileErrorReceived(error)),
      mobileComm.receivedSynchStatusStream.listen((state) => onMobileSynchStateChanged(state)),
      mobileComm.receivedBackDisplayDataStream.listen((frame) => onMobileDisplayDataReceived(frame)),
      
      stageComm.statusStream.listen((connected) => onStageConnectionChanged(connected)),
      stageComm.statusDataStream.listen((data) => onStageDataReceived(data)),
      stageComm.errorStream.listen((error) => onStageErrorReceived(error)),
      stageComm.receivedSynchStatusStream.listen((state) => onStageSynchStateChanged(state)),
    ]);

    // gets the latest status from devices depending on the screen is being shown.
    if (fetchMobileStatus) {
      mobileComm.sendRequestStatus();
    }
    
    if (fetchStageStatus) {
      stageComm.sendRequestStatus();
    }

    // _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
    //   mobileComm.sendStatusCommand();
    //   stageComm.sendStatusCommand();
    // });
  }

  @mustCallSuper
  void onMobileDisplayDataReceived(Uint8List frame) {
    LedMatrixManager.instance.backController.setAllFramesFromBytes(frame);
  }

  @mustCallSuper
  void onMobileConnectionChanged(bool isConnected) {}

  @mustCallSuper
  void onMobileDataReceived(StatusMobileData data) {
    DeviceManager.instance.lastMobileStatus = data;
  }

  @mustCallSuper
  void onMobileErrorReceived(ConnectionError error) {
    final isCurrentScreen = ModalRoute.of(context)?.isCurrent ?? false;
    if (isCurrentScreen) {
      if (widget is! SettingsScreen || error.type != ConnectionErrorType.invalidHostType) {
        _showErrorSnackBar("Mobile", error);
      }
    }
  }
  
  @mustCallSuper
  void onMobileSynchStateChanged(bool state) {
    if (DeviceManager.instance.lastMobileStatus != null) {
      DeviceManager.instance.lastMobileStatus!.synchEnabled = state;
    }
  }


  @mustCallSuper
  void onStageConnectionChanged(bool isConnected) {}

  @mustCallSuper
  void onStageDataReceived(StatusStageData data) {
    DeviceManager.instance.lastStageStatus = data;
  }

  @mustCallSuper
  void onStageErrorReceived(ConnectionError error) {
    final isCurrentScreen = ModalRoute.of(context)?.isCurrent ?? false;
    if (isCurrentScreen) {
      if (widget is! SettingsScreen || error.type != ConnectionErrorType.invalidHostType) {
        _showErrorSnackBar("Stage", error);
      }
    }
  }

  @mustCallSuper
  void onStageSynchStateChanged(bool state) {
    if (DeviceManager.instance.lastStageStatus != null) {
      DeviceManager.instance.lastStageStatus!.synchEnabled = state;
    }
  }

  void _showErrorSnackBar(String deviceName, ConnectionError error) {
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