import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xff006657);
  static const greenDark = Color(0xff073b34);
  static const gold = Color(0xffbc955c);
  static const burgundy = Color(0xff691c32);
  static const cream = Color(0xfff7f3e8);
  static const soft = Color(0xffeef4ef);
  static const ink = Color(0xff222722);
  static const muted = Color(0xff606b64);
  static const line = Color(0xffd8cdb9);
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      primary: AppColors.green,
      secondary: AppColors.gold,
      tertiary: AppColors.burgundy,
      surface: AppColors.cream,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.cream,
      fontFamily: 'Arial',
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.greenDark,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.line),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          // Keep the fix for infinite width by avoiding Size.fromHeight(48)
          minimumSize: const Size(64, 48),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.burgundy,
          side: const BorderSide(color: AppColors.gold),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          minimumSize: const Size(64, 48),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.green, width: 1.6),
        ),
      ),
    );
  }
}
