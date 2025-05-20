import 'package:flutter/foundation.dart';
import '../services/network_service.dart';
import '../services/sync_service.dart';

class ConnectivityProvider with ChangeNotifier {
  ConnectivityProvider(this._sync) {
    // подписываемся на поток статусов
    NetworkService.instance.status.listen((offline) async {
      _isOffline = offline;
      notifyListeners();

      // если вернулась сеть → запускаем автосинхронизацию
      if (!offline) await _sync.sync();
    });
  }

  final SyncService _sync;

  bool _isOffline = false;
  bool get isOffline => _isOffline;
}
