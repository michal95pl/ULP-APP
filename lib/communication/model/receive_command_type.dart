enum ReceiveCommandType {
  /*
  R - Read command
  W - Write command
  T - Tunnel write command
  F - Tunnel read (fetch) command
  */
  writeAcknowledge('WAC'),
  writeStatus('WST'),
  writeHostInfo('WHO'),
  writeDisplayFrame('WDF'),

  tunnelWriteConnectionStatus('TCS'),
  tunnelWriteConnectionError('TCE');

  final String code;
  const ReceiveCommandType(this.code);
}