import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mobile_app/communication/mobile_connection_listener.dart';
import 'package:mobile_app/status_mobile_data.dart';

class SocketConnection {

  var _connectionStatus = false;
  Socket? _socket;
  MobileConnectionListener? _listener;

  static const int connectionTimeout = 2;

  // wait for ack from the server. ESP32 will send ack after receiving command. 
  // It us used, becuse esp32 has problem with buffering commands
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

          // devide data by K at the end (sometimes multiple commands are received at once)
          var commands = data.split("K");
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
  Future<bool> sendCommand(String command) async {
    if (_socket == null || isWaitingForAck()) {
      return false;
    }

    try {
      _ackCompleter = Completer<void>();
      _socket!.write(command);
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
}