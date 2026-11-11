enum SendCommandType {
  /*
  R - Read command
  W - Write command
  T - Tunnel write command
  F - Tunnel read (fetch) command
  */
  readStatus('RST'),
  readDisplayFrame('RDF'),

  writeBrightness('WSB'),
  writeSpeedEffect('WSS'),
  writeColor('WSC'),
  writeEffect('WSE'),
  writeDisplayFrame('WDF'),
  writeDisplayText('WDT'),
  writeSynch('WSY'),

  // Commands to handle the tunnel connection
  writeTunnelConnect('TTC'),
  writeTunnelDisconnect('TTD');


  final String code;
  const SendCommandType(this.code);
}