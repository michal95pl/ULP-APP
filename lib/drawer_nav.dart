import 'package:flutter/material.dart';

class DrawerNav
{
  /// Returns a panel with icon and name of page that is used for navigation in the drawer.
  static ListTile _pageNavigatorTile(IconData icon, String title, String route, BuildContext context) {

    bool isActuallyUsed = ModalRoute.of(context)!.settings.name == route;

    return ListTile(
      leading: Icon(icon,
          color: isActuallyUsed? const Color.fromARGB(255, 149, 61, 255) : const Color.fromARGB(255, 189, 189, 189)
        ),
      title: Text(title,
        style: TextStyle(
          color: isActuallyUsed? const Color.fromARGB(255, 149, 61, 255) : const Color.fromARGB(255, 189, 189, 189)
          )
        ),
      onTap: !isActuallyUsed? () {
          Navigator.pop(context);
          Navigator.pushReplacementNamed(context, route);
        } : null,
    );
  }

   static Widget getDrawerNav(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        height: 370,
        width: 180,
        child: Drawer(
          backgroundColor: const Color.fromARGB(255, 28, 28, 28).withOpacity(0.77), // Set the background color with opacity
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
          ),
          child: ListView(
            padding: EdgeInsets.zero, // Set padding to zero
            children: <Widget>[
              Container(
                height: 150, // Adjust the height as needed
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/drawer.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              _pageNavigatorTile(Icons.texture, "led strip", "/led_strip", context),
              _pageNavigatorTile(Icons.settings, "settings", "/settings", context),
            ],
          ),
        ),
      ),
    );
  }
}