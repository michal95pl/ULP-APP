import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_app/communication/device_error.dart';
import 'package:mobile_app/communication/host_type.dart';

class SocketConnection {

  String? hostName;
  HostType hostType = HostType.unknown;
  var _connectionStatus = false;
  Socket? _socket;
  StreamSubscription<List<int>>? _socketSubscription;
  
  static const int connectionTimeout = 2;

  // wait for ack from the server. ESP32 will send ack after receiving command. 
  // It us used to synchronize with microcontrollers
  Completer<void>? _ackCompleter;

  // void because we don't need to send any data, just notify listeners that host info has changed
  final StreamController<void> _connectionHostInfoController = StreamController<void>.broadcast();
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  final StreamController<String> _statusDataController = StreamController<String>.broadcast();
  final StreamController<DeviceError> _errorController = StreamController<DeviceError>.broadcast();

  Stream<bool> get statusStream => _connectionStatusController.stream;
  Stream<String> get rawDataStream => _statusDataController.stream;
  Stream<void> get connectionHostInfoStream => _connectionHostInfoController.stream;
  Stream<DeviceError> get errorStream => _errorController.stream;

  // Throws SocketException and TimeoutException
  Future<void> connect(String host, int port) async {
    await closeConnection();

    final Socket socket;
    try {
      socket = await Socket.connect(host, port).timeout(const Duration(seconds: connectionTimeout));
      _socket = socket;
    } catch (e) {
      debugPrint("[SocketConnection] Error connecting to $host:$port - $e");
      rethrow;
    }

    _connectionStatus = true;
    _connectionStatusController.add(_connectionStatus);

    final BytesBuilder bytesBuffer = BytesBuilder(copy: false);
    const int etxSeparator = 0x03;

    // receive data
    _socketSubscription = _socket!.listen(
      (List<int> event) {
        bytesBuffer.add(event);
        Uint8List currentBytes = bytesBuffer.toBytes();
        int separatorIndex;
        
        while ((separatorIndex = currentBytes.indexOf(etxSeparator)) != -1) {
          Uint8List packetBytes = currentBytes.sublist(0, separatorIndex);
          Uint8List remainingBytes = currentBytes.sublist(separatorIndex + 1);
          bytesBuffer.clear();
          bytesBuffer.add(remainingBytes);
          currentBytes = remainingBytes;

          String command = utf8.decode(packetBytes, allowMalformed: true);

          // ST - status command, W - write type command
          if (command.startsWith("WST"))
          {
            // remove command type
            var jsonData = command.substring(3).trim();
            _statusDataController.add(jsonData);
            debugPrint("[SocketConnection] Received status data: $jsonData");
          }
          // WAC - ack command
          else if (command.startsWith("WAC"))
          {
            if (_ackCompleter != null && !_ackCompleter!.isCompleted) {
              _ackCompleter!.complete();
            }
            debugPrint("[SocketConnection] Received ack");
          }
          else if (command.startsWith("WHO"))
          {
            try {
              var jsonData = command.substring(3).trim();
              final Map<String, dynamic> data = jsonDecode(jsonData) as Map<String, dynamic>;

              hostName = data['hostName'] as String? ?? 'Unknown Host';
              hostType = HostType.fromString(data['hostType'] as String?);

              _connectionHostInfoController.add(null);
              debugPrint("[SocketConnection] Received WHO command: $command");
            } catch (e) {
              debugPrint("[SocketConnection] Error parsing WHO command: $e");
              _errorController.add(DeviceError.fromParsing(e));
            }
          }
          else {
            debugPrint("[SocketConnection] Unknown command received: $command");
            _errorController.add(DeviceError(DeviceErrorType.parsingError, 'Unknown command received'));
          }
        } 
      },
      onError: (error) async {
        debugPrint("[SocketConnection] Error $error");
        _errorController.add(DeviceError.fromSocket(error));
        await closeConnection();
      },
      onDone: () async {
        debugPrint("[SocketConnection] Connection stream closed");
        await closeConnection();
      }
    );
  }

  Future<void> closeConnection() async {
    if (_socketSubscription != null) {
      await _socketSubscription!.cancel();
      _socketSubscription = null;
    }
    
    if (_socket != null) {
      try {
        await _socket!.close();
      } catch (e) {
        debugPrint("[SocketConnection] Error closing socket: $e");
      }
      finally {
        _socket = null;
        _connectionStatus = false;
        _connectionStatusController.add(_connectionStatus);

        if (_ackCompleter != null && !_ackCompleter!.isCompleted) {
          _ackCompleter!.completeError(Exception("Connection closed before receiving ack"));
        }
      }
    }
  }

  bool isWaitingForAck() {
    return _ackCompleter != null;
  }

  // Send command to the server. Return true if command was received by the server.
  Future<bool> sendCommand(String typeCommand, [List<int>? data]) async {
    if (_socket == null || isWaitingForAck()) {
      return false;
    }

    try {
      _ackCompleter = Completer<void>();

      final List<int> payload = data ?? const [];
      final builder = BytesBuilder(copy: false);

      builder.add(ascii.encode(typeCommand));
      // length of data is 2 bytes
      builder.add([
        (payload.length >> 8) & 0xFF,
        payload.length & 0xFF,
      ]);
      if (payload.isNotEmpty) {
        builder.add(payload);
      }
      // preambula has type of command (3 bytes) and length of data (2 bytes). Length of data is used to devide commands on the server side
      _socket!.add(builder.toBytes());
      await _socket!.flush();
      await _ackCompleter!.future.timeout(const Duration(seconds: 1));
      
      return true;
    } catch (e) {
      await closeConnection();
      debugPrint("[SocketConnection] Error: $e");
      _errorController.add(DeviceError.fromSocket(e));
      return false;
    } finally {
      _ackCompleter = null;
    } 
  }

  bool isConnected() {
    return _connectionStatus;
  }

  void emitError(DeviceError error) {
    _errorController.add(error);
  }
}