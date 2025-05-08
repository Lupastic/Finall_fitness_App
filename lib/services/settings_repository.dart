import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsRepository {
  static const _kNameKey = 'userName';
  static const _kGoalsKey = 'goals';           // {"water":8,"steps":10000}

  final SharedPreferences prefs;
  SettingsRepository(this.prefs);

  String get name => prefs.getString(_kNameKey) ?? 'Гость';
  Future<void> setName(String v) => prefs.setString(_kNameKey, v);

  Map<String,int> get goals =>
      (json.decode(prefs.getString(_kGoalsKey) ?? '{}') as Map).cast<String,int>();

  Future<void> setGoal(String id, int val) {
    final g = goals..[id] = val;
    return prefs.setString(_kGoalsKey, json.encode(g));
  }
}
