import 'package:flutter/material.dart';
import 'app/app.dart';

/// App entry point for Neverest mobile frontend.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MainApp());
}
