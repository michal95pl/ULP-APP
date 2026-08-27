import 'package:flutter/material.dart';
import 'package:mobile_app/utils/app_colors.dart';

enum ConnectionStatus {disconnected, connecting, connected}

class ConnectionButton extends StatelessWidget {
  final ConnectionStatus status;
  final VoidCallback? onConnectPressed;
  final VoidCallback? onDisconnectPressed;

  const ConnectionButton({
    super.key,
    required this.status,
    this.onConnectPressed,
    this.onDisconnectPressed,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case ConnectionStatus.connecting:
        return FilledButton(
          onPressed: null,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(AppColors.buttonColor),
          ),
          child: const Text('Connecting...')
        );

      case ConnectionStatus.connected:
        return FilledButton(
        onPressed: onDisconnectPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(AppColors.buttonColor),
          ),
          child: const Text('Disconnect')
        );

      case ConnectionStatus.disconnected:
        return FilledButton(
          onPressed: onConnectPressed,
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all<Color>(AppColors.buttonColor),
          ),
          child: const Text('Connect'),
        );
    }
  }
}