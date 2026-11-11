import 'dart:convert';
import 'dart:typed_data';

class ReceivedPacket {
  final String commandType;
  final Uint8List payload;

  const ReceivedPacket({
    required this.commandType,
    required this.payload,
  });

  String get payloadAsString => utf8.decode(payload, allowMalformed: true);
}