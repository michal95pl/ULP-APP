import 'dart:convert';

class StatusMobileData {

  // true if the device is connected to the high power power supply
  bool _usbPD = false;

  // true if the sx1281 module is powered
  bool _communicationModule = false;

  bool _fan = false;
  double _temperaturePCB = 0.0;
  double _temperatureESP32 = 0.0;
  double _temperatureSTM32 = 0.0;
  int _stripBrightness = 0;
  int _stripSpeedEffect = 0;
  int _stripEffect = 0;
  List<int> _stripFirstColor = [0, 0, 0];
  List<int> _stripSecondColor = [0, 0, 0];

  void decode(String data) {
    var jsonData = jsonDecode(data);
    decodeESP32Data(jsonData['ESP']);
    decodeSTM32Data(jsonData['STM']);
    
  }

  void decodeESP32Data(Map<String, dynamic> jsonData) {
    _usbPD = (jsonData['usb_pd'].toInt() == 1);
    _communicationModule = (jsonData['communication_module'].toInt() == 1);
    _fan = (jsonData['fan'].toInt() == 1);
    _temperaturePCB = jsonData['temp_pcb'].toDouble();
    _temperatureESP32 = jsonData['temp_esp32'].toDouble();
    _temperatureSTM32 = jsonData['temp_stm32'].toDouble();
  }

  void decodeSTM32Data(Map<String, dynamic> jsonData) {
    var stripData = jsonData['strip'];
    _stripBrightness = stripData['brightness'].toInt();
    _stripSpeedEffect = stripData['speed'].toInt();
    _stripEffect = stripData['effect'].toInt();
    _stripFirstColor = [
      stripData['color0'][0].toInt(),
      stripData['color0'][1].toInt(),
      stripData['color0'][2].toInt()
    ];
    _stripSecondColor = [
      stripData['color1'][0].toInt(),
      stripData['color1'][1].toInt(),
      stripData['color1'][2].toInt()
    ];
  }

  static StatusMobileData getStatusData(String data) {
    var statusData = StatusMobileData();
    statusData.decode(data);
    return statusData;
  }

  bool get pd => _usbPD;
  bool get communicationModule => _communicationModule;
  bool get fan => _fan;
  double get temperaturePCB => _temperaturePCB;
  double get temperatureESP32 => _temperatureESP32;
  double get temperatureSTM32 => _temperatureSTM32;

  int get stripBrightness => _stripBrightness;
  int get stripSpeedEffect => _stripSpeedEffect;
  int get stripEffect => _stripEffect;
  List<int> get stripFirstColor => _stripFirstColor;
  List<int> get stripSecondColor => _stripSecondColor;

  @override
  String toString() {
    return 'StatusData{usbPD: $_usbPD, communicationModule: $_communicationModule, fan: $_fan, temperaturePCB: $_temperaturePCB, temperatureESP32: $_temperatureESP32, temperatureSTM32: $_temperatureSTM32}';
  }
}