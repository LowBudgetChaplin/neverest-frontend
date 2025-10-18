import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app/app.dart';

/// App entry point: initializes bindings, sets task switcher info,
/// requests notification permissions, and runs the app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  setAppSwitcher();
  _requestPermissions();

  runApp(
    const ProviderScope(
        child: MainApp()
      )
  );
}

// Sets the information displayed in the app/task switcher
void setAppSwitcher() {
  SystemChrome.setApplicationSwitcherDescription(
    const ApplicationSwitcherDescription(
      label: 'One step at a time',
      primaryColor: 0xFFFFFFFF,
    ),
  );
}

// Requests notification permissions
void _requestPermissions() async {
  if (Platform.isAndroid) {
    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 33) {
      final status = await Permission.notification.status;
      if (!status.isGranted) {
        await Permission.notification.request();
      }
    }
  }

  if (Platform.isIOS) {
    final settings = await FirebaseMessaging.instance.requestPermission();
    debugPrint('iOS permission: ${settings.authorizationStatus}');
  }
}