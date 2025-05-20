import 'dart:async';
import 'package:flutter/foundation.dart';                 // ← для debugPrint
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';

class NetworkService {
  NetworkService._() {
    // реагируем на смену подключения (Wi-Fi / Cellular / Wired / None)
    _conn.onConnectivityChanged.listen((result) async {
      debugPrint('CONNECTIVITY_CHANGED → $result');       // ← лог №1
      await _check();
    });

    // периодический DNS-пинг (актуально для Windows/macOS)
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _check());

    // начальная проверка сразу после запуска
    _check();
  }

  static final NetworkService instance = NetworkService._();

  final _controller = StreamController<bool>.broadcast();
  Stream<bool> get status => _controller.stream;

  final _conn = Connectivity();
  late final Timer _timer;

  Future<void> _check() async {
    final hasNet = await InternetConnectionChecker().hasConnection;
    debugPrint('CHECK → hasNet=$hasNet');                 // ← лог №2
    _controller.add(!hasNet);                             // true = OFFLINE
  }
}
