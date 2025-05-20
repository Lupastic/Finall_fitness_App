import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final offline = context.watch<ConnectivityProvider>().isOffline;
    if (!offline) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      color: Colors.red,
      padding: const EdgeInsets.all(4),
      child: const Center(
        child: Text(
          'Нет соединения с интернетом',
          style: TextStyle(color: Colors.white, fontSize: 12),
        ),
      ),
    );
  }
}
