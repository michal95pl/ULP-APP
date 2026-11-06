import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mobile_app/communication/model/receive_command_type.dart';
import 'package:mobile_app/communication/model/send_command_type.dart';
import 'package:mobile_app/communication/model/connection_error.dart';
import 'package:mobile_app/communication/model/host_type.dart';
import 'package:mobile_app/communication/transport/socket_channel.dart';
import 'package:mobile_app/utils/color_extensions.dart';

abstract class DeviceCommunication<T> {

  String? hostName;
  HostType hostType = HostType.unknown;
  bool isConnected = false; // means the socket is connected and the host type is valid

  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  final StreamController<T> _statusDataController = StreamController<T>.broadcast();
  final StreamController<ConnectionError> _errorController = StreamController<ConnectionError>.broadcast();
  final StreamController<String> _receivedDataController = StreamController<String>.broadcast();

  Stream<bool> get statusStream => _connectionStatusController.stream;
  Stream<T> get statusDataStream => _statusDataController.stream;
  Stream<ConnectionError> get errorStream => _errorController.stream;
  // Stream of specific data received from the device to be handled by the specific communication class (e.g., MobileCommunication, StageCommunication)
  Stream<String> get receivedDataStream => _receivedDataController.stream;

  @protected
  late SocketChannel connection;

  // Subscriptions to socket channel streams, to be able to cancel them when changing the channel
  StreamSubscription? _dataSub;
  StreamSubscription? _statusSub;
  StreamSubscription? _errorSub;

  DeviceCommunication(this.connection) {
    _bindStreams();
  }

  void setNewChannel(SocketChannel newChannel) {
    if (isConnected) {
      isConnected = false;
      _connectionStatusController.add(false);
    }
    connection = newChannel;
    _dataSub?.cancel();
    _statusSub?.cancel();
    _errorSub?.cancel();
    _bindStreams();
  }

  void _bindStreams() {
    _dataSub = connection.receivedDataStream.listen((rawData) => _onRawDataReceived(rawData));
    _statusSub = connection.statusStream.listen((status) {
      if (!status) {
        isConnected = false;
        _connectionStatusController.add(isConnected);
      }
    });
    _errorSub = connection.errorStream.listen((error) => _errorController.add(error));
  }

  Future<void> _onRawDataReceived(String rawData) async {
    if (rawData.isEmpty) return;
    try {
      if (rawData.startsWith(ReceiveCommandType.writeStatus.code)) {
        var jsonData = rawData.substring(3).trim();
        _statusDataController.add(parseData(jsonData));
        debugPrint("[SocketConnection] Received status data: $jsonData");

      } else if (rawData.startsWith(ReceiveCommandType.writeHostInfo.code)) {
        var jsonData = rawData.substring(3).trim();
        final Map<String, dynamic> data = jsonDecode(jsonData) as Map<String, dynamic>;
        hostName = data['hostName'] as String? ?? 'Unknown Host';
        hostType = HostType.fromString(data['hostType'] as String?);

        if (isValidHostType(hostType)) {
          isConnected = true;
          _connectionStatusController.add(isConnected);
        }
        else {
          isConnected = false;
          _connectionStatusController.add(isConnected);
          _errorController.add(ConnectionError(ConnectionErrorType.invalidHostType, "Invalid host type: ${hostType.rawValue}"));
          await connection.closeConnection();
        }
        debugPrint("[SocketConnection] Received WHO command: $data");
        // We do not need to handle in the upper layer tunneled commands
      } else if (rawData[0] != 'T' && rawData[0] != 'F') {
        _receivedDataController.add(rawData);
      }
    } catch (e) {
      debugPrint("[DeviceCommunication] Error parsing data: $e");
      _errorController.add(ConnectionError(ConnectionErrorType.parsingError, "Error parsing data: $e"));
    }
  }

  Future<void> connect([String? host, int? port]) =>
    connection.connect(host, port);

  Future<void> disconnect() =>
    connection.closeConnection();

  /// Check if the host type is valid for this communication class.
  bool isValidHostType(HostType hostType);

  T parseData(String rawData);

  /// Send status command. Server will respond with status data.
  Future<void> sendRequestStatus() =>
    connection.sendGuaranteedCommand(SendCommandType.readStatus.code);

  /// Send brightness to the server.
  ///
  /// param brightness - brightness value (0-100)
  Future<void> sendBrightness(int index, int brightness) =>
    connection.sendCommand(SendCommandType.writeBrightness.code, <int>[index, brightness]);

  Future<void> sendGuaranteedBrightness(int index, int brightness) =>
    connection.sendGuaranteedCommand(SendCommandType.writeBrightness.code, <int>[index, brightness]);

  /// Send speed effect to the server.
  ///
  /// param speed - speed value (0-100)
  Future<void> sendSpeedEffect(int index, int speed) =>
    connection.sendCommand(SendCommandType.writeSpeedEffect.code, <int>[index, speed]);

  /// Send color to the server.
  ///
  /// @param color - color value
  Future<void> sendColor(int index, Color color) =>
    connection.sendCommand(SendCommandType.writeColor.code, <int>[index, color.redInt, color.greenInt, color.blueInt]);


  Future<void> sendGuaranteedColor(int index, Color color) =>
    connection.sendGuaranteedCommand(SendCommandType.writeColor.code, <int>[index, color.redInt, color.greenInt, color.blueInt]);

  /// Send effect to the server.
  ///
  /// @param effect - effect index
  Future<void> sendGuaranteedEffect(int index, int effect) =>
    connection.sendGuaranteedCommand(SendCommandType.writeEffect.code, <int>[index, effect]);
}