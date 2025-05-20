import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

class NetworkIcon extends StatelessWidget {
  const NetworkIcon({super.key});

  @override
  Widget build(BuildContext context) {
    final offline = context.watch<ConnectivityProvider>().isOffline;
    return Icon(
      offline ? Icons.cloud_off : Icons.cloud_done,
      color: offline ? Colors.redAccent : Colors.greenAccent,
      size: 22,
    );
  }
}
