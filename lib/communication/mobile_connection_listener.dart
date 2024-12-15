import 'package:mobile_app/status_mobile_data.dart';

abstract class MobileConnectionListener {
  void onConnectionMobileStatusChanged(bool status);
  void onStatusMobileDataReceived(StatusMobileData statusData);
}