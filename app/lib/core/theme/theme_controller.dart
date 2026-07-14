import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Theme mode options for the app (simplified; system mode support for future)
enum AppThemeMode {
  light,
  dark,
}

/// Controller to manage theme mode (light/dark) via Riverpod StateNotifier with SharedPreferences persistence
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  ThemeModeNotifier() : super(ThemeMode.light) {
    _loadThemeMode();
  }

  static const _themeModeKey = 'theme_mode';

  /// Load persisted theme mode from SharedPreferences
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeModeString = prefs.getString(_themeModeKey) ?? 'light';
      state = themeModeString == 'dark' ? ThemeMode.dark : ThemeMode.light;
    } catch (e) {
      // Fallback to light theme if SharedPreferences fails
      state = ThemeMode.light;
    }
  }

  /// Update theme mode and persist to storage
  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, mode == ThemeMode.dark ? 'dark' : 'light');
    } catch (e) {
      // If persistence fails, state is still updated in memory
      debugPrint('Failed to persist theme mode: $e');
    }
  }

  /// Toggle between light and dark modes
  Future<void> toggleTheme() async {
    final newMode = state == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    await setThemeMode(newMode);
  }
}

/// Riverpod provider for theme mode state
final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  return ThemeModeNotifier();
});
