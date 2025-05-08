import 'package:flutter/material.dart';

class AchievementsPage extends StatefulWidget {
  const AchievementsPage({super.key});

  @override
  State<AchievementsPage> createState() => _AchievementsPageState();
}

class _AchievementsPageState extends State<AchievementsPage> {
  final achievements = const [
    {'title': 'Early Bird', 'icon': Icons.check_circle, 'done': true},
    {'title': 'Hydrated', 'icon': Icons.opacity, 'value': '1/10'},
    {'title': 'Week Streak', 'icon': Icons.star_border, 'value': '0/7'},
    {'title': 'Marathon', 'icon': Icons.directions_run},
    {'title': 'Meal Master', 'icon': Icons.restaurant, 'done': true},
    {'title': 'Intermediate', 'icon': Icons.local_fire_department},
    {'title': 'Champion', 'icon': Icons.emoji_events, 'value': '50,000 steps'},
    {'title': 'Brisk Walk', 'icon': Icons.directions_walk, 'value': '0/30 mins'},
  ];

  int _rebuildKey = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    setState(() => _rebuildKey++); // 🔁 перезапуск при возвращении на вкладку
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Достижения')),
      body: GridView.builder(
        key: ValueKey(_rebuildKey),
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: achievements.length,
        itemBuilder: (context, index) {
          final a = achievements[index];
          return AchievementCard(
            title: a['title'] as String,
            icon: a['icon'] as IconData,
            value: a['value'] as String?,
            done: a['done'] == true,
          );
        },
      ),
    );
  }
}

class AchievementCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final String? value;
  final bool done;

  const AchievementCard({
    super.key,
    required this.title,
    required this.icon,
    required this.value,
    required this.done,
  });

  @override
  State<AchievementCard> createState() => _AchievementCardState();
}

class _AchievementCardState extends State<AchievementCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2), // один цикл пульсации
    );

    _scale = Tween<double>(
      begin: widget.done ? 0.95 : 0.98,
      end: widget.done ? 1.05 : 1.02,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
    _controller.forward();
    Future.delayed(const Duration(seconds: 2), () => _controller.reverse());
    Future.delayed(const Duration(seconds: 4), () => _controller.forward());
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) _controller.stop();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bgColor = widget.done ? const Color(0xFF2E7D32) : const Color(0xFF1F1F1F);
    final iconColor = widget.done ? Colors.greenAccent : Colors.white70;
    return AnimatedBuilder(
      animation: _scale,
      builder: (context, child) {
        return Transform.scale(
          scale: _scale.value,
          child: child,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(widget.icon, size: 36, color: iconColor),
            const SizedBox(height: 8),
            Text(
              widget.title,
              style: const TextStyle(fontSize: 14, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            if (widget.value != null)
              Text(
                widget.value!,
                style: const TextStyle(color: Colors.white70),
              ),
          ],
        ),
      ),
    );
  }
}