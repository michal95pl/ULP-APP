import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mobile_app/status_data.dart';

abstract class CommunicationListener {
  void onConnectionStatusChanged(List<bool> connections);
  void onStatusDataReceived(StatusData statusData);
}

class Communication {

  // ignore: constant_identifier_names
  static const int CONNECTION_TIMEOUT = 500;

  static final _socketList = <Socket?>[null, null];
  static final _connectionStatuses = [false, false];

  ///  Create connection to the server.
  ///
  ///  param host - server host
  /// 
  ///  param port - server port
  /// 
  ///  param socketId - socket id - identifier of the socket in the list
  /// 
  ///  return connection id -1 if connection failed, otherwise connection id
  static Future<void> createConnection(String host, int port, int socketId) async {
    try {
      var connection = await Socket.connect(host, port, timeout: const Duration(milliseconds: CONNECTION_TIMEOUT));
      _socketList[socketId] = connection;
      _connectionStatuses[socketId] = true;
      if (_listener != null) {
        _listener!.onConnectionStatusChanged(_connectionStatuses);
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
              if (_listener != null) {
                // remove command type
                var jsonData = command.substring(3);
                _listener!.onStatusDataReceived(StatusData.getStatusData(jsonData));
                debugPrint("[Communication] Received status data: $jsonData");
              }
            }
          }
        }, 
        onError: (error) {
          debugPrint("Error: $error");
          closeConnection(socketId);
        }, 
        onDone: () {
          debugPrint("[Communication] Connection stream closed");
          closeConnection(socketId);
        }
      );

    } catch (e) {
      debugPrint("[Communication] Error: $e");
      closeConnection(socketId);
    }
  }


  static void closeConnection(int socketId) async {
    if (_socketList[socketId] != null) {
      try {
        await _socketList[socketId]!.close();
      } catch (e) {
        debugPrint("[Communication] Error closing socket: $e");
      }
      _socketList[socketId] = null;
      _setConnectionStatus(socketId, false);
    }
  }

  static List<bool> getConnectionsStatus() {
    return _connectionStatuses;
  }

  static CommunicationListener? _listener;

  static void setListener(CommunicationListener listener) {
    _listener = listener;
  }

  static void _setConnectionStatus(int socketId, bool status) {
    _connectionStatuses[socketId] = status;
    if (_listener != null) {
      _listener!.onConnectionStatusChanged(_connectionStatuses);
    }
  }

  /*
   * Commands:
   * 2 characters - type of command
   * W - write / R - read
   * data
   * k - end of command
   */

  /// Send status command. Server will respond with status data.
  static void sendStatusCommand(int socketId) {
    try {
      if (_connectionStatuses[socketId]) {
        _socketList[socketId]!.write("STRK");
        debugPrint("[Communication] Sent status command");
      }
    } catch (e) {
      debugPrint("[Communication] Error: $e");
      closeConnection(socketId);
    }
  }

  /// Send brightness to the server.
  /// 
  /// param brightness - brightness value (0-100)
  static void sendStripBrightness(int socketId, int brightness) {
    try {
      if (_connectionStatuses[socketId]) {
        _socketList[socketId]!.write("SBW${String.fromCharCode(brightness)}K");
      }
    } catch (e) {
      debugPrint("[Communication] Error: $e");
      closeConnection(socketId);
    }
  }

  /// Send speed effect to the server.
  /// 
  /// param speed - speed value (0-100)
  static void sendStripSpeedEffect(int socketId, int speed) {
    try {
      if (_connectionStatuses[socketId]) {
        _socketList[socketId]!.write("SSW${String.fromCharCode(speed)}K");
      }
    } catch (e) {
      debugPrint("[Communication] Error: $e");
      closeConnection(socketId);
    }
  }

  /// Send primary color to the server.
  /// 
  /// @param color - color value
  static void sendPrimaryStripColor(int socketId, Color color) {
    try {
      if (_connectionStatuses[socketId]) {
        // SCW {index} {red} {green} {blue} k
        _socketList[socketId]!.write("SCW${String.fromCharCode(0)}${String.fromCharCode(color.red)}${String.fromCharCode(color.green)}${String.fromCharCode(color.blue)}K");
      }
    } catch (e) {
      debugPrint("[Communication] Error: $e");
      closeConnection(socketId);
    }
  }

  /// Send secondary color to the server.
  ///   
  /// @param color - color value
  static void sendSecondaryStripColor(int socketId, Color color) {
    try {
      if (_connectionStatuses[socketId]) {
         // SCW {index} {red} {green} {blue} k
        _socketList[socketId]!.write("SCW${String.fromCharCode(1)}${String.fromCharCode(color.red)}${String.fromCharCode(color.green)}${String.fromCharCode(color.blue)}K");
      }
    } catch (e) {
      debugPrint("[Communication] Error: $e");
      closeConnection(socketId);
    }
  }

  /// Send effect to the server.
  /// 
  /// @param effect - effect index
  static void sendStripEffect(int socketId, int effect) {
    try {
      if (_connectionStatuses[socketId]) {
        _socketList[socketId]!.write("SEW${String.fromCharCode(effect)}K");
      }
    } catch (e) {
      debugPrint("[Communication] Error: $e");
      closeConnection(socketId);
    }
  }
}