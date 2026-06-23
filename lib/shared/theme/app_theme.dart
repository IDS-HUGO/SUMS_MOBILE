import 'package:flutter/material.dart';

class AppColors {
  static const green        = Color(0xff006657);
  static const greenDark    = Color(0xff073b34);
  static const greenLight   = Color(0xff4a9e8e);
  static const terracota    = Color(0xff9b4f2e); // ← NUEVO: acento tierra
  static const gold         = Color(0xffbc955c);
  static const burgundy     = Color(0xff691c32);

  static const canvas       = Color(0xfff4efe6);
  static const surface      = Color(0xffffffff);
  static const surfaceAlt   = Color(0xfffaf7f2);
  static const soft         = Color(0xffeef4ef);

  static const ink          = Color(0xff1a2320);
  static const muted        = Color(0xff5a6862);
  static const subtle       = Color(0xff8fa49d);

  static const line         = Color(0xffe2d9c8);
  static const lineStrong   = Color(0xffc8bfae);
  static const success      = Color(0xff2e7d32);
  static const warning      = Color(0xfff57f17);
  static const error        = Color(0xffc62828);

  // Colores semánticos por rol
  static const rolAdmin       = greenDark;
  static const rolMedico      = burgundy;
  static const rolEncuestador = green;
  static const rolAnalista    = Color(0xff1565c0);
}

class AppDimens {
  static const radiusS  = 6.0;
  static const radiusM  = 10.0;
  static const radiusL  = 14.0;
  static const radiusXL = 20.0;
}

class AppTheme {
  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor:  AppColors.green,
      primary:    AppColors.green,
      secondary:  AppColors.gold,
      tertiary:   AppColors.burgundy,
      surface:    AppColors.surface,
      surfaceContainerHighest: AppColors.surfaceAlt,
      brightness: Brightness.light,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme:  scheme,
      scaffoldBackgroundColor: AppColors.canvas,
      fontFamily:   'Arial',

      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.greenDark,
        elevation:       0,
        scrolledUnderElevation: 1,
        shadowColor:     AppColors.line,
        centerTitle:     false,
        titleTextStyle:  TextStyle(
          fontFamily: 'Arial', fontSize: 16, fontWeight: FontWeight.w700,
          color: AppColors.greenDark,
        ),
      ),

      cardTheme: CardThemeData(
        color:     AppColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimens.radiusM),
          side: const BorderSide(color: AppColors.line),
        ),
        margin: EdgeInsets.zero,
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.green,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM)),
          minimumSize:    const Size(64, 50),
          textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          elevation: 0,
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.green,
          side:            const BorderSide(color: AppColors.green, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM)),
          minimumSize:    const Size(64, 50),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled:         true,
        fillColor:      AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        labelStyle:     const TextStyle(color: AppColors.muted, fontSize: 14, fontWeight: FontWeight.w500),
        border:         OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM), borderSide: const BorderSide(color: AppColors.line)),
        enabledBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM), borderSide: const BorderSide(color: AppColors.line)),
        focusedBorder:  OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM), borderSide: const BorderSide(color: AppColors.green, width: 2)),
        errorBorder:    OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM), borderSide: const BorderSide(color: AppColors.error)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.radiusM), borderSide: const BorderSide(color: AppColors.error, width: 2)),
        prefixIconColor: AppColors.muted,
      ),

      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceAlt,
        selectedColor:   AppColors.soft,
        checkmarkColor:  AppColors.green,
        side:            const BorderSide(color: AppColors.line),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusS)),
        labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.ink),
      ),

      segmentedButtonTheme: SegmentedButtonThemeData(
        style: ButtonStyle(
          shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimens.radiusS))),
          backgroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.soft : AppColors.surface),
          foregroundColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? AppColors.green : AppColors.muted),
          side: const WidgetStatePropertyAll(BorderSide(color: AppColors.line)),
          textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ),
      ),

      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 24),

      textTheme: const TextTheme(
        headlineLarge:  TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.greenDark, letterSpacing: -0.5),
        headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.greenDark),
        headlineSmall:  TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.greenDark),
        titleLarge:     TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.greenDark),
        titleMedium:    TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
        titleSmall:     TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.muted),
        bodyLarge:      TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: AppColors.ink),
        bodyMedium:     TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppColors.ink),
        bodySmall:      TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: AppColors.muted),
        labelLarge:     TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink),
        labelSmall:     TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.muted, letterSpacing: 0.5),
      ),
    );
  }
}