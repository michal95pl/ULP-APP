enum DeviceCommand {
  readStatus('RST'),

  writeBrightness('WSB'),
  writeSpeedEffect('WSS'),
  writeColor('WSC'),
  writeEffect('WSE'),
  writeDisplayFrame('WDF'),
  writeDisplayText('WDT');


  final String code;
  const DeviceCommand(this.code);
}