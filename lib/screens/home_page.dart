// lib/screens/home_page.dart
//
// ДИЗАЙН НЕ ИЗМЕНЁН.  Добавлено только динамическое имя
// через SettingsProvider + импорты provider.
// ИСПРАВЛЕНО ПЕРЕПОЛНЕНИЕ ЭКРАНА (BOTTOM OVERFLOW)
//

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';               // ← новый импорт
import '../providers/settings_provider.dart';          // ← новый импорт

class AnimatedFlame extends StatefulWidget {
  final bool active;
  const AnimatedFlame({super.key, required this.active});
  @override
  _AnimatedFlameState createState() => _AnimatedFlameState();
}

class _AnimatedFlameState extends State<AnimatedFlame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _anim = Tween<double>(begin: 0.95, end: 1.05).animate(_ctrl);
    if (widget.active) {
      _ctrl.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _ctrl.stop();
      });
    }
  }
  @override
  void didUpdateWidget(covariant AnimatedFlame old) {
    super.didUpdateWidget(old);
    if (!old.active && widget.active) {
      _ctrl.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _ctrl.stop();
      });
    }
    if (old.active && !widget.active) _ctrl.stop();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      child: const Icon(Icons.local_fire_department,
          color: Colors.deepOrangeAccent, size: 32),
      builder: (_, child) => Transform.scale(scale: _anim.value, child: child),
    );
  }
}

class AnimatedWater extends StatefulWidget {
  final bool active;
  const AnimatedWater({super.key, required this.active});
  @override
  _AnimatedWaterState createState() => _AnimatedWaterState();
}

class _AnimatedWaterState extends State<AnimatedWater>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _anim = Tween<double>(begin: 0, end: 5).animate(_ctrl);
    if (widget.active) {
      _ctrl.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _ctrl.stop();
      });
    }
  }
  @override
  void didUpdateWidget(covariant AnimatedWater old) {
    super.didUpdateWidget(old);
    if (!old.active && widget.active) {
      _ctrl.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _ctrl.stop();
      });
    }
    if (old.active && !widget.active) _ctrl.stop();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      child: const Icon(Icons.local_drink,
          color: Colors.cyanAccent, size: 32),
      builder: (_, child) =>
          Transform.translate(offset: Offset(0, _anim.value), child: child),
    );
  }
}

class AnimatedMoon extends StatefulWidget {
  final bool active;
  const AnimatedMoon({super.key, required this.active});
  @override
  _AnimatedMoonState createState() => _AnimatedMoonState();
}

class _AnimatedMoonState extends State<AnimatedMoon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _anim = Tween<double>(begin: -30, end: 30).animate(_ctrl);
    if (widget.active) {
      _ctrl.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _ctrl.stop();
      });
    }
  }
  @override
  void didUpdateWidget(covariant AnimatedMoon old) {
    super.didUpdateWidget(old);
    if (!old.active && widget.active) {
      _ctrl.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _ctrl.stop();
      });
    }
    if (old.active && !widget.active) _ctrl.stop();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      child: const Icon(Icons.bedtime,
          color: Colors.deepPurpleAccent, size: 32),
      builder: (_, child) =>
          Transform.translate(offset: Offset(_anim.value, 0), child: child),
    );
  }
}

class AnimatedPerson extends StatefulWidget {
  final bool active;
  const AnimatedPerson({super.key, required this.active});
  @override
  _AnimatedPersonState createState() => _AnimatedPersonState();
}

class _AnimatedPersonState extends State<AnimatedPerson>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _offset, _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _offset = Tween<double>(begin: -2, end: 2).animate(_ctrl);
    _scale  = Tween<double>(begin: 0.98, end: 1.02).animate(_ctrl);
    if (widget.active) {
      _ctrl.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _ctrl.stop();
      });
    }
  }
  @override
  void didUpdateWidget(covariant AnimatedPerson old) {
    super.didUpdateWidget(old);
    if (!old.active && widget.active) {
      _ctrl.repeat(reverse: true);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) _ctrl.stop();
      });
    }
    if (old.active && !widget.active) _ctrl.stop();
  }
  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      child: const Icon(Icons.directions_walk,
          color: Colors.cyanAccent, size: 32),
      builder: (_, child) => Transform.translate(
        offset: Offset(_offset.value, 0),
        child: Transform.scale(scale: _scale.value, child: child),
      ),
    );
  }
}

// =====  САМ ЭКРАН HOME  =====
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
          mainAxisSize: MainAxisSize.min, // Добавлено для компактности карточек
          children: [
            icon,
            const SizedBox(height: 8),
            Text(title,
                style: const TextStyle(fontSize: 16, color: Colors.white)),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView( // <--- ДОБАВЛЕН SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(16),
          child:
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const CircleAvatar(
                  radius: 28, backgroundImage: AssetImage('assets/user.png')),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text("Доброе утро,",
                    style: TextStyle(color: Colors.white70, fontSize: 16)),

                // === ДИНАМИЧЕСКОЕ ИМЯ ===
                Consumer<SettingsProvider>(
                  builder: (_, p, __) => Text(
                    "${(p.name.isEmpty ? 'Алекс' : p.name)}!",
                    style: const TextStyle(
                        fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ])
            ]),
            const SizedBox(height: 24),
            const Text("Дневная сводка",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(children: [
              summaryCard(AnimatedWater(active: active), "5/8", "стаканов"),
              summaryCard(AnimatedMoon(active: active), "6.5 ч", "/ 8 ч"),
            ]),
            Row(children: [
              summaryCard(AnimatedFlame(active: active), "1200", "/ 2200 ккал"),
              summaryCard(
                  AnimatedPerson(active: active), "7200", "10 000 шагов"),
            ]),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[800],
                  minimumSize: const Size(double.infinity, 50)),
              onPressed: () {},
              child: const Text("Показать аналитику"),
            ),
            const SizedBox(height: 24),
            const Text("Челлендж",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: const Color(0xFF1F1F1F),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: const [
                Icon(Icons.military_tech,
                    color: Colors.deepPurpleAccent, size: 32),
                SizedBox(width: 12),
                Expanded(
                    child: Text("Идёшь 7 дней подряд — получи медаль!",
                        style: TextStyle(fontSize: 16))),
              ]),
            ),
            // Добавляем немного отступа снизу, чтобы контент не прилипал к краю при прокрутке
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }
}