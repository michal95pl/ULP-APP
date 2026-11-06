import 'dart:async';
import 'dart:io';

enum ConnectionErrorType {
  unknown, connectionError, invalidHostType, timeout, parsingError, unknownCommand, tunnelledConnectionError;
}

class ConnectionError {
  final ConnectionErrorType type;
  final String message;

  const ConnectionError(this.type, this.message);

  factory ConnectionError.fromSocket(dynamic error) {
    if (error is SocketException) {
      switch (error.osError?.errorCode) {
        case 111:
          return const ConnectionError(ConnectionErrorType.connectionError, 'Connection refused by target device');
        case 104:
          return const ConnectionError(ConnectionErrorType.connectionError, 'Connection reset by peer');
        case 113:
          return const ConnectionError(ConnectionErrorType.connectionError, 'No route to host');
        default:
          return ConnectionError(ConnectionErrorType.connectionError, error.osError?.message ?? 'Network socket error');
      }
    } else if (error is TimeoutException) {
      return const ConnectionError(ConnectionErrorType.timeout, 'Connection timed out');
    }
    
    return ConnectionError(ConnectionErrorType.unknown, error.toString());
  }
}