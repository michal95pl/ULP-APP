import 'package:mobile_app/communication/model/connection_error.dart';
import 'package:mobile_app/communication/model/received_packet.dart';

abstract interface class SocketChannel {
  Stream<bool> get statusStream;
  Stream<ReceivedPacket> get receivedDataStream;
  Stream<ConnectionError> get errorStream;

  bool get isConnected;

  // host and port need to be provided when connecting through socket, but not when using tunneled connection
  Future<void> connect([String? host, int? port]);
  Future<void> closeConnection();

  Future<bool> sendCommand(String typeCommand, [List<int>? data]);
  Future<bool> sendGuaranteedCommand(String typeCommand, [List<int>? data]);
}