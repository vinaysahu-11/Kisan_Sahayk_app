import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  final AuthService _authService = AuthService();

  ThemeMode get themeMode => _themeMode;
  
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadSavedTheme() async {
    try {
      // First load from local storage
      final prefs = await SharedPreferences.getInstance();
      final isDark = prefs.getBool('is_dark_mode') ?? false;
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();

      // Try to sync with backend
      try {
        final response = await _authService.getPreferences();
        if (response['success'] == true && response['preferences'] != null) {
          final darkMode = response['preferences']['darkMode'] ?? false;
          if (darkMode != isDark) {
            _themeMode = darkMode ? ThemeMode.dark : ThemeMode.light;
            await prefs.setBool('is_dark_mode', darkMode);
            notifyListeners();
          }
        }
      } catch (e) {
        // Ignore backend sync errors, use local storage
        print('Theme sync with backend failed: $e');
      }
    } catch (e) {
      print('Failed to load theme: $e');
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_dark_mode', mode == ThemeMode.dark);
    
    // Sync with backend
    try {
      await _authService.updatePreferences(darkMode: mode == ThemeMode.dark);
    } catch (e) {
      print('Failed to sync theme with backend: $e');
      // Continue even if backend sync fails
    }
  }
  
  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}
