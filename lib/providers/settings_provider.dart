// lib/providers/settings_provider.dart
//
// Обновлен для полной загрузки/сохранения настроек из/в Firebase,
// включая имя, цели, и обработки состояния загрузки.
//

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/settings_repository.dart'; // Убедись, что путь корректен

class SettingsProvider extends ChangeNotifier {
  final SettingsRepository repo; // Предполагается, что репозиторий инициализируется актуальными данными

  // Локальные копии для быстрого доступа и UI, синхронизируются с repo и Firebase
  String _name = '';
  Map<String, int> _goals = {}; // Инициализируем пустой картой

  // Состояние загрузки
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Дефолтные значения
  static const String _defaultName = '';
  static const Map<String, int> _defaultGoals = {
    'water': 8,
    'steps': 70000,
    'sleep': 8,
  };

  SettingsProvider(this.repo) {
    // При инициализации провайдера загружаем данные из репозитория
    // Репозиторий сам должен позаботиться о загрузке из SharedPreferences
    _name = repo.name;
    _goals = Map.from(repo.goals); // Создаем копию, чтобы избежать прямого изменения
    // Если пользователь уже вошел, можно сразу запустить загрузку из Firebase
    // Это лучше делать из места, где создается провайдер, после проверки auth state
  }

  // ------- getters -------
  String get name => _name;
  Map<String, int> get goals => _goals;


  // --- Метод для загрузки всех настроек пользователя из Firebase ---
  Future<void> loadSettingsFromFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Пользователь не вошел, используем дефолтные значения или из репозитория (уже загружены в конструкторе)
      _name = repo.name; // Или _defaultName, если репозиторий пуст
      _goals = Map.from(repo.goals.isNotEmpty ? repo.goals : _defaultGoals);
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot<Map<String, dynamic>> userSettingsDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userSettingsDoc.exists && userSettingsDoc.data() != null) {
        final data = userSettingsDoc.data()!;
        _name = data['name'] as String? ?? _defaultName;

        final Map<String, dynamic>? goalsData = data['goals'] as Map<String, dynamic>?;
        if (goalsData != null) {
          _goals['water'] = goalsData['water'] as int? ?? _defaultGoals['water']!;
          _goals['steps'] = goalsData['steps'] as int? ?? _defaultGoals['steps']!;
          _goals['sleep'] = goalsData['sleep'] as int? ?? _defaultGoals['sleep']!;
        } else {
          _goals = Map.from(_defaultGoals);
        }
        // TODO: Загрузка темы и языка, если они тоже управляются этим провайдером
        // _themeMode = (data['theme'] == 'dark' ? ThemeMode.dark : ThemeMode.light);
        // _locale = Locale(data['language'] ?? 'en');

        // Обновляем локальный репозиторий
        await repo.setName(_name);
        for (var entry in _goals.entries) {
          await repo.setGoal(entry.key, entry.value);
        }

      } else {
        // Документа нет (новый пользователь или данные не сохранялись)
        // Устанавливаем дефолтные значения и сохраняем их в Firebase и репозиторий
        _name = _defaultName;
        _goals = Map.from(_defaultGoals);
        await _saveAllCurrentSettingsToFirebase(); // Сохраняем дефолты в Firebase
        await repo.setName(_name);
        for (var entry in _goals.entries) {
          await repo.setGoal(entry.key, entry.value);
        }
      }
    } catch (e) {
      print("Error loading settings from Firebase: $e");
      // В случае ошибки можно использовать значения из репозитория или дефолтные
      _name = repo.name.isNotEmpty ? repo.name : _defaultName;
      _goals = Map.from(repo.goals.isNotEmpty ? repo.goals : _defaultGoals);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  // ------- имя -------
  Future<void> updateName(String newName) async {
    _name = newName;
    await repo.setName(newName); // Сохраняем в локальный репозиторий
    notifyListeners(); // Обновляем UI немедленно

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'name': newName}, SetOptions(merge: true));

      // Обновление displayName в FirebaseAuth (опционально, но полезно)
      if (user.displayName != newName) {
        await user.updateDisplayName(newName);
        await user.reload(); // Перезагружаем пользователя, чтобы изменения вступили в силу
      }
    } catch (e) {
      print("Error updating name in Firebase: $e");
      // TODO: Обработка ошибок, возможно откат локального изменения или показ сообщения
    }
  }

  // ------- цели челленджей -------
  Future<void> updateGoal(String id, int value) async {
    // Обновляем локальное состояние
    _goals[id] = value;
    await repo.setGoal(id, value); // Сохраняем в локальный репозиторий
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      // Используем FieldPath для обновления конкретного элемента в карте 'goals'
      // Это безопаснее, чем перезаписывать всю карту `goals` каждый раз
      // Для этого нужно, чтобы поле 'goals' уже существовало как карта в Firestore.
      // Если его нет, то первый раз лучше использовать set с merge:true для всей карты.
      final userDocRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

      // Проверяем, существует ли документ и поле goals
      final docSnapshot = await userDocRef.get();
      if (docSnapshot.exists && docSnapshot.data()?['goals'] is Map) {
        await userDocRef.update({'goals.$id': value});
      } else {
        // Если поля goals нет или оно не карта, создаем/перезаписываем его
        Map<String, int> currentGoalsInFirebase = Map.from(_defaultGoals); // Начнем с дефолтных
        if(docSnapshot.exists && docSnapshot.data()?['goals'] is Map) { // Если карта все же есть, загрузим ее
          currentGoalsInFirebase = Map<String, int>.from(docSnapshot.data()!['goals']);
        }
        currentGoalsInFirebase[id] = value; // Обновляем нужный ключ
        await userDocRef.set({'goals': currentGoalsInFirebase}, SetOptions(merge: true));
      }

    } catch (e) {
      print("Error updating goal '$id' in Firebase: $e");
      // TODO: Обработка ошибок
    }
  }

  // --- Метод для сброса всех настроек к значениям по умолчанию ---
  Future<void> resetSettingsToDefaults() async {
    _name = _defaultName;
    _goals = Map.from(_defaultGoals);

    // Обновляем локальный репозиторий
    await repo.setName(_name);
    for (var entry in _goals.entries) {
      await repo.setGoal(entry.key, entry.value);
    }
    // TODO: Сброс темы и языка, если они здесь управляются

    notifyListeners();

    // Сохраняем сброшенные настройки в Firebase
    await _saveAllCurrentSettingsToFirebase();
  }

  // Вспомогательный метод для сохранения всех текущих локальных настроек в Firebase
  Future<void> _saveAllCurrentSettingsToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'name': _name,
          'goals': _goals,
          // TODO: Сохранение темы и языка, если они здесь управляются
          // 'theme': _themeMode == ThemeMode.dark ? 'dark' : 'light',
          // 'language': _locale.languageCode,
        },
        SetOptions(merge: true), // Используем merge, чтобы не затереть другие поля
      );
    } catch (e) {
      print("Error saving all settings to Firebase: $e");
    }
  }

  // Метод для сброса только целей (если нужен отдельно)
  Future<void> resetGoals() async {
    _goals = Map.from(_defaultGoals);
    for (var entry in _goals.entries) {
      await repo.setGoal(entry.key, entry.value);
    }
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .set({'goals': _goals}, SetOptions(merge: true));
      } catch (e) {
        print("Error resetting goals in Firebase: $e");
      }
    }
  }
}