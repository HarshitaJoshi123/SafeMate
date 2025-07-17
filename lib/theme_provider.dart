// lib/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getString('themeMode');

    if (savedTheme == 'Light') {
      _themeMode = ThemeMode.light;
    } else if (savedTheme == 'Dark') {
      _themeMode = ThemeMode.dark;
    } else {
      _themeMode = ThemeMode.system;
    }

    notifyListeners(); // Notifies the MaterialApp in main.dart
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;

    final prefs = await SharedPreferences.getInstance();
    String modeString = switch (mode) {
      ThemeMode.light => 'Light',
      ThemeMode.dark => 'Dark',
      _ => 'System',
    };

    await prefs.setString('themeMode', modeString);
    notifyListeners(); // Rebuilds the app with the new theme
  }
}
