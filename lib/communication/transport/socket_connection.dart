import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:mobile_app/communication/model/receive_command_type.dart';
import 'package:mobile_app/communication/transport/socket_channel.dart';
import 'package:mobile_app/communication/model/connection_error.dart';

class SocketConnection implements SocketChannel {

  var _connectionStatus = false;
  Socket? _socket;
  StreamSubscription<List<int>>? _socketSubscription;

  Future<void> _commandQueue = Future.value();

  static const int _connectionTimeout = 2;

  // wait for ack from the server. ESP32 will send ack after receiving command.
  // It us used to synchronize with microcontrollers
  Completer<void>? _ackCompleter;

  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  final StreamController<String> _receivedDataController = StreamController<String>.broadcast();
  final StreamController<ConnectionError> _errorController = StreamController<ConnectionError>.broadcast();

  @override
  Stream<bool> get statusStream => _connectionStatusController.stream;
  @override
  Stream<String> get receivedDataStream => _receivedDataController.stream;
  @override
  Stream<ConnectionError> get errorStream => _errorController.stream;

  @override
  get isConnected => _connectionStatus;

  SocketConnection();

  // Throws SocketException and TimeoutException
  @override
  Future<void> connect([String? host, int? port]) async {
    await closeConnection();

    final Socket socket;
    try {
      socket = await Socket.connect(host!, port!).timeout(const Duration(seconds: _connectionTimeout));
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
        
        //TODO: esp should send length of data in the preambula, so we can read the exact number of bytes and avoid separator issues.
        while ((separatorIndex = currentBytes.indexOf(etxSeparator)) != -1) {
          Uint8List packetBytes = currentBytes.sublist(0, separatorIndex);
          Uint8List remainingBytes = currentBytes.sublist(separatorIndex + 1);
          bytesBuffer.clear();
          bytesBuffer.add(remainingBytes);
          currentBytes = remainingBytes;

          String command = utf8.decode(packetBytes, allowMalformed: true);

          // WAC - ack command
          if (command.startsWith(ReceiveCommandType.writeAcknowledge.code)) {
            if (_ackCompleter != null && !_ackCompleter!.isCompleted) {
              _ackCompleter!.complete();
            }
            debugPrint("[SocketConnection] Received ack");
          }
          else {
            debugPrint("[SocketConnection] Received data: $command");
            _receivedDataController.add(command);
          }
        }
      },
      onError: (error) async {
        debugPrint("[SocketConnection] Error $error");
        _errorController.add(ConnectionError.fromSocket(error));
        await closeConnection();
      },
      onDone: () async {
        debugPrint("[SocketConnection] Connection stream closed");
        await closeConnection();
      }
    );
  }

  @override
  Future<void> closeConnection() async {
    _commandQueue = Future.value();
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
          _ackCompleter!.complete();
          _ackCompleter = null;
        }
      }
    }
  }

  bool isWaitingForAck() {
    return _ackCompleter != null;
  }

  /// Send command to the server. Return true if command was received by the server.
  /// This method not guarantee that the command wiil be sent. It sends only if the socket is ready to receive.
  /// data should be a list of bytes (8bit integers)!
  @override
  Future<bool> sendCommand(String typeCommand, [List<int>? data]) async {
    if (!_connectionStatus || _socket == null || isWaitingForAck()) {
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
      _errorController.add(ConnectionError.fromSocket(e));
      return false;
    } finally {
      _ackCompleter = null;
    } 
  }

  /// Send command to the server. Return true if command was received by the server.
  /// This method guarantees that the command will be sent, even if the device is not ready to receive.
  /// It will wait for the socket to be ready and for any previous commands to be acknowledged before sending the new command.
  /// data should be a list of bytes (8bit integers)!
  @override
  Future<bool> sendGuaranteedCommand(String typeCommand, [List<int>? data]) {
    if (_connectionStatus == false || _socket == null) {
      return Future.value(false);
    }

    final completer = Completer<bool>();

    _commandQueue = _commandQueue.catchError((_) {}).then((_) async {
      if (_socket == null) {
        completer.complete(false);
        return;
      }
      if (isWaitingForAck()) {
        try {
          await _ackCompleter!.future;
        } catch (_) {
        }
      }
      final result = await sendCommand(typeCommand, data);
      
      if (!completer.isCompleted) {
        completer.complete(result);
      }
      
    }).catchError((error) {
      if (!completer.isCompleted) {
        completer.complete(false);
      }
    });

    return completer.future;
  }
}