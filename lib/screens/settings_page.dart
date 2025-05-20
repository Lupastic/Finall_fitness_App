import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../providers/theme_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/settings_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'start_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          SwitchListTile(
            title: Text(loc.darkMode),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (v) async {
              themeProvider.toggleTheme(v);
              await _saveDisplaySettingsToFirebase(context);
            },
          ),
          const SizedBox(height: 16),
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
          ListTile(
            leading: const Icon(Icons.person),
            title: Text(loc.name),
            subtitle: settingsProvider.isLoading
                ? const LinearProgressIndicator()
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
                    TextButton(onPressed: () => Navigator.pop(ctx), child: Text(loc.cancel)),
                    ElevatedButton(onPressed: () => Navigator.pop(ctx, ctrl.text.trim()), child: Text(loc.save)),
                  ],
                ),
              );
              if (res != null) {
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
          SwitchListTile(
            title: Text(loc.notifications),
            value: themeProvider.areNotificationsEnabled,
            onChanged: (value) {
              themeProvider.toggleNotifications(value);
            },
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.flag),
            title: Text(loc.challenges),
            subtitle: Text(loc.editGoals),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const _GoalsSheet(),
            ),
          ),
          const SizedBox(height: 16),
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
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.cancel)),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(loc.reset ?? 'Reset'),
                    ),
                  ],
                ),
              );

              if (confirm == true) {
                Provider.of<ThemeProvider>(context, listen: false).resetSettings();
                Provider.of<LocaleProvider>(context, listen: false).setLocale(const Locale('en'));
                await settingsProvider.resetSettingsToDefaults();
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
          ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(loc.version),
              subtitle: const Text('1.0.0')),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: Text(loc.logout),
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50)),
            onPressed: () async {
              final confirmLogout = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text(loc.logout),
                  content: Text(loc.confirmLogout ?? 'Are you sure you want to log out?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(loc.cancel)),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: Text(loc.logout),
                    ),
                  ],
                ),
              );

              if (confirmLogout == true) {
                await FirebaseAuth.instance.signOut();
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
  static const _defaults = {
    'water': 8,
    'steps': 70000,
    'sleep': 8,
    'yoga': 3,
    'plank': 5,
    'running': 15,
    'meditate': 10,
    'sugar': 5,
  };

  final Map<String, TextEditingController> _controllers = {};

  @override
  void initState() {
    super.initState();
    final goals = context.read<SettingsProvider>().goals;
    for (var key in _defaults.keys) {
      _controllers[key] = TextEditingController(
        text: (goals[key] ?? _defaults[key]).toString(),
      );
    }
  }

  @override
  void dispose() {
    for (var ctrl in _controllers.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Widget _buildGoalRow({
    required String title,
    required String key,
    required String unit,
  }) {
    final ctrl = _controllers[key]!;
    return ListTile(
      title: Text("$title (${ctrl.text} $unit)"),
      trailing: SizedBox(
        width: 90,
        child: TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            isDense: true,
            border: const OutlineInputBorder(),
            hintText: unit,
          ),
          onChanged: (_) => setState(() {}),
        ),
      ),
    );
  }

  Future<void> _saveGoals() async {
    final settingsProvider = context.read<SettingsProvider>();
    bool changed = false;

    for (var entry in _controllers.entries) {
      final val = int.tryParse(entry.value.text);
      final current = settingsProvider.goals[entry.key] ?? _defaults[entry.key]!;
      if (val != null && val > 0 && val != current) {
        await settingsProvider.updateGoal(entry.key, val);
        changed = true;
      } else if (val == null || val <= 0) {
        entry.value.text = current.toString();
      }
    }

    if (mounted) {
      if (changed) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Goals updated!"), backgroundColor: Colors.green),
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  color: Colors.grey[400],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              AppLocalizations.of(context)!.editGoals,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            _buildGoalRow(title: 'Water', key: 'water', unit: 'стаканов'),
            _buildGoalRow(title: 'Steps', key: 'steps', unit: 'шагов'),
            _buildGoalRow(title: 'Sleep', key: 'sleep', unit: 'ч'),
            _buildGoalRow(title: 'Yoga', key: 'yoga', unit: 'сессий'),
            _buildGoalRow(title: 'Plank', key: 'plank', unit: 'минут'),
            _buildGoalRow(title: 'Running', key: 'running', unit: 'км'),
            _buildGoalRow(title: 'Meditation', key: 'meditate', unit: 'минут'),
            _buildGoalRow(title: 'Sugar-Free Days', key: 'sugar', unit: 'дней'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _saveGoals,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 12)),
              child: Text(AppLocalizations.of(context)!.save),
            ),
          ],
        ),
      ),
    );
  }
}
