
// This class is responsible for communication with the mobile ULP
import 'package:flutter/material.dart';
import 'package:mobile_app/communication/device_communication.dart';
import 'package:mobile_app/communication/host_type.dart';
import 'package:mobile_app/model/status_mobile_data.dart';

class MobileCommunication 
  extends DeviceCommunication<StatusMobileData> {

  Future<void> sendPrimaryStripColor(Color color) async {
    await sendColor(0, color);
  }

  Future<void> sendSecondaryStripColor(Color color) async {
    await sendColor(1, color);
  }

  Future<void> sendStripEffect(int effect) async {
    await sendEffect(0, effect);
  }

  Future<void> sendStripBrightness(int brightness) async {
    await sendBrightness(0, brightness);
  }

  Future<void> sendStripSpeedEffect(int speed) async {
    await sendSpeedEffect(0, speed);
  }

  @override
  StatusMobileData parseData(String rawData) {
    return StatusMobileData.getStatusData(rawData);
  }

  @override
  bool isValidHostType(HostType hostType) {
    return hostType.isMobile;
  }
}