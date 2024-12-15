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

  void decode(String data) {
    var jsonData = jsonDecode(data);

    _usbPD = (jsonData['usb_pd'].toInt() == 1);
    _communicationModule = (jsonData['communication_module'].toInt() == 1);
    _fan = (jsonData['fan'].toInt() == 1);
    _temperaturePCB = jsonData['temperature_pcb'].toDouble();
    _temperatureESP32 = jsonData['temperature_esp32'].toDouble();
    _temperatureSTM32 = jsonData['temperature_stm32'].toDouble();
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

  @override
  String toString() {
    return 'StatusData{usbPD: $_usbPD, communicationModule: $_communicationModule, fan: $_fan, temperaturePCB: $_temperaturePCB, temperatureESP32: $_temperatureESP32, temperatureSTM32: $_temperatureSTM32}';
  }
}