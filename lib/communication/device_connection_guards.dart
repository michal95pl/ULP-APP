import 'package:flutter/material.dart';
import 'package:mobile_app/communication/devices_listener.dart';
import 'package:mobile_app/utils/app_routes.dart';

mixin RequiresStageConnection<T extends StatefulWidget> on State<T>, DevicesListener<T> {
  @override
  void onStageConnectionChanged(bool isConnected) {
    super.onStageConnectionChanged(isConnected);
    if (!isConnected && mounted) {
      AppRoutes.navigateTo(context, AppRoutes.settings);
    }
  }
}

mixin RequiresMobileConnection<T extends StatefulWidget> on State<T>, DevicesListener<T> {
  @override
  void onMobileConnectionChanged(bool isConnected) {
    super.onMobileConnectionChanged(isConnected);
    if (!isConnected && mounted) {
      AppRoutes.navigateTo(context, AppRoutes.settings);
    }
  }
}