import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_app/communication/mobile_connection_listener.dart';
import 'package:mobile_app/status_mobile_data.dart';

class SocketConnection {

  var _connectionStatus = false;
  Socket? _socket;
  MobileConnectionListener? _listener;

  static const int connectionTimeout = 2;

  // wait for ack from the server. ESP32 will send ack after receiving command. 
  // It us used to synchronize with microcontrollers
  Completer<void>? _ackCompleter;

  Future<void> connect(String host, int port) async {
    try {
      var connection = await Socket.connect(host, port).timeout(const Duration(seconds: connectionTimeout));
      _socket = connection;

      _connectionStatus = true;
      if (_listener != null) {
        _listener!.onConnectionMobileStatusChanged(_connectionStatus);
      }

      // receive data
      connection.listen(
        (List<int> event) {
          var data = String.fromCharCodes(event);

          // devide commands by 0x03 (ETX) character (sometimes multiple commands are received at once)
          // importand: 0x03 is not allowed in the data
          // todo: change 0x03 to somethig else
          var commands = data.split(String.fromCharCode(0x03));
          commands.removeLast();

          for (var command in commands) {
            // ST - status command, W - write type command
            if (command.startsWith("STW"))
            {
              // remove command type
              var jsonData = command.substring(3);
              if (_listener != null) {
                _listener!.onStatusMobileDataReceived(StatusMobileData.getStatusData(jsonData));
              }
              debugPrint("[SocketConnection] Received status data: $jsonData");
            }
            // ACW - ack command
            else if (command.startsWith("ACW"))
            {
              _ackCompleter!.complete();
              
              debugPrint("[SocketConnection] Received ack");
            }
          }
        },
        onError: (error) async {
          debugPrint("[SocketConnection] Error $error");
          await closeConnection();
        }, 
        onDone: () async {
          debugPrint("[SocketConnection] Connection stream closed");
          await closeConnection();
        }
      );
    } catch (e) {
      debugPrint("[SocketConnection] Error: $e");
    }
  }

  Future<void> closeConnection() async {
    if (_socket != null) {
      try {
        await _socket!.close();
      } catch (e) {
        debugPrint("[SocketConnection] Error closing socket: $e");
      }
      _socket = null;
      _connectionStatus = false;
      if (_listener != null) {
        _listener!.onConnectionMobileStatusChanged(_connectionStatus);
      }
    }
  }

  bool isWaitingForAck() {
    return _ackCompleter != null;
  }

  // Send command to the server. Return true if command was received by the server.
  Future<bool> sendCommand(String typeCommand, String data) async {
    if (_socket == null || isWaitingForAck()) {
      return false;
    }

    try {
      _ackCompleter = Completer<void>();
      // preambula has type of command (3 bytes) and length of data (2 bytes). Length of data is used to devide commands on the server side
      _socket!.write(typeCommand + _convertValueToBytes(data.length) + data);
      await _socket!.flush();
      await _ackCompleter!.future.timeout(const Duration(seconds: 1));
      
      return true;
    } catch (e) {
      await closeConnection();
      debugPrint("[SocketConnection] Error: $e");
      return false;
    } finally {
      _ackCompleter = null;
    } 
  }

  bool isConnected() {
    return _connectionStatus;
  }

  void setListener(MobileConnectionListener listener) {
    _listener = listener;
  }

  // convert 2 byte value to 2 x 1 byte value in string
  String _convertValueToBytes(int value) {
    Uint8List bytes = Uint8List(2);
    bytes[0] = (value.toInt() >> 8) & 0xFF; // msb
    bytes[1] = value & 0xFF;        // lsb
    return String.fromCharCodes(bytes);
  }
}