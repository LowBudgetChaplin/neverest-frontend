import 'dart:io';

import 'package:flutter/foundation.dart';

class AppConfig {
  static String get apiBaseUrl {
    const fromEnv = String.fromEnvironment('API_BASE_URL');
    if (fromEnv.isNotEmpty) {
      return fromEnv;
    }

    if (kIsWeb) {
      return 'http://localhost:8081';
    }

    if (Platform.isAndroid) {
      return 'http://10.0.2.2:8081';
    }

    return 'http://localhost:8081';
  }
}
