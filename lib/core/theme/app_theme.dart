import 'package:flutter/material.dart';

const _primary = Color(0xFF1A1A2E);
const _surface = Color(0xFFF5F5F5);

final appTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: _primary,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
  scaffoldBackgroundColor: _surface,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    foregroundColor: _primary,
    elevation: 0,
    centerTitle: false,
    titleTextStyle: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: _primary,
    ),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: Colors.white,
    elevation: 1,
    indicatorColor: Color(0xFFE8E8F0),
    labelTextStyle: WidgetStatePropertyAll(
      TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: _primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: _primary,
      side: const BorderSide(color: _primary),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  cardTheme: const CardThemeData(
    elevation: 0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
    margin: EdgeInsets.zero,
  ),
  dividerTheme: const DividerThemeData(color: Color(0xFFEEEEEE), space: 1),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(),
    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  ),
  sliderTheme: const SliderThemeData(
    activeTrackColor: _primary,
    thumbColor: _primary,
    overlayColor: Color(0x201A1A2E),
    inactiveTrackColor: Color(0xFFDDDDDD),
    trackHeight: 2,
    thumbShape: RoundSliderThumbShape(enabledThumbRadius: 7),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: WidgetStateProperty.resolveWith(
      (states) => states.contains(WidgetState.selected) ? _primary : null,
    ),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(3)),
  ),
  snackBarTheme: const SnackBarThemeData(
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8))),
  ),
);
