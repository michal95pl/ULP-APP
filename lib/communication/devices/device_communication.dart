
// This class is responsible for communication with the mobile ULP
import 'package:flutter/material.dart';
import 'package:mobile_app/communication/model/device_command.dart';
import 'package:mobile_app/communication/model/device_error.dart';
import 'package:mobile_app/communication/model/host_type.dart';
import 'package:mobile_app/communication/socket_connection.dart';
import 'package:mobile_app/utils/color_extensions.dart';

///TODO: There is an issue where a state-change command is sent to all devices, regardless of which screen is currently open.
///TODO: Whe shoud first check device type and then send all commands. If we connect to wrong device tpe, there is exception thrown during receiving wrong data type.
abstract class DeviceCommunication<T> {

  @protected
  final SocketConnection connection = SocketConnection();

  DeviceCommunication() {
    connection.connectionHostInfoStream.listen((_) {
      _verifyHostType();
    });
  }

  Future<void> connect(String host, int port) async {
    await connection.connect(host, port);
  }

  bool isConnected() {
    return connection.isConnected();
  }

  bool isReadyToSend() {
    return !connection.isWaitingForAck();
  }

  String getHostName() {
    return connection.hostName ?? "";
  }

  HostType getHostType() {
    return connection.hostType;
  }

  Future<void> disconnect() async {
    await connection.closeConnection();
  }

  /// Check if the host type is valid for this communication class.
  bool isValidHostType(HostType hostType);

  Future<void> _verifyHostType() async {
    if (!isValidHostType(connection.hostType)) {
      debugPrint("[DeviceCommunication] Invalid host type: ${connection.hostType.rawValue}");
      connection.emitError(DeviceError(DeviceErrorType.invalidHostType, "Invalid host type: ${connection.hostType.rawValue}"));
      await connection.closeConnection();
    }
  }

  Stream<bool> get statusStream => connection.statusStream;
  Stream<T> get dataStream => connection.rawDataStream.map((String rawData) => parseData(rawData));
  Stream<void> get connectionHostInfoStream => connection.connectionHostInfoStream;
  Stream<DeviceError> get errorStream => connection.errorStream;

  T parseData(String rawData);

  /*
   * Commands:
   * W - write / R - read
   * 2 characters - type of command
   * data
   */

  /// Send status command. Server will respond with status data.
  Future<void> sendStatusCommand() async {
    await connection.sendGuaranteedCommand(DeviceCommand.readStatus.code);
  }

  /// Send brightness to the server.
  /// 
  /// param brightness - brightness value (0-100)
  Future<void> sendBrightness(int index, int brightness) async {
    await connection.sendCommand(DeviceCommand.writeBrightness.code, <int>[index, brightness]);
  }

  Future<void> sendGuaranteedBrightness(int index, int brightness) async {
    await connection.sendGuaranteedCommand(DeviceCommand.writeBrightness.code, <int>[index, brightness]);
  }

  /// Send speed effect to the server.
  /// 
  /// param speed - speed value (0-100)
  Future<void> sendSpeedEffect(int index, int speed) async {
    await connection.sendCommand(DeviceCommand.writeSpeedEffect.code, <int>[index, speed]);
  }

  /// Send color to the server.
  /// 
  /// @param color - color value
  Future<void> sendColor(int index, Color color) async {
    // SCW {index} {red} {green} {blue} k
    await connection.sendCommand(DeviceCommand.writeColor.code, <int>[index, color.redInt, color.greenInt, color.blueInt]);
  }

  Future<void> sendGuaranteedColor(int index, Color color) async {
    await connection.sendGuaranteedCommand(DeviceCommand.writeColor.code, <int>[index, color.redInt, color.greenInt, color.blueInt]);
  }

  /// Send effect to the server.
  /// 
  /// @param effect - effect index
  Future<void> sendGuaranteedEffect(int index, int effect) async {
    await connection.sendGuaranteedCommand(DeviceCommand.writeEffect.code, <int>[index, effect]);
  }
}