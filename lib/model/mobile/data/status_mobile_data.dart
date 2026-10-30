import 'dart:convert';

import 'package:mobile_app/model/mobile/data/display_mobile_data.dart';
import 'package:mobile_app/model/mobile/data/strip_mobile_data.dart';

class StatusMobileData {

  final DisplayMobileData displayData;
  final StripMobileData stripData;

  StatusMobileData({
    required this.displayData,
    required this.stripData,
  });

  factory StatusMobileData.getStatusData(String data) {
    var jsonData = jsonDecode(data);
    var displayData = DisplayMobileData.fromJson(jsonData['displayData']);
    var stripData = StripMobileData.fromJson(jsonData['stripData']);
    return StatusMobileData(displayData: displayData, stripData: stripData);
  }

}