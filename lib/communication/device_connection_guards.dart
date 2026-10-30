import 'package:flutter/material.dart';
import 'package:mobile_app/communication/devices_listener.dart';
import 'package:mobile_app/utils/app_routes.dart';

/// Requires the Stage device to be connected. If not, it will navigate to the settings screen.
/// Also sets fetchStageStatus flag to true, so the status is fetched when the screen is initialized.
mixin RequiresStageConnection<T extends StatefulWidget> on State<T>, DevicesListener<T> {

  @override
  bool get fetchStageStatus => true;

  @override
  void onStageConnectionChanged(bool isConnected) {
    super.onStageConnectionChanged(isConnected);
    if (!isConnected && mounted) {
      AppRoutes.navigateTo(context, AppRoutes.settings);
    }
  }
}

/// Requires the Mobile device to be connected. If not, it will navigate to the settings screen.
/// Also sets fetchMobileStatus flag to true, so the status is fetched when the screen is initialized.
mixin RequiresMobileConnection<T extends StatefulWidget> on State<T>, DevicesListener<T> {

  @override
  bool get fetchMobileStatus => true;

  @override
  void onMobileConnectionChanged(bool isConnected) {
    super.onMobileConnectionChanged(isConnected);
    if (!isConnected && mounted) {
      AppRoutes.navigateTo(context, AppRoutes.settings);
    }
  }
}