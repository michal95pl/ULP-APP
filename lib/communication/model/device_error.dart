import 'dart:async';
import 'dart:io';

enum DeviceErrorType {
  unknown, parsingError, connectionError, invalidHostType, timeout;
}

class DeviceError {
  final DeviceErrorType type;
  final String message;

  const DeviceError(this.type, this.message);

  factory DeviceError.fromSocket(dynamic error) {
    if (error is SocketException) {
      switch (error.osError?.errorCode) {
        case 111:
          return const DeviceError(DeviceErrorType.connectionError, 'Connection refused by target device');
        case 104:
          return const DeviceError(DeviceErrorType.connectionError, 'Connection reset by peer');
        case 113:
          return const DeviceError(DeviceErrorType.connectionError, 'No route to host');
        default:
          return DeviceError(DeviceErrorType.connectionError, error.osError?.message ?? 'Network socket error');
      }
    } else if (error is TimeoutException) {
      return const DeviceError(DeviceErrorType.timeout, 'Connection timed out');
    }
    
    return DeviceError(DeviceErrorType.unknown, error.toString());
  }

  factory DeviceError.fromParsing(dynamic error) {
    return DeviceError(
      DeviceErrorType.parsingError, 
      'Invalid data received',
    );
  }
}