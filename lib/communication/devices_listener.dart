import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app/communication/device_error.dart';
import 'package:mobile_app/communication/device_manager.dart';
import 'package:mobile_app/model/status_mobile_data.dart';
import 'package:mobile_app/model/status_stage_data.dart';
import 'package:async/async.dart';
import 'package:mobile_app/screens/settings/settings_screen.dart';
import 'package:mobile_app/utils/app_colors.dart';

mixin DevicesListener<T extends StatefulWidget> on State<T> {

  final List<StreamSubscription> _subscriptions = [];
  Timer? _statusTimer;

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

    _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      mobileComm.sendStatusCommand();
      stageComm.sendStatusCommand();
    });
  }

  void onMobileConnectionChanged(bool isConnected) {}
  void onMobileDataReceived(StatusMobileData data) {}

  @mustCallSuper
  void onMobileErrorReceived(DeviceError error) {
    if (error.type != DeviceErrorType.invalidHostType && widget is SettingsScreen) {
      _showErrorSnackBar("Mobile", error);
    }
  }
  
  void onStageConnectionChanged(bool isConnected) {}
  void onStageDataReceived(StatusStageData data) {}

  @mustCallSuper
  void onStageErrorReceived(DeviceError error) {
    if (error.type != DeviceErrorType.invalidHostType && widget is SettingsScreen) {
      _showErrorSnackBar("Stage", error);
    }
  }

  void onConnectionsHostInfoChanged() {}

  void _showErrorSnackBar(String deviceName, DeviceError error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        backgroundColor: AppColors.snackbarBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: AppColors.redSnackbarColor, width: 1),
        ),
        content: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.redSnackbarColor, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    deviceName,
                    style: const TextStyle(
                      color: Colors.white, 
                      fontSize: 14, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    error.message,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _statusTimer?.cancel();
    super.dispose();
  }
}