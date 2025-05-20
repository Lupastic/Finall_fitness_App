import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/local_repository.dart';
import '../models/daily_summary.dart';

class SyncService {
  final LocalRepository _repo;
  final _fire = FirebaseFirestore.instance;

  SyncService(this._repo);

  Future<void> sync() async {
    final items = _repo.unsynced();
    for (final d in items) {
      await _fire
          .collection('users')   // 1‑й уровень
          .doc('demo')           // TODO: uid
          .collection('summaries')
          .doc(d.date.toIso8601String())
          .set({
        'water': d.waterCups,
        'sleep': d.sleepHours,
        'cal': d.calories,
        'steps': d.steps,
        'ts': FieldValue.serverTimestamp(),
      });
      d.synced = true;
      await d.save();
    }
  }
}
