import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart'; // Импортируйте ThemeProvider

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
    setState(() => _rebuildKey++);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : const Color(0xFFF3F6FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Achievements',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: GridView.builder(
        key: ValueKey(_rebuildKey),
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 20,
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

class AchievementCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    final Color bgColor = done
        ? isDarkMode ? Colors.green.shade800.withOpacity(0.8) : const Color(0xFFE0F7EC) // soft green for completed
        : isDarkMode ? Colors.grey.shade800.withOpacity(0.8) : Colors.white.withOpacity(0.8);
    final Color iconColor = done ? Colors.green.shade600 : Colors.indigo.shade400;
    final Color textColor = done ? (isDarkMode ? Colors.greenAccent.shade100 : Colors.green.shade900) : (isDarkMode ? Colors.white : Colors.black87);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        color: bgColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: const Offset(4, 6),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 38, color: iconColor)
              .animate()
              .scale(delay: 100.ms, duration: 400.ms, curve: Curves.easeOut),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            textAlign: TextAlign.center,
          ),
          if (value != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                value!,
                style: TextStyle(
                  fontSize: 13,
                  color: textColor.withOpacity(0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}