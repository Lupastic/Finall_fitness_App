import 'package:flutter/foundation.dart';
import '../services/local_repository.dart';
import '../models/daily_summary.dart';

class SummaryProvider with ChangeNotifier {
  final LocalRepository _repo;
  late DailySummary _today;

  SummaryProvider(this._repo) {
    _today = _repo.getToday() ??
        DailySummary(date: DateTime.now(),
            waterCups: 0, sleepHours: 0,
            calories: 0, steps: 0);
  }

  DailySummary get today => _today;

  void update({int? water, double? sleep, int? cal, int? steps}) {
    _today = DailySummary(
      date: _today.date,
      waterCups: water ?? _today.waterCups,
      sleepHours: sleep ?? _today.sleepHours,
      calories: cal ?? _today.calories,
      steps: steps ?? _today.steps,
      synced: false,
    );
    _repo.save(_today);
    notifyListeners();
  }

  void markSynced() {
    _today.synced = true;
    _repo.save(_today);
    notifyListeners();
  }
}
