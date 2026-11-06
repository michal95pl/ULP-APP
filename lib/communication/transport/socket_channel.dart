import 'package:mobile_app/communication/model/connection_error.dart';

abstract interface class SocketChannel {
  Stream<bool> get statusStream;
  Stream<String> get receivedDataStream;
  Stream<ConnectionError> get errorStream;

  bool get isConnected;

  // host and port need to be provided when connecting through socket, but not when using tunneled connection
  Future<void> connect([String? host, int? port]);
  Future<void> closeConnection();

  Future<bool> sendCommand(String typeCommand, [List<int>? data]);
  Future<bool> sendGuaranteedCommand(String typeCommand, [List<int>? data]);
}