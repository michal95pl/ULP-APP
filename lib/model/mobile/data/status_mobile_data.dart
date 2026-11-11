import 'dart:convert';

import 'package:mobile_app/model/mobile/data/display_mobile_data.dart';
import 'package:mobile_app/model/mobile/data/strip_mobile_data.dart';

class StatusMobileData {

  final DisplayMobileData displayData;
  final StripMobileData stripData;
  bool synchEnabled; // can be changed if deviced send special command with synch state

  StatusMobileData({
    required this.displayData,
    required this.stripData,
    required this.synchEnabled
  });

  factory StatusMobileData.getStatusData(String data) {
    var jsonData = jsonDecode(data);
    final bool synch = jsonData['synch'] as bool;
    var displayData = DisplayMobileData.fromJson(jsonData['displayData']);
    var stripData = StripMobileData.fromJson(jsonData['stripData']);
    return StatusMobileData(displayData: displayData, stripData: stripData, synchEnabled: synch);
  }

}