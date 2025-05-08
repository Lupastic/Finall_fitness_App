import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart'; // <--- ДОБАВЬ ЭТОТ ИМПОРТ
import 'package:firebase_auth/firebase_auth.dart'; // <--- ДОБАВЬ ЭТОТ ИМПОРТ
import '../providers/settings_provider.dart'; // <--- ДОБАВЬ ЭТОТ ИМПОРТ

import 'home_page.dart';
import 'challenges_page.dart';
import 'statistics_page.dart';
import 'achievements_page.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class NavigationWrapper extends StatefulWidget {
  final bool isGuest;

  const NavigationWrapper({super.key, this.isGuest = false});

  @override
  State<NavigationWrapper> createState() => _NavigationWrapperState();
}

class _NavigationWrapperState extends State<NavigationWrapper> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Загружаем настройки только если это не гостевой режим
    // и если пользователь аутентифицирован (хотя сюда мы должны попадать только аутентифицированными,
    // но проверка не помешает).
    if (!widget.isGuest) {
      // Используем addPostFrameCallback, чтобы убедиться, что BuildContext доступен
      // и чтобы не вызывать setState или операции, изменяющие состояние, прямо в initState.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // Проверяем, есть ли текущий пользователь (на всякий случай)
        final user = FirebaseAuth.instance.currentUser;
        if (user != null && mounted) { // Добавил mounted для безопасности
          // Используем context.read, так как нам не нужно слушать изменения здесь,
          // а только один раз вызвать метод.
          context.read<SettingsProvider>().loadSettingsFromFirebase();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Формируем список страниц и элементов навигации динамически
    // на основе widget.isGuest, чтобы избежать проблем с индексами,
    // если ProfilePage и SettingsPage отсутствуют.
    final List<Widget> pages = [
      const HomePage(active: true), // active будет обновляться в IndexedStack
      const StatisticsPage(),
      const ChallengesPage(),
      const AchievementsPage(),
    ];

    final List<BottomNavigationBarItem> navItems = [
      BottomNavigationBarItem(icon: const Icon(Icons.home), label: localizations.home),
      BottomNavigationBarItem(icon: const Icon(Icons.bar_chart), label: localizations.statistics),
      BottomNavigationBarItem(icon: const Icon(Icons.flag), label: localizations.challenges),
      BottomNavigationBarItem(icon: const Icon(Icons.emoji_events), label: localizations.achievements),
    ];

    if (!widget.isGuest) {
      pages.add(const ProfilePage());
      pages.add(const SettingsPage());
      navItems.add(BottomNavigationBarItem(icon: const Icon(Icons.person), label: localizations.profile));
      navItems.add(BottomNavigationBarItem(icon: const Icon(Icons.settings), label: localizations.settings));
    }

    // Корректируем _currentIndex, если он выходит за пределы доступных элементов
    // (например, если был на странице настроек, а потом вошел как гость)
    if (_currentIndex >= navItems.length) {
      _currentIndex = 0; // Сбрасываем на первую страницу
    }


    return Scaffold(
      appBar: widget.isGuest
          ? AppBar(
        title: const Text("Guest Mode"), // Можно локализовать, если нужно
        backgroundColor: Colors.orange,
        centerTitle: true,
      )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        // Обновляем параметр active для HomePage динамически
        children: pages.asMap().entries.map((entry) {
          int idx = entry.key;
          Widget page = entry.value;
          if (page is HomePage) {
            return HomePage(active: _currentIndex == idx);
          }
          return page;
        }).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF1A1A1A),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
        type: BottomNavigationBarType.fixed,
        items: navItems,
      ),
    );
  }
}