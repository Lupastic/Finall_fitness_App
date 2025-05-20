import 'package:hive/hive.dart';
import '../models/daily_summary.dart';

class LocalRepository {
  static const _boxName = 'dailyBox';
  late final Box<DailySummary> _box;

  Future<void> init() async {
    _box = await Hive.openBox<DailySummary>(_boxName);
  }

  DailySummary? getToday() {
    final key = _dateKey(DateTime.now());
    return _box.get(key);
  }

  Future<void> save(DailySummary summary) async =>
      _box.put(_dateKey(summary.date), summary);

  List<DailySummary> unsynced() =>
      _box.values.where((e) => !e.synced).toList();

  String _dateKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
