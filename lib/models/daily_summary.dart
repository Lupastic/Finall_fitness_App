import 'package:hive/hive.dart';
part 'daily_summary.g.dart';

@HiveType(typeId: 1)
class DailySummary extends HiveObject {
  @HiveField(0) DateTime date;       // ключ «день»
  @HiveField(1) int waterCups;       // 0–8
  @HiveField(2) double sleepHours;   // 0–24
  @HiveField(3) int calories;        // 0+
  @HiveField(4) int steps;           // 0+
  @HiveField(5) bool synced;         // ← ещё не выгружено в Firebase

  @HiveField(6) int yogaSessions;        // 0+
  @HiveField(7) int plankMinutes;        // 0+
  @HiveField(8) double runningKm;        // 0+
  @HiveField(9) int meditationMinutes;   // 0+
  @HiveField(10) int sugarFreeDays;      // 0+

  DailySummary({
    required this.date,
    required this.waterCups,
    required this.sleepHours,
    required this.calories,
    required this.steps,
    this.synced = false,
    this.yogaSessions = 0,
    this.plankMinutes = 0,
    this.runningKm = 0.0,
    this.meditationMinutes = 0,
    this.sugarFreeDays = 0,
  });
}
