import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService {
  static const _key = 'locale_code';
  static const supportedCodes = ['en', 'fr', 'rw'];

  static final ValueNotifier<Locale> notifier =
      ValueNotifier(const Locale('en'));

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved != null && supportedCodes.contains(saved)) {
      notifier.value = Locale(saved);
    }
  }

  static Future<void> setLocale(Locale locale) async {
    notifier.value = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, locale.languageCode);
  }

  static String get currentCode => notifier.value.languageCode;
}
