import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService {
  static const _key = 'theme_mode';

  static final ValueNotifier<ThemeMode> notifier =
      ValueNotifier(ThemeMode.light);

  /// Call once before runApp to restore the saved preference.
  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    notifier.value = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
  }

  /// Toggle between light and dark, and persist the choice.
  static Future<void> toggle() async {
    final next =
        notifier.value == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifier.value = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, next == ThemeMode.dark ? 'dark' : 'light');
  }

  static bool get isDark => notifier.value == ThemeMode.dark;
}
