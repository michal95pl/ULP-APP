import 'package:flutter/material.dart';
import 'package:mobile_app/utils/app_colors.dart';
import 'package:mobile_app/utils/app_routes.dart';

class _RoutableNavItem extends BottomNavigationBarItem {
  final String route;
  _RoutableNavItem({required this.route, required super.icon, required super.label});
}

class BottomNav extends StatelessWidget
{
  final String currentRoute;

  final bool isMobileConnected;
  final bool isStageConnected;
  const BottomNav({super.key, required this.currentRoute, required this.isMobileConnected, required this.isStageConnected});

  @override
  Widget build(BuildContext context) {

    final List<_RoutableNavItem> routableNavItems = [
      if (isMobileConnected)
        _RoutableNavItem(
          route: AppRoutes.wearableDisplay,
          icon: Icon(Icons.apps),
          label: 'Display',
        ),

      if (isMobileConnected)
      _RoutableNavItem(
        route: AppRoutes.wearableLed,
        icon: Icon(Icons.accessibility_new),
        label: 'Wearable',
      ),

      if (isStageConnected)
        _RoutableNavItem(
          route: AppRoutes.stageLed,
          icon: Icon(Icons.tungsten),
          label: 'Stage',
        ),

      _RoutableNavItem(
        route: AppRoutes.settings,
        icon: Icon(Icons.settings),
        label: 'Settings',
      ),
    ];

    if (routableNavItems.length < 2) {
      return const SizedBox.shrink();
    }

    int currentIndex = routableNavItems.indexWhere((item) => item.route == currentRoute);
    if (currentIndex == -1) currentIndex = routableNavItems.length - 1;

    return Container(
      height: 70,
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 30),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Theme(
            data: Theme.of(context).copyWith(
              splashColor: Colors.black,
              highlightColor: Colors.black,
            ),
            child: BottomNavigationBar(
              elevation: 0,
              backgroundColor: AppColors.cardBackgroundColor,
              selectedItemColor: AppColors.navBarActiveColor,
              unselectedItemColor: AppColors.navBarInactiveColor,
              currentIndex: currentIndex,
              type: BottomNavigationBarType.fixed,
              selectedFontSize: 12,
              unselectedFontSize: 12,
              items: routableNavItems,
              onTap: (index) {
                if (index == currentIndex) return;
                Navigator.pushReplacementNamed(context, routableNavItems[index].route);
              },
            ),
          ),
        ),
      ),
    );
  }
}