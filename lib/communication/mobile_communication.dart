
// This class is responsible for communication with the mobile ULP
import 'package:flutter/material.dart';
import 'package:mobile_app/communication/socket_connection.dart';
import 'package:mobile_app/communication/mobile_connection_listener.dart';

class MobileCommunication {

  static SocketConnection connection = SocketConnection();

  static Future<void> connect(String host, int port) async {
    await connection.connect(host, port);
  }

  static bool isConnected() {
    return connection.isConnected();
  }

  static void setListener(MobileConnectionListener listener) {
    connection.setListener(listener);
  }

  static bool isReadyToSend() {
    return !connection.isWaitingForAck();
  }

  /*
   * Commands:
   * 2 characters - type of command
   * W - write / R - read
   * data
   * k - end of command
   */
  // todo: change K to 253 (0xFD) - end of command

  /// Send status command. Server will respond with status data.
  static Future<void> sendStatusCommand() async {
    await connection.sendCommand("STR", "");
  }

  /// Send brightness to the server.
  /// 
  /// param brightness - brightness value (0-100)
  static Future<void> sendStripBrightness(int brightness) async {
    await connection.sendCommand("SBW", String.fromCharCode(brightness));
  }

  /// Send speed effect to the server.
  /// 
  /// param speed - speed value (0-100)
  static Future<void> sendStripSpeedEffect(int speed) async {
    await connection.sendCommand("SSW", String.fromCharCode(speed));
  }

  /// Send primary color to the server.
  /// 
  /// @param color - color value
  static Future<void> sendPrimaryStripColor(Color color) async {
    // SCW {index} {red} {green} {blue} k
    await connection.sendCommand("PCW", String.fromCharCode(0) + String.fromCharCode(color.red) + String.fromCharCode(color.green) + String.fromCharCode(color.blue));
  }

  /// Send secondary color to the server.
  ///   
  /// @param color - color value
  static Future<void> sendSecondaryStripColor(Color color) async {
    // SCW {index} {red} {green} {blue} k
    await connection.sendCommand("SCW", String.fromCharCode(1) + String.fromCharCode(color.red) + String.fromCharCode(color.green) + String.fromCharCode(color.blue));
  }

  /// Send effect to the server.
  /// 
  /// @param effect - effect index
  static Future<void> sendStripEffect(int effect) async {
    await connection.sendCommand("SEW", String.fromCharCode(effect));
  }
}