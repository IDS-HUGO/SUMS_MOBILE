import 'package:flutter/material.dart';

class AppColors {
  static const green = Color(0xff006455);
  static const greenDark = Color(0xff00473a);
  static const greenLight = Color(0xff1b8875);
  static const terracota = Color(0xff9b4f2e);
  static const gold = Color(0xffbc955c);
  static const burgundy = Color(0xff691c32);
  static const canvas = Color(0xfff4efe6);
  static const surface = Color(0xffffffff);
  static const surfaceAlt = Color(0xfffaf7f2);
  static const soft = Color(0xffeef4ef);
  static const ink = Color(0xff1a2320);
  static const muted = Color(0xff5a6862);
  static const subtle = Color(0xff8fa49d);
  static const line = Color(0xffe2d9c8);
  static const lineStrong = Color(0xffc8bfae);
  static const success = Color(0xff2e7d32);
  static const warning = Color(0xfff57f17);
  static const error = Color(0xffc62828);
  static const rolAdmin = greenDark;
  static const rolMedico = burgundy;
  static const rolEncuestador = green;
  static const rolAnalista = Color(0xff1565c0);
}

class AppDimens {
  static const radiusS = 6.0;
  static const radiusM = 10.0;
  static const radiusL = 14.0;
  static const radiusXL = 20.0;
}

class AppTheme {
  static const seedColor = AppColors.green;
  static const secondaryColor = AppColors.gold;
  static const tertiaryColor = AppColors.burgundy;
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      primary: seedColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: AppColors.surface,
      surfaceContainerHighest: AppColors.surfaceAlt,
      brightness: Brightness.light,
    );
    return _buildTheme(scheme, AppColors.canvas);
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      primary: seedColor,
      secondary: secondaryColor,
      tertiary: tertiaryColor,
      surface: const Color(0xff121212),
      surfaceContainerHighest: const Color(0xff1e1e1e),
      brightness: Brightness.dark,
    );
    return _buildTheme(scheme, const Color(0xff000000));
  }

  static ThemeData _buildTheme(ColorScheme scheme, Color scaffoldColor) {
    final isDark = scheme.brightness == Brightness.dark;
    final ink = isDark ? Colors.white : AppColors.ink;
    final muted = isDark ? Colors.grey[400]! : AppColors.muted;
    final line = isDark ? Colors.grey[800]! : AppColors.line;
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scaffoldColor,
      fontFamily: 'Arial',
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: line,
        centerTitle: false,
        iconTheme: IconThemeData(color: scheme.onPrimary),
        actionsIconTheme: IconThemeData(color: scheme.onPrimary),
        titleTextStyle: TextStyle(
          fontFamily: 'Arial',
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: scheme.onPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          side: BorderSide(color: line),
        ),
        margin: EdgeInsets.zero,
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
          ),
          minimumSize: const Size(64, 50),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.primary,
          side: BorderSide(color: scheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.radiusM),
          ),
          minimumSize: const Size(64, 50),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        labelStyle: TextStyle(
          color: muted,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide(color: line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide(color: line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        prefixIconColor: muted,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHighest,
        selectedColor: scheme.primaryContainer,
        checkmarkColor: scheme.onPrimaryContainer,
        side: BorderSide(color: line),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusS),
        ),
        labelStyle: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: ink,
        ),
      ),
      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimens.radiusS),
            ),
          ),
          backgroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? scheme.primaryContainer
                : scheme.surface,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : muted,
          ),
          side: WidgetStatePropertyAll(BorderSide(color: line)),
          textStyle: const WidgetStatePropertyAll(
            TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
        ),
      ),
      dividerTheme: DividerThemeData(color: line, thickness: 1, space: 24),
      textTheme: TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w900,
          color: scheme.primary,
          letterSpacing: -0.5,
        ),
        headlineMedium: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          color: scheme.primary,
        ),
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: scheme.primary,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: scheme.primary,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: ink,
        ),
        titleSmall: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: muted,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: ink,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: ink,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: muted,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: ink,
        ),
        labelSmall: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: muted,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
