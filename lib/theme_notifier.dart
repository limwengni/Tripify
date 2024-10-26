import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default to light theme

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? theme = prefs.getString('theme');
    
    // Check saved theme and set _themeMode accordingly
    if (theme == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (theme == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.light; // Set default to light theme if nothing is saved
    }
    
    notifyListeners();
  }

  void setTheme(ThemeMode mode) async {
    _themeMode = mode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    
    // Save the selected theme
    if (mode == ThemeMode.dark) {
      await prefs.setString('theme', 'dark');
    } else if (mode == ThemeMode.light) {
      await prefs.setString('theme', 'light');
    } else {
      await prefs.remove('theme'); // Reset to default light theme
    }
    
    notifyListeners();
  }
}
