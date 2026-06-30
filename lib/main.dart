import 'package:flutter/material.dart';
import 'package:flutter_jailbreak_detection/flutter_jailbreak_detection.dart';
import 'app.dart';
import 'core/sync/background_worker.dart';
import 'core/network/app_logger.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeBackgroundSync();

  bool isSecure = true;
  try {
    final jailbroken = await FlutterJailbreakDetection.jailbroken;
    final developerMode = await FlutterJailbreakDetection.developerMode;
    if (jailbroken) {
      isSecure = false;
      AppLogger.warn('Dispositivo con Jailbreak/Root detectado (OWASP MASVS-RESILIENCE-1).');
    }
    if (developerMode) {
      AppLogger.warn('Modo desarrollador activo (OWASP MASVS-RESILIENCE-2).');
    }
  } catch (e) {
    AppLogger.error('Error al verificar integridad de entorno de ejecucion', e);
  }

  final prefs = await SharedPreferences.getInstance();
  runApp(App(prefs: prefs, isSecureDevice: isSecure));
}
