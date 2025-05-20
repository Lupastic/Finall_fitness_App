import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/challenge.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart'; // Импортируйте ThemeProvider
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  static const List<Challenge> _challenges = [
    // Basic + advanced challenges
    Challenge(id: 'water', title: 'Drink 8 cups of water', frequency: 'Ежедневно', unit: 'стаканов', target: 8, icon: Icons.local_cafe),
    Challenge(id: 'steps', title: 'Walk 70,000 steps', frequency: 'Еженедельно', unit: 'шагов', target: 70000, icon: Icons.directions_walk),
    Challenge(id: 'sleep', title: 'Sleep 8 hours nightly', frequency: 'Ежедневно', unit: 'ч', target: 8, icon: Icons.nights_stay),
    Challenge(id: 'yoga', title: 'Do Yoga', frequency: 'Еженедельно', unit: 'сессий', target: 3, icon: Icons.self_improvement),
    Challenge(id: 'plank', title: 'Hold Plank', frequency: 'Ежедневно', unit: 'минут', target: 5, icon: Icons.accessibility_new),
    Challenge(id: 'running', title: 'Run', frequency: 'Еженедельно', unit: 'км', target: 15, icon: Icons.directions_run),
    Challenge(id: 'meditate', title: 'Meditate', frequency: 'Ежедневно', unit: 'минут', target: 10, icon: Icons.spa),
    Challenge(id: 'sugar', title: 'Sugar-free Days', frequency: 'Еженедельно', unit: 'дней', target: 5, icon: Icons.no_food),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : const Color(0xFFF0F4F8),
      appBar: AppBar(
        title: Text(
          loc.challenges,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.indigoAccent.shade100 : Colors.indigo.shade900,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<SettingsProvider>(
          builder: (_, prov, __) => ListView.separated(
            itemCount: _challenges.length,
            separatorBuilder: (_, __) => const SizedBox(height: 20),
            itemBuilder: (ctx, i) {
              final ch = _challenges[i];
              final goal = prov.goals[ch.id] ?? ch.target;

              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  color: isDarkMode ? Colors.grey.shade800 : Colors.white.withOpacity(0.7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: const Offset(4, 4),
                    )
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [Colors.indigo.shade400, Colors.purpleAccent],
                          ),
                        ),
                        child: Icon(ch.icon, color: Colors.white, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ch.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: isDarkMode ? Colors.white : Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              ch.frequency,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey.shade400 : Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$goal ${ch.unit}',
                              style: TextStyle(
                                fontSize: 14,
                                color: isDarkMode ? Colors.grey.shade500 : Colors.black45,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '$goal',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurpleAccent,
                            ),
                          ),
                          Text(
                            ch.unit,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode ? Colors.grey.shade400 : Colors.black54,
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}