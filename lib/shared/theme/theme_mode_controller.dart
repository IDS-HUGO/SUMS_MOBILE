import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/di/injection.dart';

const _themeModePrefsKey = 'app_theme_mode';

/// Controla el [ThemeMode] activo de la app y lo persiste en
/// [SharedPreferences] para que la elección del usuario sobreviva a un
/// reinicio (por defecto, antes de esto, la app solo seguía el modo del
/// sistema operativo sin poder elegirse manualmente).
class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._prefs) : super(_readInitial(_prefs));

  final SharedPreferences _prefs;

  static ThemeMode _readInitial(SharedPreferences prefs) {
    switch (prefs.getString(_themeModePrefsKey)) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_themeModePrefsKey, mode.name);
  }
}

final themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>(
      (ref) => ThemeModeController(sl<SharedPreferences>()),
    );
