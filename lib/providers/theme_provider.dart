import 'package:flutter/material.dart';

class ThemeProvider with ChangeNotifier {
  // Default theme is light mode
  ThemeMode _themeMode = ThemeMode.light;

  // Getter to access the current theme mode
  ThemeMode get themeMode => _themeMode;

  // Method to toggle between light and dark modes
  void toggleTheme(bool isDarkMode) {
    _themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  // New method to toggle notifications (you may have this logic in your app)
  bool _areNotificationsEnabled = true;
  bool get areNotificationsEnabled => _areNotificationsEnabled;

  void toggleNotifications(bool value) {
    _areNotificationsEnabled = value;
    notifyListeners();
  }

  // Reset settings to defaults
  void resetSettings() {
    _themeMode = ThemeMode.light; // Reset to light mode
    _areNotificationsEnabled = true; // Enable notifications by default
    notifyListeners();
  }
}
