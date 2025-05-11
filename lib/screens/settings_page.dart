// lib/screens/settings_page.dart
//
// Обновлен для работы с асинхронным SettingsProvider,
// сохранения/загрузки имени, состояния загрузки, диалогов подтверждения
// и обновленным _GoalsSheet.
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/settings_provider.dart'; // Убедись, что это обновленный SettingsProvider
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'start_page.dart'; // скорректируйте путь, если нужно

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  // Эта функция сохраняет только тему и язык.
  // Имя и цели сохраняются через SettingsProvider.
  Future<void> _saveDisplaySettingsToFirebase(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final localeProvider = Provider.of<LocaleProvider>(context, listen: false);

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {
          'theme': themeProvider.themeMode == ThemeMode.dark ? 'dark' : 'light',
          'language': localeProvider.locale.languageCode,
        },
        SetOptions(merge: true),
      );
    } catch (e) {
      print("Error saving display settings to Firebase: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save display settings: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final settingsProvider = context.watch<SettingsProvider>();
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.settings)),
      body: SingleChildScrollView( // Добавлено для предотвращения overflow
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          // Тёмная тема
          SwitchListTile(
            title: Text(loc.darkMode),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (v) async {
              themeProvider.toggleTheme(v);
              await _saveDisplaySettingsToFirebase(context);
            },
          ),
          const SizedBox(height: 16),

          // Язык
          DropdownButtonFormField<Locale>(
            value: localeProvider.locale,
            items: const [
              DropdownMenuItem(value: Locale('en'), child: Text('English')),
              DropdownMenuItem(value: Locale('ru'), child: Text('Русский')),
              DropdownMenuItem(value: Locale('kk'), child: Text('Қазақ')),
            ],
            onChanged: (l) async {
              if (l == null) return;
              localeProvider.setLocale(l);
              await _saveDisplaySettingsToFirebase(context);
            },
            decoration: InputDecoration(
              labelText: loc.language,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),

          // Имя
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(loc.name),
            subtitle: settingsProvider.isLoading
                ? const SizedBox(height: 10, width: 100, child: LinearProgressIndicator())
                : Text(settingsProvider.name.isEmpty ? (loc.nameNotSet ?? 'Name not set') : settingsProvider.name),
            onTap: () async {
              final ctrl = TextEditingController(text: settingsProvider.name);
              final res = await showDialog<String>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(loc.enterName),
                  content: TextField(
                    controller: ctrl,
                    autofocus: true,
                    decoration: InputDecoration(hintText: loc.name),
                  ),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(ctx),
                        child: Text(loc.cancel)),
                    ElevatedButton(
                        onPressed: () =>
                            Navigator.pop(ctx, ctrl.text.trim()),
                        child: Text(loc.save)),
                  ],
                ),
              );
              if (res != null) { // Разрешаем сохранять пустое имя
                await settingsProvider.updateName(res);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.nameUpdated ?? 'Name updated!')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),

          // Уведомления
          SwitchListTile(
            title: Text(loc.notifications),
            value: themeProvider.areNotificationsEnabled, // Предполагаем, что это в ThemeProvider
            onChanged: (value) {
              themeProvider.toggleNotifications(value);
              // Опционально: сохранение в Firebase
              // final user = FirebaseAuth.instance.currentUser;
              // if (user != null) {
              //   FirebaseFirestore.instance.collection('users').doc(user.uid).set(
              //     {'notificationsEnabled': value}, SetOptions(merge: true));
              // }
            },
          ),
          const SizedBox(height: 16),

          // ==== ЧЕЛЛЕНДЖ ЦЕЛИ ====
          ListTile(
            leading: const Icon(Icons.flag),
            title: Text(loc.challenges),
            subtitle: Text(loc.editGoals),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent, // Делаем фон прозрачным для кастомной формы
              builder: (_) => const _GoalsSheet(),
            ),
          ),
          const SizedBox(height: 16),
          // =======================

          // Сброс
          ListTile(
            leading: const Icon(Icons.restore),
            title: Text(loc.resetSettings),
            onTap: () async {
              final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(loc.resetSettings),
                    content: Text(loc.confirmResetSettings ?? 'Are you sure you want to reset settings?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(loc.cancel)),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text(loc.reset ?? 'Reset'),
                      ),
                    ],
                  )
              );

              if (confirm == true) {
                // Сброс темы и языка через их провайдеры (они сами могут сохранять в Firebase при сбросе, если так настроены)
                Provider.of<ThemeProvider>(context, listen: false).resetSettings();
                Provider.of<LocaleProvider>(context, listen: false).setLocale(const Locale('en')); // или дефолтный

                // Сброс остальных настроек через SettingsProvider
                await settingsProvider.resetSettingsToDefaults();

                // Явно сохраняем дефолтные тему и язык в Firebase после сброса
                // (если resetSettings в Theme/LocaleProvider этого не делают)
                await _saveDisplaySettingsToFirebase(context);

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(loc.settingsReset ?? 'Settings reset!')),
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),

          // Версия
          ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(loc.version),
              subtitle: const Text('1.0.0')),
          const SizedBox(height: 24),

          // Выход
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: Text(loc.logout),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50)
            ),
            onPressed: () async {
              final confirmLogout = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: Text(loc.logout),
                    content: Text(loc.confirmLogout ?? 'Are you sure you want to log out?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(ctx, false),
                          child: Text(loc.cancel)),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
                        child: Text(loc.logout),
                      ),
                    ],
                  )
              );

              if (confirmLogout == true) {
                await FirebaseAuth.instance.signOut();
                // Опционально: сброс локального состояния провайдеров до дефолтного
                // Provider.of<SettingsProvider>(context, listen: false).resetToLocalDefaults(); // Нужен такой метод
                if (context.mounted) {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const StartPage()),
                        (_) => false,
                  );
                }
              }
            },
          ),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
