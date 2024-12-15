import 'package:flutter/material.dart';

class StatisticsBar
{
  static final List<bool> _connections = [false, false];
  static bool _synch = false;
  static bool _pd = false;

  static Column _iconWithDescription(IconData iconData, String description, bool status) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: 30.0),
        Icon(
          iconData,
          color: status? Colors.greenAccent : Colors.pink,
          size: 25.0,
        ),
        Text(
          description,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14.0,
          ),
        )
      ],
    );
  }

  static AppBar getAppBar()
  {
    debugPrint("[StatisticsBar] getAppBar invoke: $_connections, synch: $_synch, pd: $_pd");
    return AppBar(
      backgroundColor: const Color.fromARGB(255, 28, 28, 28),
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      flexibleSpace: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _iconWithDescription(Icons.sensors, 'conn 1', _connections[0]),
          const SizedBox(width: 40),
          _iconWithDescription(Icons.sensors, 'conn 2', _connections[1]),
          const SizedBox(width: 40),
          _iconWithDescription(Icons.lan, 'synch', _synch),
          const SizedBox(width: 40),
          _iconWithDescription(Icons.bolt, 'PD', _pd),
        ],
      ),
      )
    );
  }

  static void setMobileConnectionStatus(bool status) {
    _connections[0] = status;
  }

  static void setStationaryConnectionStatus(bool status) {
    _connections[1] = status;
  }

  static set synch(bool synch) {
    _synch = synch;
  }

  static set pd(bool pd) {
    _pd = pd;
  }
}