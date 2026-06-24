import 'package:flutter/material.dart';
import 'app.dart';
import 'core/sync/background_worker.dart';

import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeBackgroundSync();
  final prefs = await SharedPreferences.getInstance();
  runApp(App(prefs: prefs));
}
