import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLocaleCubit extends Cubit<Locale?> {
  AppLocaleCubit() : super(null) {
    _load();
  }

  static const _prefsKey = 'neverest_locale_code';
  static const systemCode = 'system';
  static const enCode = 'en';
  static const roCode = 'ro';

  String get currentCode => state?.languageCode ?? systemCode;

  Future<void> setLocaleCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    if (code == systemCode) {
      emit(null);
      await prefs.setString(_prefsKey, systemCode);
      return;
    }
    emit(Locale(code));
    await prefs.setString(_prefsKey, code);
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString(_prefsKey) ?? systemCode;
    if (code == systemCode) {
      emit(null);
      return;
    }
    emit(Locale(code));
  }
}
