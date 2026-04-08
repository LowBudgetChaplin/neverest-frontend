import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthTokenStorage {
  static const _key = 'neverest_access_token';
  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage();

  bool get _preferSharedPrefsOnThisPlatform =>
      kIsWeb || defaultTargetPlatform == TargetPlatform.android;

  Future<void> saveToken(String token) async {
    if (_preferSharedPrefsOnThisPlatform) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, token);
      return;
    }

    try {
      await _secureStorage.write(key: _key, value: token);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_key, token);
    }
  }

  Future<String?> readToken() async {
    if (_preferSharedPrefsOnThisPlatform) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_key);
    }

    try {
      return await _secureStorage.read(key: _key);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_key);
    }
  }

  Future<void> clearToken() async {
    if (_preferSharedPrefsOnThisPlatform) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
      return;
    }

    try {
      await _secureStorage.delete(key: _key);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_key);
    }
  }
}
