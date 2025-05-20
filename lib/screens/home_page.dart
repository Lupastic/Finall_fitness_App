// Redesigned HomePage with Dark Mode Support and Modern UI
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../providers/connectivity_provider.dart';
import '../providers/summary_provider.dart';
import '../services/sync_service.dart';
import '../widgets/network_icon.dart';
import '../widgets/offline_banner.dart';

////////////////////////////////////////////////////////////////////////////////
// ANIMATED ICONS
////////////////////////////////////////////////////////////////////////////////

class AnimatedFlame extends StatefulWidget {
  final bool active;
  const AnimatedFlame({super.key, required this.active});
  @override
  State<AnimatedFlame> createState() => _AnimatedFlameState();
}

class _AnimatedFlameState extends State<AnimatedFlame> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _a = Tween<double>(begin: 0.95, end: 1.05).animate(_c);
    _maybeStart();
  }

  void _maybeStart() {
    if (widget.active) {
      _c.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _c.stop();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedFlame old) {
    super.didUpdateWidget(old);
    if (!old.active && widget.active) _maybeStart();
    if (old.active && !widget.active) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) => AnimatedBuilder(
    animation: _a,
    child: const Icon(Icons.local_fire_department, color: Colors.deepOrangeAccent, size: 32),
    builder: (_, child) => Transform.scale(scale: _a.value, child: child),
  );
}

class AnimatedWater extends StatefulWidget {
  final bool active;
  const AnimatedWater({super.key, required this.active});
  @override
  State<AnimatedWater> createState() => _AnimatedWaterState();
}

class _AnimatedWaterState extends State<AnimatedWater> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 1));
    _a = Tween<double>(begin: 0, end: 5).animate(_c);
    _maybeStart();
  }

  void _maybeStart() {
    if (widget.active) {
      _c.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _c.stop();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedWater old) {
    super.didUpdateWidget(old);
    if (!old.active && widget.active) _maybeStart();
    if (old.active && !widget.active) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) => AnimatedBuilder(
    animation: _a,
    child: const Icon(Icons.local_drink, color: Colors.cyanAccent, size: 32),
    builder: (_, child) => Transform.translate(offset: Offset(0, _a.value), child: child),
  );
}

class AnimatedMoon extends StatefulWidget {
  final bool active;
  const AnimatedMoon({super.key, required this.active});
  @override
  State<AnimatedMoon> createState() => _AnimatedMoonState();
}

class _AnimatedMoonState extends State<AnimatedMoon> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _a;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _a = Tween<double>(begin: -30, end: 30).animate(_c);
    _maybeStart();
  }

  void _maybeStart() {
    if (widget.active) {
      _c.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _c.stop();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedMoon old) {
    super.didUpdateWidget(old);
    if (!old.active && widget.active) _maybeStart();
    if (old.active && !widget.active) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) => AnimatedBuilder(
    animation: _a,
    child: const Icon(Icons.bedtime, color: Colors.deepPurpleAccent, size: 32),
    builder: (_, child) => Transform.translate(offset: Offset(_a.value, 0), child: child),
  );
}

class AnimatedPerson extends StatefulWidget {
  final bool active;
  const AnimatedPerson({super.key, required this.active});
  @override
  State<AnimatedPerson> createState() => _AnimatedPersonState();
}

class _AnimatedPersonState extends State<AnimatedPerson> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _dx, _scale;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _dx = Tween<double>(begin: -2, end: 2).animate(_c);
    _scale = Tween<double>(begin: 0.98, end: 1.02).animate(_c);
    _maybeStart();
  }

  void _maybeStart() {
    if (widget.active) {
      _c.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _c.stop();
      });
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedPerson old) {
    super.didUpdateWidget(old);
    if (!old.active && widget.active) _maybeStart();
    if (old.active && !widget.active) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext _) => AnimatedBuilder(
    animation: _c,
    child: const Icon(Icons.directions_walk, color: Colors.cyanAccent, size: 32),
    builder: (_, child) => Transform.translate(
      offset: Offset(_dx.value, 0),
      child: Transform.scale(scale: _scale.value, child: child),
    ),
  );
}

////////////////////////////////////////////////////////////////////////////////
// MAIN SCREEN (HomePage)
////////////////////////////////////////////////////////////////////////////////

class HomePage extends StatelessWidget {
  final bool active;
  const HomePage({super.key, required this.active});

  Widget summaryCard(Widget icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1F1F1F),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            icon,
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontSize: 16, color: Colors.white)),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final offline = context.watch<ConnectivityProvider>().isOffline;
    final summary = context.watch<SummaryProvider>().today;
    final syncServ = context.read<SyncService>();

    return SafeArea(
      child: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      const CircleAvatar(radius: 28, backgroundImage: AssetImage('assets/user.png')),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Доброе утро,", style: TextStyle(color: Colors.white70, fontSize: 16)),
                          Consumer<SettingsProvider>(
                            builder: (_, p, __) => Text(
                              "${p.name.isEmpty ? 'Алекс' : p.name}!",
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      const NetworkIcon(),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Summary
                  const Text("Дневная сводка", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    summaryCard(AnimatedWater(active: active), "${summary.waterCups}/8", "стаканов"),
                    summaryCard(AnimatedMoon(active: active), "${summary.sleepHours.toStringAsFixed(1)} ч", "/ 8 ч"),
                  ]),
                  Row(children: [
                    summaryCard(AnimatedFlame(active: active), "${summary.calories}", "/ 2200 ккал"),
                    summaryCard(AnimatedPerson(active: active), "${summary.steps}", "10 000 шагов"),
                  ]),
                  Row(children: [
                    summaryCard(const Icon(Icons.self_improvement, color: Colors.orangeAccent, size: 32), "${summary.yogaSessions}", "йога-сессий"),
                    summaryCard(const Icon(Icons.accessibility_new, color: Colors.pinkAccent, size: 32), "${summary.plankMinutes} мин", "планка"),
                  ]),
                  Row(children: [
                    summaryCard(const Icon(Icons.directions_run, color: Colors.lightGreenAccent, size: 32), "${summary.runningKm} км", "пробежка"),
                    summaryCard(const Icon(Icons.spa, color: Colors.lightBlueAccent, size: 32), "${summary.meditationMinutes} мин", "медитация"),
                  ]),
                  Row(children: [
                    summaryCard(const Icon(Icons.no_food, color: Colors.redAccent, size: 32), "${summary.sugarFreeDays}", "без сахара"),
                  ]),

                  const SizedBox(height: 16),

                  // Analytics Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[800],
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: offline ? null : () {/* TODO: show analytics */},
                    child: Text(offline ? 'Нет интернета' : 'Показать аналитику'),
                  ),
                  const SizedBox(height: 12),

                  // Sync Button
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    onPressed: offline ? null : () async => await syncServ.sync(),
                    child: Text(offline ? 'Оффлайн' : 'Синхронизировать', style: const TextStyle(color: Colors.white)),
                  ),

                  const SizedBox(height: 24),

                  // Challenge Section
                  const Text("Челлендж", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F1F1F),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.military_tech, color: Colors.deepPurpleAccent, size: 32),
                        SizedBox(width: 12),
                        Expanded(child: Text("Идёшь 7 дней подряд — получи медаль!", style: TextStyle(fontSize: 16))),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
