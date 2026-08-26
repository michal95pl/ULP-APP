import 'package:flutter/material.dart';
import 'package:mobile_app/utils/app_colors.dart';

class StatisticsAppBar extends StatelessWidget 
implements PreferredSizeWidget {
  final bool isMobileConnected;
  final bool isStageConnected;
  final bool isSynchEnabled;

  const StatisticsAppBar({
    super.key,
    required this.isMobileConnected,
    required this.isStageConnected,
    required this.isSynchEnabled
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  static Column _buildIconWithDescription(IconData iconData, String description, bool status) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          iconData,
          color: status? AppColors.greenStatus : AppColors.redStatus,
          size: 25.0,
        ),
        const SizedBox(height: 4.0),
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

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.cardBackgroundColor,
      automaticallyImplyLeading: false,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(30),
        ),
      ),
      flexibleSpace: SafeArea(
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildIconWithDescription(Icons.sensors, 'conn 1', isMobileConnected),
              const SizedBox(width: 40),
              _buildIconWithDescription(Icons.sensors, 'conn 2', isStageConnected),
              const SizedBox(width: 40),
              _buildIconWithDescription(Icons.lan, 'synch', isSynchEnabled),
            ],
          ),
        ),
      ),
    );
  }
}