import 'package:flutter/material.dart';

class InfoBoard {

  // show board when received at least one data
  static bool showInfoBoard = false;

  static bool fan = false;
  static double pcbTemperature = 0.0;
  static double espTemperature = 0.0;
  static double stmTemperature = 0.0;

  static Container getBoard() {

    if (!showInfoBoard) {
      return Container();
    }

    return Container(
      width: 220,
      padding: const EdgeInsets.all(6),
      margin: const EdgeInsets.all(10.0),
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 28, 28, 28),
        borderRadius: BorderRadius.all(Radius.circular(12.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(
            child: Text("Mobile ULP", style: TextStyle(color: Color.fromARGB(255, 191, 0, 255), fontSize: 22))
          ),
          const SizedBox(width: 20),
          Row(children: [
            const SizedBox(width: 10),
            const Text("Fan", style: TextStyle(color: Colors.white, fontSize: 18)),
            Icon(Icons.cyclone, color: fan ? Colors.green : const Color.fromARGB(255, 241, 0, 128)),
            Text(" ${fan ? "ON" : "OFF"}", style: const TextStyle(color: Colors.white, fontSize: 18))
          ]),
          Row(children: [
            const SizedBox(width: 10),
            const Text("PCB temp", style: TextStyle(color: Colors.white, fontSize: 18)),
            const Icon(Icons.thermostat, color: Color.fromARGB(255, 0, 171, 231)),
            Text(" $pcbTemperature °C", style: const TextStyle(color: Colors.white, fontSize: 18))
          ]),
          Row(children: [
            const SizedBox(width: 10),
            const Text("ESP temp", style: TextStyle(color: Colors.white, fontSize: 18)),
            const Icon(Icons.thermostat, color: Color.fromARGB(255, 0, 171, 231)),
            Text(" $espTemperature °C", style: const TextStyle(color: Colors.white, fontSize: 18))
          ]),
          Row(children: [
            const SizedBox(width: 10),
            const Text("STM temp", style: TextStyle(color: Colors.white, fontSize: 18)),
            const Icon(Icons.thermostat, color: Color.fromARGB(255, 0, 171, 231)),
            Text(" $stmTemperature °C", style: const TextStyle(color: Colors.white, fontSize: 18))
          ]),     
        ],
      )
    );
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

  static void hideBoard() {
    showInfoBoard = false;
  }
}