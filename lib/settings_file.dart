import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class SettingsFile {

  static File? file;

  static Future<void> openFile(String path) async {
    Directory appDirectory = await getApplicationDocumentsDirectory();
    file = File('${appDirectory.path}/$path');

    if (!await file!.exists()) {
      await file!.create();
      await file!.writeAsString('''
      {
      "device_addresses" : [
      {
      "ip": "",
      "port": ""
      },
      {
      "ip": "",
      "port": ""
      }
      ]
      }
      ''');
    }
  }

  static void writeAddress(String ip, String port, int index) {
    try {
      final contents = file!.readAsStringSync();
      Map<String, dynamic> data = jsonDecode(contents);
      data['device_addresses'][index]["ip"] = ip;
      data['device_addresses'][index]["port"] = port;
      file!.writeAsStringSync(jsonEncode(data));
    } catch (e) {
      debugPrint("[SettingsFile] error: $e");
    }
  }

  static Map<String, String> readAddress(int index) {
    try {
      final contents = file!.readAsStringSync();
      Map<String, dynamic> data = jsonDecode(contents);
      return {
        "ip": data['device_addresses'][index]["ip"],
        "port": data['device_addresses'][index]["port"]
      };
    } catch (e) {
      debugPrint("[SettingsFile] error: $e");
    }
    return {"ip":"","port":""};
  }

}