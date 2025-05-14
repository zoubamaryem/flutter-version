import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeProvider() {
    _loadThemeMode();
  }

  ThemeMode get themeMode => _themeMode;

  // Load saved theme preference
  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeIndex = prefs.getInt('themeMode') ?? 0;
    
    switch (themeModeIndex) {
      case 1:
        _themeMode = ThemeMode.light;
        break;
      case 2:
        _themeMode = ThemeMode.dark;
        break;
      default:
        _themeMode = ThemeMode.system;
    }
    
    notifyListeners();
  }

  // Set theme mode and save preference
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    int themeModeIndex;
    
    switch (mode) {
      case ThemeMode.light:
        themeModeIndex = 1;
        break;
      case ThemeMode.dark:
        themeModeIndex = 2;
        break;
      case ThemeMode.system:
      default:
        themeModeIndex = 0;
    }
    
    await prefs.setInt('themeMode', themeModeIndex);
  }
}