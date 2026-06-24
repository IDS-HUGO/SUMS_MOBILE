import 'package:flutter/material.dart';
import 'app.dart';
import 'core/sync/background_worker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  initializeBackgroundSync();
  runApp(const App());
}
