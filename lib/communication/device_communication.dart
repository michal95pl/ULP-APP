
// This class is responsible for communication with the mobile ULP
import 'package:flutter/material.dart';
import 'package:mobile_app/communication/device_error.dart';
import 'package:mobile_app/communication/host_type.dart';
import 'package:mobile_app/communication/socket_connection.dart';
import 'package:mobile_app/utils/color_extensions.dart';

abstract class DeviceCommunication<T> {

  final SocketConnection _connection = SocketConnection();

  DeviceCommunication() {
    _connection.connectionHostInfoStream.listen((_) {
      _verifyHostType();
    });
  }

  Future<void> connect(String host, int port) async {
    await _connection.connect(host, port);
  }

  bool isConnected() {
    return _connection.isConnected();
  }

  bool isReadyToSend() {
    return !_connection.isWaitingForAck();
  }

  String getHostName() {
    return _connection.hostName ?? "";
  }

  HostType getHostType() {
    return _connection.hostType;
  }

  Future<void> disconnect() async {
    await _connection.closeConnection();
  }

  bool isValidHostType(HostType hostType);

  Future<void> _verifyHostType() async {
    if (!isValidHostType(_connection.hostType)) {
      debugPrint("[DeviceCommunication] Invalid host type: ${_connection.hostType.rawValue}");
      _connection.emitError(DeviceError(DeviceErrorType.invalidHostType, "Invalid host type: ${_connection.hostType.rawValue}"));
      await _connection.closeConnection();
    }
  }

  Stream<bool> get statusStream => _connection.statusStream;
  Stream<T> get dataStream => _connection.rawDataStream.map((String rawData) => parseData(rawData));
  Stream<void> get connectionHostInfoStream => _connection.connectionHostInfoStream;
  Stream<DeviceError> get errorStream => _connection.errorStream;

  T parseData(String rawData);

  /*
   * Commands:
   * W - write / R - read
   * 2 characters - type of command
   * data
   * k - end of command
   */
  // todo: change K to 253 (0xFD) - end of command

  /// Send status command. Server will respond with status data.
  Future<void> sendStatusCommand() async {
    await _connection.sendCommand("RST");
  }

  /// Send brightness to the server.
  /// 
  /// param brightness - brightness value (0-100)
  Future<void> sendBrightness(int index, int brightness) async {
    await _connection.sendCommand("WSB", <int>[index, brightness]);
  }

  /// Send speed effect to the server.
  /// 
  /// param speed - speed value (0-100)
  Future<void> sendSpeedEffect(int index, int speed) async {
    await _connection.sendCommand("WSS", <int>[index, speed]);
  }

  /// Send color to the server.
  /// 
  /// @param color - color value
  Future<void> sendColor(int index, Color color) async {
    // SCW {index} {red} {green} {blue} k
    await _connection.sendCommand("WSC", <int>[index, color.redInt, color.greenInt, color.blueInt]);
  }

  /// Send effect to the server.
  /// 
  /// @param effect - effect index
  Future<void> sendEffect(int index, int effect) async {
    await _connection.sendCommand("WSE", <int>[index, effect]);
  }
}