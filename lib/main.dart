import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';

/// App entry point for Neverest mobile frontend.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final firebaseInit = await _initializeFirebase();
  runApp(
    MainApp(
      firebaseReady: firebaseInit.ready,
      firebaseInitError: firebaseInit.errorMessage,
    ),
  );
}

Future<_FirebaseInitResult> _initializeFirebase() async {
  try {
    await Firebase.initializeApp();
    return const _FirebaseInitResult(ready: true);
  } catch (error) {
    return _FirebaseInitResult(
      ready: false,
      errorMessage: error.toString(),
    );
  }
}

class _FirebaseInitResult {
  const _FirebaseInitResult({
    required this.ready,
    this.errorMessage,
  });

  final bool ready;
  final String? errorMessage;
}
