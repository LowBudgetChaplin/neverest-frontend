import 'dart:ui';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Riverpod StateNotifierProvider that exposes the current Locale and a controller (LocaleNotifier) to update it
// Widgets can ref.watch(localeProvider) to rebuild when the app language changes
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>(
      (ref) => LocaleNotifier(),
);

// Holds the current locale and persists user choice to SharedPreferences
class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadLocale();
  }

  // Falls back to 'en' when no value is stored and updates 'state' so the UI reflects the stored locale at startup
  void _loadLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString('locale') ?? 'en';
    state = Locale(code);
  }

  // UI changes language instantly and persists across app restarts
  Future<void> changeLocale(String code) async {
    state = Locale(code);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', code);
  }
}