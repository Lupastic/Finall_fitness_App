import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Импортируйте Provider
import '../providers/theme_provider.dart'; // Укажите правильный путь к вашему ThemeProvider

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  final List<Map<String, dynamic>> stats = const [
    {'title': 'Water Intake', 'value': '1.8 L', 'icon': Icons.local_drink},
    {'title': 'Sleep Duration', 'value': '9 hr', 'icon': Icons.bedtime},
    {'title': 'Calories Burned', 'value': '2,407 kcal', 'icon': Icons.local_fire_department},
    {'title': 'Yoga Sessions', 'value': '2 sessions', 'icon': Icons.self_improvement},
    {'title': 'Running Distance', 'value': '12 km', 'icon': Icons.directions_run},
    {'title': 'Plank Time', 'value': '4 min', 'icon': Icons.accessibility_new},
    {'title': 'Meditation', 'value': '8 min', 'icon': Icons.spa},
    {'title': 'Sugar-Free Days', 'value': '3 days', 'icon': Icons.no_food},
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.grey.shade900 : const Color(0xFFF3F6FA),
      appBar: AppBar(
        title: const Text('Статистика'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: isDarkMode ? Colors.tealAccent.shade100 : Colors.teal.shade800,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];

          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isDarkMode ? Colors.grey.shade800 : Colors.white.withOpacity(0.85),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(4, 4),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Colors.teal.shade300, Colors.tealAccent.shade100],
                      ),
                    ),
                    child: Icon(stat['icon'] as IconData, color: Colors.white, size: 26),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stat['title'] as String,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Данные за последнюю неделю',
                          style: TextStyle(fontSize: 13, color: isDarkMode ? Colors.grey.shade400 : Colors.black54),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    stat['value'] as String,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  )
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}