import 'package:flutter/material.dart';

abstract final class PrizmaColors {
  static const canvas = Color(0xFFF4F7FE);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceSubtle = Color(0xFFF8FAFF);
  static const surfaceMuted = Color(0xFFF0F3FA);
  static const ink = Color(0xFF1B2559);
  static const inkSoft = Color(0xFF526084);
  static const muted = Color(0xFF8F9BBA);
  static const line = Color(0xFFE4EAF5);
  static const violet = Color(0xFF7551FF);
  static const violetDeep = Color(0xFF5B38E8);
  static const violetSoft = Color(0xFFEEE9FF);
  static const cyan = Color(0xFF36C6D8);
  static const cyanSoft = Color(0xFFE3FAFC);
  static const green = Color(0xFF05B881);
  static const greenSoft = Color(0xFFE5F9F3);
  static const orange = Color(0xFFFF9E42);
  static const orangeSoft = Color(0xFFFFF3E5);
  static const pink = Color(0xFFEF6BB7);
  static const pinkSoft = Color(0xFFFFF0F8);
  static const yellow = Color(0xFFF6C945);
  static const yellowSoft = Color(0xFFFFF8DF);
  static const danger = Color(0xFFE85663);
  static const navy = Color(0xFF182257);
}

ThemeData prizmaLightTheme() {
  const scheme = ColorScheme.light(
    primary: PrizmaColors.violet,
    onPrimary: Colors.white,
    secondary: PrizmaColors.cyan,
    onSecondary: PrizmaColors.ink,
    surface: PrizmaColors.surface,
    onSurface: PrizmaColors.ink,
    error: PrizmaColors.danger,
    onError: Colors.white,
  );

  final textTheme = Typography.material2021().black.apply(
    bodyColor: PrizmaColors.ink,
    displayColor: PrizmaColors.ink,
    fontFamily: 'Arial',
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: PrizmaColors.canvas,
    textTheme: textTheme,
    dividerColor: PrizmaColors.line,
    splashFactory: InkSparkle.splashFactory,
    appBarTheme: const AppBarTheme(
      backgroundColor: PrizmaColors.canvas,
      foregroundColor: PrizmaColors.ink,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: PrizmaColors.surfaceSubtle,
      hintStyle: const TextStyle(color: PrizmaColors.muted, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: PrizmaColors.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: PrizmaColors.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: PrizmaColors.violet, width: 1.5),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: PrizmaColors.navy,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    ),
  );
}

ThemeData prizmaDarkTheme() {
  const canvas = Color(0xFF11172A);
  const surface = Color(0xFF182039);
  const surfaceSubtle = Color(0xFF202A46);
  const line = Color(0xFF2B3858);
  const ink = Color(0xFFF3F5FF);
  const muted = Color(0xFF919DBD);
  const scheme = ColorScheme.dark(
    primary: Color(0xFF9177FF),
    onPrimary: Colors.white,
    secondary: Color(0xFF66D9DF),
    surface: surface,
    onSurface: ink,
    error: Color(0xFFFF7A85),
    onError: Colors.white,
  );
  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: canvas,
    dividerColor: line,
    textTheme: Typography.material2021().white.apply(
      bodyColor: ink,
      displayColor: ink,
      fontFamily: 'Arial',
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: canvas,
      foregroundColor: ink,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceSubtle,
      hintStyle: const TextStyle(color: muted, fontSize: 13),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: const BorderSide(color: Color(0xFF9177FF), width: 1.5),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF303D63),
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
    ),
  );
}

Color pageSurface(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF182039)
    : PrizmaColors.surface;

Color pageSubtleSurface(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF202A46)
    : PrizmaColors.surfaceSubtle;

Color pageLine(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF2B3858)
    : PrizmaColors.line;

Color pageMuted(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF919DBD)
    : PrizmaColors.muted;