//                          Bottom‑sheet для целей
// ---------------------------------------------------------------------------
class _GoalsSheet extends StatefulWidget {
  const _GoalsSheet();

  @override
  State<_GoalsSheet> createState() => _GoalsSheetState();
}

class _GoalsSheetState extends State<_GoalsSheet> {
  // Дефолтные значения, если они не загружены из SettingsProvider
  static const _defaultWater = 8;
  static const _defaultSteps = 70000;
  static const _defaultSleep = 8;

  late TextEditingController _waterCtrl;
  late TextEditingController _stepsCtrl;
  late TextEditingController _sleepCtrl;

  @override
  void initState() {
    super.initState();
    final goals = context.read<SettingsProvider>().goals;
    _waterCtrl = TextEditingController(text: (goals['water'] ?? _defaultWater).toString());
    _stepsCtrl = TextEditingController(text: (goals['steps'] ?? _defaultSteps).toString());
    _sleepCtrl = TextEditingController(text: (goals['sleep'] ?? _defaultSleep).toString());
  }

  @override
  void dispose() {
    _waterCtrl.dispose();
    _stepsCtrl.dispose();
    _sleepCtrl.dispose();
    super.dispose();
  }

  Widget _buildGoalRow({
    required AppLocalizations loc,
    required String goalKey,
    required TextEditingController controller,
    required String Function(String count) titleBuilder, // e.g. (c) => loc.goalWaterTitle(c)
    required String unitText, // e.g. loc.waterUnit
  }) {
    return ListTile(
      title: Text(titleBuilder(controller.text)),
      trailing: SizedBox(
        width: 90,
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            hintText: unitText,
          ),
          onChanged: (_) => setState(() {}), // Update title dynamically
        ),
      ),
    );
  }

  Future<void> _saveGoals() async {
    final settingsProvider = context.read<SettingsProvider>();
    final loc = AppLocalizations.of(context)!;
    bool changed = false;

    // Helper to update a single goal
    Future<bool> updateSingleGoal(String key, TextEditingController ctrl, int defaultValue) async {
      final val = int.tryParse(ctrl.text);
      final currentGoalValue = settingsProvider.goals[key] ?? defaultValue;
      if (val != null && val > 0 && val != currentGoalValue) {
        await settingsProvider.updateGoal(key, val);
        return true;
      } else if (val == null || val <= 0) {
        ctrl.text = currentGoalValue.toString(); // Restore if invalid
      }
      return false;
    }

    if (await updateSingleGoal('water', _waterCtrl, _defaultWater)) changed = true;
    if (await updateSingleGoal('steps', _stepsCtrl, _defaultSteps)) changed = true;
    if (await updateSingleGoal('sleep', _sleepCtrl, _defaultSleep)) changed = true;

    setState(() {}); // To reflect restored values if any

    if (mounted) {
      if (changed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(loc.goalsUpdated ?? 'Goals updated!'), backgroundColor: Colors.green),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    // Используем context.watch если хотим чтобы UI здесь обновлялся при изменении goals в провайдере.
    // Но т.к. контроллеры инициализируются в initState, прямое обновление может не понадобиться,
    // если только цели не меняются из другого места пока этот sheet открыт.
    // final settingsProvider = context.watch<SettingsProvider>();


    // Используем Material для задания формы и цвета фона
    return Material(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      color: Theme.of(context).bottomSheetTheme.backgroundColor ?? Theme.of(context).scaffoldBackgroundColor,
      child: Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, top: 8,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                    color: Colors.grey[400], borderRadius: BorderRadius.circular(2)),
              ),
            ),
            Text(
              loc.editGoals,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildGoalRow(
              loc: loc,
              goalKey: 'water',
              controller: _waterCtrl,
              titleBuilder: (c) => loc.goalWaterTitle.call(c) ?? 'Water: $c',
              unitText: loc.waterUnit ?? 'glasses',
            ),
            _buildGoalRow(
              loc: loc,
              goalKey: 'steps',
              controller: _stepsCtrl,
              titleBuilder: (c) => loc.goalStepsTitle.call(c) ?? 'Steps: $c',
              unitText: loc.stepsUnit ?? 'steps',
            ),
            _buildGoalRow(
              loc: loc,
              goalKey: 'sleep',
              controller: _sleepCtrl,
              titleBuilder: (c) => loc.goalSleepTitle.call(c) ?? 'Sleep: $c',
              unitText: loc.sleepUnit ?? 'hours',
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveGoals,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              child: Text(loc.save),
            ),
          ],
        ),
      ),
    );
  }
}