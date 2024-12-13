import 'package:flutter/material.dart';

class InfoBoard {

  // show board when received at least one data
  static bool showInfoBoard = false;

  static bool fan = false;
  static double pcbTemperature = 25.0;
  static double espTemperature = 25.0;
  static double stmTemperature = 25.0;

  static Column getBoard() {

    if (!showInfoBoard) {
      return const Column();
    }

    return Column(children: [
      Row(children: [
        const SizedBox(width: 10),
        const Text("Fan", style: TextStyle(color: Colors.white, fontSize: 18)),
        Icon(Icons.cyclone, color: fan ? Colors.green : Colors.red),
        Text(" ${fan ? "ON" : "OFF"}", style: const TextStyle(color: Colors.white, fontSize: 18))
      ]),
      Row(children: [
        const SizedBox(width: 10),
        const Text("PCB temperature", style: TextStyle(color: Colors.white, fontSize: 18)),
        const Icon(Icons.thermostat, color: Colors.blue),
        Text(" $pcbTemperature °C", style: const TextStyle(color: Colors.white, fontSize: 18))
      ]),
      Row(children: [
        const SizedBox(width: 10),
        const Text("ESP temperature", style: TextStyle(color: Colors.white, fontSize: 18)),
        const Icon(Icons.thermostat, color: Colors.blue),
        Text(" $espTemperature °C", style: const TextStyle(color: Colors.white, fontSize: 18))
      ]),
      Row(children: [
        const SizedBox(width: 10),
        const Text("STM temperature", style: TextStyle(color: Colors.white, fontSize: 18)),
        const Icon(Icons.thermostat, color: Colors.blue),
        Text(" $stmTemperature °C", style: const TextStyle(color: Colors.white, fontSize: 18))
      ]),
    ]);
  }

  static set fanStatus(bool status) {
    fan = status;
  }

  static set pcbTemp(double temp) {
    pcbTemperature = temp;
  }

  static set espTemp(double temp) {
    espTemperature = temp;
  }

  static set stmTemp(double temp) {
    stmTemperature = temp;
  }

  static void showBoard() {
    showInfoBoard = true;
  }
}