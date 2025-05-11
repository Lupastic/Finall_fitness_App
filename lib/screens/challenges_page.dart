// lib/screens/challenges_page.dart
//
// Карандаш убран.  В правой части карточки теперь выводится
// сама числовая цель (например 25, 50000, 8).
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/challenge.dart';
import '../providers/settings_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ChallengesPage extends StatelessWidget {
  const ChallengesPage({super.key});

  static const List<Challenge> _defaultChallenges = [
    Challenge(
      id: 'water',
      title: 'Drink 8 cups of water',
      frequency: 'Ежедневно',
      unit: 'стаканов',
      target: 8,
      icon: Icons.local_cafe,
    ),
    Challenge(
      id: 'steps',
      title: 'Walk 70 000 steps',
      frequency: 'Еженедельно',
      unit: 'шагов',
      target: 70000,
      icon: Icons.directions_walk,
    ),
    Challenge(
      id: 'sleep',
      title: 'Sleep 8 hours nightly',
      frequency: 'Еженедельно',
      unit: 'ч',
      target: 8,
      icon: Icons.nights_stay,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(loc.challenges)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<SettingsProvider>(
          builder: (_, prov, __) => ListView.separated(
            itemCount: _defaultChallenges.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final ch = _defaultChallenges[i];
              final goal = prov.goals[ch.id] ?? ch.target;

              return Container(
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Icon(ch.icon, color: Colors.cyanAccent),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ch.title,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 16)),
                          const SizedBox(height: 4),
                          Text(ch.frequency,
                              style: const TextStyle(color: Colors.grey)),
                          const SizedBox(height: 4),
                          Text('$goal ${ch.unit}',
                              style: const TextStyle(
                                  color: Colors.white70)),
                        ],
                      ),
                    ),
                    // === вместо карандаша показываем саму цифру ===
                    Text(
                      '$goal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
