import 'dart:async';

import 'package:mobile_app/communication/model/connection_error.dart';
import 'package:mobile_app/communication/model/receive_command_type.dart';
import 'package:mobile_app/communication/model/received_packet.dart';
import 'package:mobile_app/communication/model/send_command_type.dart';
import 'package:mobile_app/communication/transport/socket_channel.dart';
import 'package:mobile_app/communication/transport/socket_connection.dart';

class TunneledConnection implements SocketChannel {

  @override
  bool isConnected = false;

  final SocketConnection _socketConnection;

  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  final StreamController<ReceivedPacket> _receivedDataController = StreamController<ReceivedPacket>.broadcast();
  final StreamController<ConnectionError> _errorController = StreamController<ConnectionError>.broadcast();

  @override
  Stream<ReceivedPacket> get receivedDataStream => _receivedDataController.stream;
  @override
  Stream<bool> get statusStream => _connectionStatusController.stream;
  @override
  Stream<ConnectionError> get errorStream => _errorController.stream;

  TunneledConnection(this._socketConnection) {

    _socketConnection.statusStream.listen((status) {
      if (isConnected && !status) {
        isConnected = false;
        _connectionStatusController.add(isConnected);
      }
    });

    _socketConnection.receivedDataStream.listen((packet) {
      if (packet.commandType.startsWith(ReceiveCommandType.tunnelWriteConnectionStatus.code)) {
        isConnected = packet.payload[0] == 1;
        _connectionStatusController.add(isConnected);
      } else if (packet.commandType.startsWith(ReceiveCommandType.tunnelWriteConnectionError.code)) {
        _errorController.add(ConnectionError(ConnectionErrorType.tunnelledConnectionError, packet.payloadAsString));
      }
      else if (packet.commandType.startsWith('F') || packet.commandType.startsWith('T')) {
        _receivedDataController.add(ReceivedPacket(commandType: _translateTypeCommand(packet.commandType), payload: packet.payload));
      }
    });
  }

  @override
  Future<void> closeConnection() async {
    if (isConnected) {
      await _socketConnection.sendGuaranteedCommand(SendCommandType.writeTunnelDisconnect.code);
    }
  }
    

  @override
  Future<void> connect([String? host, int? port]) =>
    _socketConnection.sendGuaranteedCommand(SendCommandType.writeTunnelConnect.code);

  @override
  Future<bool> sendCommand(String typeCommand, [List<int>? data]) =>
    _socketConnection.sendCommand(_translateTypeCommand(typeCommand), data);

  @override
  Future<bool> sendGuaranteedCommand(String typeCommand, [List<int>? data]) =>
    _socketConnection.sendGuaranteedCommand(_translateTypeCommand(typeCommand), data);

  String _translateTypeCommand(String typeCommand) {
    final firstChar = switch (typeCommand[0]) {
      'R' => 'T',
      'T' => 'R',
      'W' => 'F',
      'F' => 'W',
      _ => typeCommand[0],
    };
    return '$firstChar${typeCommand.substring(1)}';
  }
}