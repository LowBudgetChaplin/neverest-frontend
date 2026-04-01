import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Manages the application language (Locale) with Riverpod and saves it in SharedPreferences to persist between starts
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
  (ref) => LocaleNotifier(),
);

/// StateNotifier that manages the app Locale and persists it to SharedPreferences.
class LocaleNotifier extends StateNotifier<Locale> {
  // Initializes with 'en' then loads the saved locale from SharedPreferences
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  // Loads the saved locale code from SharedPreferences and updates state
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'en';
    state = Locale(code);
  }

  // Changes the current locale and saves the new code to SharedPreferences
  Future<void> changeLocale(String code) async {
    state = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
  }

  // Returns the saved locale code (defaults to 'en' if not set)
  Future<String> getLanguageCode() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'en';
    return code;
  }
}
