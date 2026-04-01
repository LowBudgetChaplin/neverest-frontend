import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthTokenStorage {
  static const _key = 'neverest_access_token';
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> saveToken(String token) {
    return _storage.write(key: _key, value: token);
  }

  Future<String?> readToken() {
    return _storage.read(key: _key);
  }

  Future<void> clearToken() {
    return _storage.delete(key: _key);
  }
}
