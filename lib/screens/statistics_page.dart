import 'package:flutter/material.dart';

class StatisticsPage extends StatelessWidget {
  const StatisticsPage({super.key});

  final stats = const [
    {'title': 'Water', 'value': '1.8 L', 'icon': Icons.local_drink},
    {'title': 'Sleep', 'value': '9 hr', 'icon': Icons.bedtime},
    {'title': 'Calories', 'value': '2,407 kcal', 'icon': Icons.local_fire_department},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Статистика')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: stats.length,
        itemBuilder: (context, index) {
          final stat = stats[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              leading: Icon(stat['icon'] as IconData, size: 28, color: Colors.cyanAccent),
              title: Text(stat['title'] as String, style: const TextStyle(fontSize: 18)),
              subtitle: const Text('Данные по дням'),
              trailing: Text(stat['value']?.toString() ?? "", style: const TextStyle(fontWeight: FontWeight.bold)),
            ),
          );
        },
      ),
    );
  }
}
